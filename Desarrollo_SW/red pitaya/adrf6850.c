/**
 * @file    adrf6850.c
 * @brief   ADRF6850 driver implementation (bare-metal, no dynamic memory,
 *          no floating point).
 *
 * Reference: ADRF6850 Data Sheet, Rev. A (7/2022).
 */

#include "adrf6850.h"
#include <unistd.h>

/* ------------------------------------------------------------------------
 * Internal state
 * ---------------------------------------------------------------------- */

static adrf6850_state_t g_dev;

/* ------------------------------------------------------------------------
 * Low-level SPI access
 * ---------------------------------------------------------------------- */

/**
 * @brief Select and lock the SPI protocol.
 *
 * The part powers up in I2C mode. Three pulses on CS latch the SPI protocol
 * on the third rising edge; once locked it can only be released by cycling
 * the supply (Data Sheet, "Serial Interface Selection", Figure 65).
 *
 */
static void adrf6850_spi_lock(void)
{
    uint8_t i;
    uint8_t dummy = 0x00U;

    for (i = 0; i < 3U; i++) {
        adrf6850_hw_spi_write(&dummy, 1U);
        usleep(1U);
    }
}

/**
 * @brief 24-bit register write: 0xD4, address, data.
 */
void adrf6850_write_reg(uint8_t addr, uint8_t data)
{
    uint8_t frame[3];

    frame[0] = ADRF6850_SPI_CMD_WRITE;
    frame[1] = addr;
    frame[2] = data;

    adrf6850_hw_spi_write(frame, 3U);
}

/**
 * @brief Register readback: a 16-bit write selects the register, then a
 *        second CS pulse issues 0xD5 and clocks the data out on SDO.
 */
uint8_t adrf6850_read_reg(uint8_t addr)
{
    uint8_t frame[2];
    uint8_t data = 0U;

    frame[0] = ADRF6850_SPI_CMD_WRITE;
    frame[1] = addr;

    adrf6850_hw_spi_write(frame, 2U);

    frame[0] = ADRF6850_SPI_CMD_READ;

    adrf6850_hw_spi_write(frame, 1U);
    adrf6850_hw_spi_read(&data, 1U);

    return data;
}

/* ------------------------------------------------------------------------
 * Frequency planning
 * ---------------------------------------------------------------------- */

/**
 * @brief Pick RFDIV and compute the INT/FRAC pair for a given LO frequency.
 *
 * RFDIV comes from the lookup table (Table 6) and the divider ratio is then
 *
 *      N = 2^(RFDIV+1) * LO / fPFD          (Equation 4)
 *      N = INT + FRAC / 2^25                (Equation 5)
 *
 * The whole computation is carried out in 64-bit fixed point with 25
 * fractional bits, so no FPU is required and the result is bit-exact
 * (round-to-nearest) rather than dependent on double rounding.
 *
 * @param[in]  lo_hz   Desired LO frequency in Hz.
 * @param[out] rfdiv   CR28[2:0] code.
 * @param[out] n_int   12-bit integer word.
 * @param[out] n_frac  25-bit fractional word.
 * @param[out] actual  Frequency actually synthesized, in Hz (may be NULL).
 * @return ADRF6850_OK, ADRF6850_ERR_PARAM or ADRF6850_ERR_RANGE.
 */
static adrf6850_status_t adrf6850_calc_freq(uint32_t  lo_hz,
                                            uint8_t  *rfdiv,
                                            uint16_t *n_int,
                                            uint32_t *n_frac,
                                            uint32_t *actual)
{
    uint64_t q25;
    uint8_t  d;

    if ((lo_hz < ADRF6850_LO_MIN_HZ) || (lo_hz > ADRF6850_LO_MAX_HZ)) {
        return ADRF6850_ERR_PARAM;
    }

    /* Table 6: RFDIV lookup. */
    if (lo_hz >= 500000000UL) {
        d = 0U;                     /* divide by 1 */
    } else if (lo_hz >= 250000000UL) {
        d = 1U;                     /* divide by 2 */
    } else if (lo_hz >= 125000000UL) {
        d = 2U;                     /* divide by 4 */
    } else {
        d = 3U;                     /* divide by 8 */
    }

    /* q25 = round( 2^(RFDIV+1) * LO * 2^25 / fPFD ). Max value ~6.8e16. */
    q25  = ((uint64_t)lo_hz) << (d + 1U);
    q25 <<= 25;
    q25 += (uint64_t)(ADRF6850_PFD_HZ / 2U);        /* round to nearest */
    q25 /= (uint64_t)ADRF6850_PFD_HZ;

    *n_int  = (uint16_t)(q25 >> 25);
    *n_frac = (uint32_t)(q25 & (ADRF6850_FRAC_MOD - 1UL));
    *rfdiv  = d;

    /* The RF fractional-N divider supports ratios from 23 to 4095. */
    if ((*n_int < 23U) || (*n_int > 4095U)) {
        return ADRF6850_ERR_RANGE;
    }

    if (actual != (uint32_t *)0) {
        uint64_t f = (uint64_t)ADRF6850_PFD_HZ * q25;
        f += (uint64_t)1 << (25U + d);                  /* round to nearest */
        *actual = (uint32_t)(f >> (25U + d + 1U));
    }

    return ADRF6850_OK;
}

/**
 * @brief Convert a VGA gain in milli-dB to the VGAIN control voltage.
 *
 * Nominal slope is 25 mV/dB over a 0 dB to 60 dB range. With CR30, Bit 2 = 0
 * (positive slope) 0 V gives 0 dB and 1.5 V gives 60 dB; with Bit 2 = 1 the
 * mapping is reversed.
 *
 * Note that the 0.5 dB gain conformance error is only specified for VGAIN
 * between 200 mV and 1.3 V (roughly 8 dB to 52 dB); outside that window the
 * gain law bends.
 */
static uint16_t adrf6850_gain_to_mv(int32_t gain_mdb, uint8_t polarity)
{
    int32_t mv;

    if (gain_mdb < 0)      { gain_mdb = 0; }
    if (gain_mdb > 60000)  { gain_mdb = 60000; }

    mv = (gain_mdb * 25 + 500) / 1000;      /* 25 mV/dB, rounded */

    if (polarity != 0U) {
        mv = 1500 - mv;                     /* negative gain slope */
    }

    return (uint16_t)mv;
}

/* ------------------------------------------------------------------------
 * Lock detection
 * ---------------------------------------------------------------------- */

/**
 * @brief Wait for the PLL to lock.
 *
 * Polls LDET (Pin 40) until it goes high. If no LDET GPIO is available the
 * platform hook returns a negative value and a fixed 300 us delay is used
 * instead: frequency settling to a 1 kHz error is 260 us typical.
 */
adrf6850_status_t adrf6850_wait_lock(uint32_t timeout_us)
{
    int ldet;
    uint32_t elapsed = 0U;

    ldet = adrf6850_hw_ldet_read();
    if (ldet < 0) {
        usleep(300U);
        return ADRF6850_OK;
    }

    while (elapsed < timeout_us) {
        if (adrf6850_hw_ldet_read() > 0) {
            return ADRF6850_OK;
        }
        usleep(10U);
        elapsed += 10U;
    }

    return ADRF6850_ERR_LOCK;
}

/* ------------------------------------------------------------------------
 * Initialization
 * ---------------------------------------------------------------------- */

/**
 * @brief Full power-up of the ADRF6850 using the static configuration.
 *
 * Follows the "Initial Register Write Sequence" of the datasheet, from
 * CR30 down to CR0.
 *
 * @return ADRF6850_OK on success, ADRF6850_ERR_LOCK if the PLL never locked,
 *         or an error from the frequency planner.
 */
adrf6850_status_t adrf6850_init(void)
{
    adrf6850_status_t st;
    uint8_t  rfdiv;
    uint16_t n_int;
    uint32_t n_frac;
    uint32_t f_actual;
    uint16_t vgain_mv;

    st = adrf6850_calc_freq(ADRF6850_CFG_LO_HZ, &rfdiv, &n_int, &n_frac,
                            &f_actual);
    if (st != ADRF6850_OK) {
        return st;
    }

    vgain_mv = adrf6850_gain_to_mv(ADRF6850_CFG_GAIN_MDB,
                                   ADRF6850_CFG_VGA_POLARITY);

    /* Park VGAIN before the VGA is powered up. */
    adrf6850_hw_vgain_set_mv(adrf6850_gain_to_mv(0, ADRF6850_CFG_VGA_POLARITY));

    adrf6850_spi_lock();

    /*  1. CR30 = 0x00: VGA powered off and gain slope forced positive. */
    adrf6850_write_reg(ADRF6850_REG_CR30, 0x00U);

    /*  2. Demodulator on, baseband mode/filter, VOCM source. */
    adrf6850_write_reg(ADRF6850_REG_CR29,
                       (uint8_t)((ADRF6850_CFG_VOCM_INTERNAL << 6) |
                                 ((ADRF6850_CFG_BB_FC & 0x3U) << 4)  |
                                 ((ADRF6850_CFG_BB_WIDEBAND & 0x1U) << 3) |
                                 0x01U));

    /*  3. RFDIV from Table 6; Bit 3 must be set to 1. */
    adrf6850_write_reg(ADRF6850_REG_CR28, (uint8_t)(0x08U | (rfdiv & 0x07U)));

    /*  4. LO monitor outputs. */
    adrf6850_write_reg(ADRF6850_REG_CR27,
                       (uint8_t)(((ADRF6850_CFG_LOMON_EN & 0x1U) << 2) |
                                 (ADRF6850_CFG_LOMON_PWR & 0x3U)));

    /*  5..16. Reserved registers, values mandated by the data sheet. */
    adrf6850_write_reg(ADRF6850_REG_CR26, 0x00U);

    /*  6. Autocalibration timer, Equation 3 (0x70 = 100 us at 27 MHz PFD). */
    adrf6850_write_reg(ADRF6850_REG_CR25, ADRF6850_BSCDIV);

    /*  7. Autocalibration enabled (Bit 0 = 0). */
    adrf6850_write_reg(ADRF6850_REG_CR24, 0x38U);

    /*  8. Lock detector enabled, 3072 up/down pulses. */
    adrf6850_write_reg(ADRF6850_REG_CR23, 0x70U);

    adrf6850_write_reg(ADRF6850_REG_CR22, 0x00U);
    adrf6850_write_reg(ADRF6850_REG_CR21, 0x00U);
    adrf6850_write_reg(ADRF6850_REG_CR20, 0x00U);
    adrf6850_write_reg(ADRF6850_REG_CR19, 0x00U);
    adrf6850_write_reg(ADRF6850_REG_CR18, 0x60U);   
    adrf6850_write_reg(ADRF6850_REG_CR17, 0x00U);
    adrf6850_write_reg(ADRF6850_REG_CR16, 0x00U);
    adrf6850_write_reg(ADRF6850_REG_CR15, 0x00U);

    /* 17. Lock detector control 2: 2048/3072 pulse option. */
    adrf6850_write_reg(ADRF6850_REG_CR14, 0x00U);

    adrf6850_write_reg(ADRF6850_REG_CR13, 0x08U);  

    /* 19. PLL (and VCO) powered up. */
    adrf6850_write_reg(ADRF6850_REG_CR12, 0x18U);

    adrf6850_write_reg(ADRF6850_REG_CR11, 0x00U);

    /* 21. Reference path: doubler, divide-by-2, 5-bit R value. */
    adrf6850_write_reg(ADRF6850_REG_CR10,
                       (uint8_t)(((ADRF6850_CFG_REF_DIV2_EN & 0x1U) << 6) |
                                 ((ADRF6850_CFG_REF_DOUBLER_EN & 0x1U) << 5) |
                                 ((ADRF6850_CFG_REF_RDIV == 32) ? 0x00U :
                                  (ADRF6850_CFG_REF_RDIV & 0x1FU))));

    /* 22. Charge pump current (0x7 => 2.50 mA with RSET = 4.7 kOhm). */
    adrf6850_write_reg(ADRF6850_REG_CR9,
                       (uint8_t)((ADRF6850_CFG_CP_CODE & 0x0FU) << 4));

    adrf6850_write_reg(ADRF6850_REG_CR8, 0x00U);

    /* 24..25. Integer word: MUXOUT in CR7[7:4], INT[11:8] in CR7[3:0]. */
    adrf6850_write_reg(ADRF6850_REG_CR7,
                       (uint8_t)(((ADRF6850_CFG_MUXOUT & 0x0FU) << 4) |
                                 ((n_int >> 8) & 0x0FU)));
    adrf6850_write_reg(ADRF6850_REG_CR6, (uint8_t)(n_int & 0xFFU));

    /* 26. 5-bit reference divider enable. */
    adrf6850_write_reg(ADRF6850_REG_CR5,
                       (uint8_t)((ADRF6850_CFG_REF_RDIV_EN & 0x1U) << 4));

    adrf6850_write_reg(ADRF6850_REG_CR4, 0x01U);   

    /* 28..31. Fractional word, MSB first; CR0 last => starts acquisition. */
    adrf6850_write_reg(ADRF6850_REG_CR3, (uint8_t)((n_frac >> 24) & 0x01U));
    adrf6850_write_reg(ADRF6850_REG_CR2, (uint8_t)((n_frac >> 16) & 0xFFU));
    adrf6850_write_reg(ADRF6850_REG_CR1, (uint8_t)((n_frac >> 8) & 0xFFU));
    adrf6850_write_reg(ADRF6850_REG_CR0, (uint8_t)( n_frac & 0xFFU));

    /* 32. Wait for lock (260 us typical to a 1 kHz frequency error). */
    st = adrf6850_wait_lock(ADRF6850_CFG_LOCK_TIMEOUT_US);

    /* 33. Apply the operating gain and power up the VGA. */
    if (adrf6850_hw_vgain_set_mv(vgain_mv) != 0) {
        return ADRF6850_ERR_HW;
    }
    adrf6850_write_reg(ADRF6850_REG_CR30,
                       (uint8_t)((ADRF6850_CFG_VGA_POLARITY << 2) | 0x01U));

    g_dev.initialized = 1U;
    g_dev.lo_hz = ADRF6850_CFG_LO_HZ;
    g_dev.lo_actual_hz = f_actual;
    g_dev.rfdiv = rfdiv;
    g_dev.n_int = n_int;
    g_dev.n_frac = n_frac;
    g_dev.gain_mdb = ADRF6850_CFG_GAIN_MDB;
    g_dev.vgain_mv = vgain_mv;
    g_dev.bb_wideband = ADRF6850_CFG_BB_WIDEBAND;
    g_dev.bb_fc = (adrf6850_bb_fc_t)ADRF6850_CFG_BB_FC;
    g_dev.cp_code = ADRF6850_CFG_CP_CODE;
    g_dev.autocal_off = 0U;

    return st;
}

/* ------------------------------------------------------------------------
 * Runtime reconfiguration
 * ---------------------------------------------------------------------- */

/**
 * @brief Change the main operating parameters of an already-initialized part.
 *
 * Only the fields flagged in @c p->mask are touched. Ordering matters:
 *
 *   - CR29 (baseband filter), CR27 (LO monitor) and CR30 (VGA) are not
 *     double buffered and take effect immediately.
 *   - CR28 (RFDIV), CR9 (charge pump), CR7/CR6 (INT) and CR3..CR1 (FRAC) are
 *     double buffered: they are only latched when CR0 is written, which is
 *     therefore always the last write and triggers a new PLL acquisition.
 *
 * If @c fast_hop is set and the requested frequency step is 100 kHz or less,
 * autocalibration is disabled (CR24, Bit 0) for a significantly faster hop.
 * The 100 kHz limit is cumulative since the last calibrated frequency, so
 * the driver tracks the accumulated offset and re-enables autocalibration as
 * soon as it would be exceeded.
 *
 * @param p Parameter set. Must not be NULL.
 * @return ADRF6850_OK, or an error code.
 */
adrf6850_status_t adrf6850_update(const adrf6850_params_t *p)
{
    adrf6850_status_t st = ADRF6850_OK;
    uint8_t  need_cr0 = 0U;
    uint8_t  rfdiv    = g_dev.rfdiv;
    uint16_t n_int    = g_dev.n_int;
    uint32_t n_frac   = g_dev.n_frac;
    uint32_t f_actual = g_dev.lo_actual_hz;
    static uint32_t s_cal_ref_hz;      /* LO at the last autocalibration */

    if (p == (const adrf6850_params_t *)0) {
        return ADRF6850_ERR_PARAM;
    }
    if (g_dev.initialized == 0U) {
        return ADRF6850_ERR_STATE;
    }

    /* ---- Baseband path (immediate) ---------------------------------- */
    if ((p->mask & ADRF6850_UPD_BB) != 0U) {
        adrf6850_write_reg(ADRF6850_REG_CR29,
                           (uint8_t)((ADRF6850_CFG_VOCM_INTERNAL << 6) |
                                     (((uint8_t)p->bb_fc & 0x3U) << 4)  |
                                     ((p->bb_wideband & 0x1U) << 3)     |
                                     0x01U));
        g_dev.bb_wideband = (uint8_t)(p->bb_wideband & 0x1U);
        g_dev.bb_fc       = p->bb_fc;
    }

    /* ---- LO monitor outputs (immediate) ----------------------------- */
    if ((p->mask & ADRF6850_UPD_LOMON) != 0U) {
        adrf6850_write_reg(ADRF6850_REG_CR27,
                           (uint8_t)(((p->lomon_en & 0x1U) << 2) |
                                     ((uint8_t)p->lomon_pwr & 0x3U)));
    }

    /* ---- Charge pump current (double buffered) ---------------------- */
    if ((p->mask & ADRF6850_UPD_CP) != 0U) {
        if (p->cp_code > 0x0FU) {
            return ADRF6850_ERR_PARAM;
        }
        adrf6850_write_reg(ADRF6850_REG_CR9, (uint8_t)(p->cp_code << 4));
        g_dev.cp_code = p->cp_code;
        need_cr0 = 1U;
    }

    /* ---- LO frequency (double buffered) ----------------------------- */
    if ((p->mask & ADRF6850_UPD_LO) != 0U) {
        uint32_t step;
        uint8_t  use_fast;

        st = adrf6850_calc_freq(p->lo_hz, &rfdiv, &n_int, &n_frac, &f_actual);
        if (st != ADRF6850_OK) {
            return st;
        }

        /* Cumulative step since the last calibrated frequency. */
        step = (p->lo_hz > s_cal_ref_hz) ? (p->lo_hz - s_cal_ref_hz)
                                         : (s_cal_ref_hz - p->lo_hz);

        use_fast = (uint8_t)((p->fast_hop != 0U) &&
                             (rfdiv == g_dev.rfdiv) &&
                             (step <= 100000UL));

        if (use_fast && (g_dev.autocal_off == 0U)) {
            adrf6850_write_reg(ADRF6850_REG_CR24, 0x39U);   /* autocal off */
            g_dev.autocal_off = 1U;
        } else if (!use_fast && (g_dev.autocal_off != 0U)) {
            adrf6850_write_reg(ADRF6850_REG_CR24, 0x38U);   /* autocal on  */
            g_dev.autocal_off = 0U;
        }
        if (!use_fast) {
            s_cal_ref_hz = p->lo_hz;
        }

        adrf6850_write_reg(ADRF6850_REG_CR28,
                           (uint8_t)(0x08U | (rfdiv & 0x07U)));
        adrf6850_write_reg(ADRF6850_REG_CR7,
                           (uint8_t)(((ADRF6850_CFG_MUXOUT & 0x0FU) << 4) |
                                     ((n_int >> 8) & 0x0FU)));
        adrf6850_write_reg(ADRF6850_REG_CR6, (uint8_t)(n_int & 0xFFU));
        adrf6850_write_reg(ADRF6850_REG_CR3, (uint8_t)((n_frac >> 24) & 0x01U));
        adrf6850_write_reg(ADRF6850_REG_CR2, (uint8_t)((n_frac >> 16) & 0xFFU));
        adrf6850_write_reg(ADRF6850_REG_CR1, (uint8_t)((n_frac >>  8) & 0xFFU));

        need_cr0 = 1U;
    }

    /* ---- Latch double-buffered fields and re-acquire ---------------- */
    if (need_cr0 != 0U) {
        adrf6850_write_reg(ADRF6850_REG_CR0, (uint8_t)(n_frac & 0xFFU));

        g_dev.rfdiv        = rfdiv;
        g_dev.n_int        = n_int;
        g_dev.n_frac       = n_frac;
        g_dev.lo_actual_hz = f_actual;
        if ((p->mask & ADRF6850_UPD_LO) != 0U) {
            g_dev.lo_hz = p->lo_hz;
        }

        st = adrf6850_wait_lock(ADRF6850_CFG_LOCK_TIMEOUT_US);
        if (st != ADRF6850_OK) {
            return st;
        }
    }

    /* ---- VGA gain (analog, applied last so the RF path is settled) -- */
    if ((p->mask & ADRF6850_UPD_GAIN) != 0U) {
        uint16_t mv;

        if ((p->gain_mdb < 0) || (p->gain_mdb > 60000)) {
            return ADRF6850_ERR_PARAM;
        }
        mv = adrf6850_gain_to_mv(p->gain_mdb, ADRF6850_CFG_VGA_POLARITY);
        if (adrf6850_hw_vgain_set_mv(mv) != 0) {
            return ADRF6850_ERR_HW;
        }
        g_dev.gain_mdb = p->gain_mdb;
        g_dev.vgain_mv = mv;
    }

    return ADRF6850_OK;
}

/* ------------------------------------------------------------------------
 * Convenience wrappers
 * ---------------------------------------------------------------------- */

/** @brief Retune the LO, letting the part autocalibrate. */
adrf6850_status_t adrf6850_set_lo(uint32_t lo_hz)
{
    adrf6850_params_t p;

    p.mask = ADRF6850_UPD_LO;
    p.lo_hz = lo_hz;
    p.fast_hop = 0U;

    return adrf6850_update(&p);
}

/** @brief Set the VGA gain, in milli-dB (0 to 60000). */
adrf6850_status_t adrf6850_set_gain_mdb(int32_t gain_mdb)
{
    adrf6850_params_t p;

    p.mask = ADRF6850_UPD_GAIN;
    p.gain_mdb = gain_mdb;

    return adrf6850_update(&p);
}

/** @brief Select wideband mode, or narrow-band mode with a given corner. */
adrf6850_status_t adrf6850_set_baseband(uint8_t wideband, adrf6850_bb_fc_t fc)
{
    adrf6850_params_t p;

    p.mask = ADRF6850_UPD_BB;
    p.bb_wideband = wideband;
    p.bb_fc = fc;

    return adrf6850_update(&p);
}

/** @brief Enable or disable the LOMON outputs and set their level. */
adrf6850_status_t adrf6850_set_lo_monitor(uint8_t enable,
                                          adrf6850_lomon_pwr_t pwr)
{
    adrf6850_params_t p;

    p.mask = ADRF6850_UPD_LOMON;
    p.lomon_en = enable;
    p.lomon_pwr = pwr;

    return adrf6850_update(&p);
}

/** @brief Read-only view of the current device state. */
const adrf6850_state_t *adrf6850_get_state(void)
{
    return &g_dev;
}
