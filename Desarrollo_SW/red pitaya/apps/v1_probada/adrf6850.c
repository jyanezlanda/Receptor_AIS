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

/* Configuration given to adrf6850_init() and the PFD derived from it (Equation 1). */
static adrf6850_config_t g_cfg;
static uint32_t          g_pfd_hz;
static adrf6850_verify_stats_t g_vstats;

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
 * @brief Register readback (Data Sheet, Figure 67): a 16-bit write (0xD4 +
 *        address) selects the register; then CS is pulsed a second time for ONE
 *        16-bit frame: the read command 0xD5 and, in the same frame, the
 *        register contents clocked out on SDO.
 */
uint8_t adrf6850_read_reg(uint8_t addr)
{
    uint8_t sel[2];
    uint8_t tx[2];
    uint8_t rx[2] = { 0U, 0U };

    sel[0] = ADRF6850_SPI_CMD_WRITE;
    sel[1] = addr;
    adrf6850_hw_spi_write(sel, 2U);          /* 1st CS pulse: select the register */

    tx[0] = ADRF6850_SPI_CMD_READ;
    tx[1] = 0x00U;                           /* dummy: clocks the data out on SDO */
    adrf6850_hw_spi_xfer(tx, rx, 2U);        /* 2nd CS pulse: 0xD5 + data, one frame */

    return rx[1];
}

/**
 * @brief Register write with read-back verification.
 *
 * With verify_retries = 0 the register is only written. Otherwise it is read back and compared byte for byte
 * (reserved bits included); on a mismatch it is rewritten and re-read, at most verify_retries more times. If it still
 * does not match, the failure is recorded and ADRF6850_ERR_VERIFY is returned so the caller stops.
 */
static adrf6850_status_t adrf6850_write_verified(uint8_t addr, uint8_t data)
{
    uint8_t attempt;
    uint8_t got = 0U;

    adrf6850_write_reg(addr, data);
    if (g_cfg.verify_retries == 0U) {
        return ADRF6850_OK;
    }
    g_vstats.writes++;

    for (attempt = 0U; ; attempt++) {
        got = adrf6850_read_reg(addr);
        if (got == data) {
            return ADRF6850_OK;
        }
        if (attempt >= g_cfg.verify_retries) {
            break;
        }
        g_vstats.retries++;
        adrf6850_write_reg(addr, data);
    }

    g_vstats.failures++;
    g_vstats.fail_addr  = addr;
    g_vstats.fail_wrote = data;
    g_vstats.fail_read  = got;
    return ADRF6850_ERR_VERIFY;
}

/* Verified write used by init() and update(): returns from the calling function on failure. */
#define WR(addr, data)                                                          \
    do {                                                                        \
        adrf6850_status_t wr_st_ = adrf6850_write_verified((addr), (data));     \
        if (wr_st_ != ADRF6850_OK) {                                            \
            return wr_st_;                                                      \
        }                                                                       \
    } while (0)

void adrf6850_get_verify_stats(adrf6850_verify_stats_t *s)
{
    if (s != (adrf6850_verify_stats_t *)0) {
        *s = g_vstats;
    }
}

void adrf6850_clear_verify_stats(void)
{
    g_vstats.writes = 0U;
    g_vstats.retries = 0U;
    g_vstats.failures = 0U;
    g_vstats.fail_addr = 0U;
    g_vstats.fail_wrote = 0U;
    g_vstats.fail_read = 0U;
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
 * @param[in]  pfd_hz  PFD frequency in Hz (Equation 1).
 * @param[in]  lo_hz   Desired LO frequency in Hz.
 * @param[out] rfdiv   CR28[2:0] code.
 * @param[out] n_int   12-bit integer word.
 * @param[out] n_frac  25-bit fractional word.
 * @param[out] actual  Frequency actually synthesized, in Hz (may be NULL).
 * @return ADRF6850_OK, ADRF6850_ERR_PARAM or ADRF6850_ERR_RANGE.
 */
static adrf6850_status_t adrf6850_calc_freq(uint32_t  pfd_hz,
                                            uint32_t  lo_hz,
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
    q25 += (uint64_t)(pfd_hz / 2U);                 /* round to nearest */
    q25 /= (uint64_t)pfd_hz;

    *n_int  = (uint16_t)(q25 >> 25);
    *n_frac = (uint32_t)(q25 & (ADRF6850_FRAC_MOD - 1UL));
    *rfdiv  = d;

    /* The RF fractional-N divider supports ratios from 23 to 4095. */
    if ((*n_int < 23U) || (*n_int > 4095U)) {
        return ADRF6850_ERR_RANGE;
    }

    if (actual != (uint32_t *)0) {
        uint64_t f = (uint64_t)pfd_hz * q25;
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
 * @brief Check a configuration and derive the PFD frequency and the autocalibration
 *        timer from it (Equations 1 and 3). Same limits the old compile-time
 *        static asserts enforced, now checked at run time.
 */
static adrf6850_status_t adrf6850_check_cfg(const adrf6850_config_t *c,
                                            uint32_t *pfd_hz, uint8_t *bscdiv)
{
    uint64_t pfd;
    uint64_t raw;
    uint32_t r_eff;

    if (c == (const adrf6850_config_t *)0) {
        return ADRF6850_ERR_PARAM;
    }
    if ((c->refin_hz == 0U) ||
        (c->ref_doubler_en > 1U) || (c->ref_div2_en > 1U) || (c->ref_rdiv_en > 1U) ||
        (c->vocm_internal > 1U)  || (c->vga_polarity > 1U) ||
        (c->bb_wideband > 1U)    || (c->lomon_en > 1U) ||
        (c->muxout > 0x0FU)      || (c->cp_code > 0x0FU) ||
        ((unsigned)c->bb_fc > 3U) || ((unsigned)c->lomon_pwr > 3U) ||
        (c->gain_mdb < 0)        || (c->gain_mdb > 60000) ||
        (c->verify_retries > 3U)) {
        return ADRF6850_ERR_PARAM;
    }
    if ((c->ref_rdiv_en != 0U) && ((c->ref_rdiv < 1U) || (c->ref_rdiv > 32U))) {
        return ADRF6850_ERR_PARAM;
    }

    /* Equation 1: fPFD = fREFIN * (1 + D) / (R * (1 + T)); 10 MHz to 30 MHz. */
    r_eff = (c->ref_rdiv_en != 0U) ? (uint32_t)c->ref_rdiv : 1UL;
    pfd = ((uint64_t)c->refin_hz * (1UL + c->ref_doubler_en)) /
          ((uint64_t)r_eff * (1UL + c->ref_div2_en));
    if ((pfd < 10000000ULL) || (pfd > 30000000ULL)) {
        return ADRF6850_ERR_PARAM;
    }

    /* Equation 3: BSCDIV = tCAL * fPFD / 24 MHz. Checked on the raw value:
     * casting to uint8_t first would silently wrap. */
    raw = (pfd * c->autocal_time_us) / 24000000ULL;
    if ((raw < 1U) || (raw > 255U)) {
        return ADRF6850_ERR_PARAM;
    }

    *pfd_hz = (uint32_t)pfd;
    *bscdiv = (uint8_t)raw;
    return ADRF6850_OK;
}

adrf6850_status_t adrf6850_validate_config(const adrf6850_config_t *cfg)
{
    uint32_t pfd_hz;
    uint8_t  bscdiv;
    uint8_t  rfdiv;
    uint16_t n_int;
    uint32_t n_frac;
    adrf6850_status_t st = adrf6850_check_cfg(cfg, &pfd_hz, &bscdiv);

    if (st != ADRF6850_OK) {
        return st;
    }
    return adrf6850_calc_freq(pfd_hz, cfg->lo_hz, &rfdiv, &n_int, &n_frac, (uint32_t *)0);
}

/**
 * @brief Full power-up of the ADRF6850 with the configuration given.
 *
 * Follows the "Initial Register Write Sequence" of the datasheet, from
 * CR30 down to CR0. The driver keeps NO defaults of its own: if the
 * configuration is invalid it returns ADRF6850_ERR_PARAM (or ERR_RANGE for a
 * LO the divider cannot reach) before touching the part or its state.
 *
 * @return ADRF6850_OK on success, ADRF6850_ERR_LOCK if the PLL never locked,
 *         or an error from the validation / frequency planner.
 */
adrf6850_status_t adrf6850_init(const adrf6850_config_t *cfg)
{
    adrf6850_status_t st;
    uint32_t pfd_hz;
    uint8_t  bscdiv;
    uint8_t  rfdiv;
    uint16_t n_int;
    uint32_t n_frac;
    uint32_t f_actual;
    uint16_t vgain_mv;

    st = adrf6850_check_cfg(cfg, &pfd_hz, &bscdiv);
    if (st != ADRF6850_OK) {
        return st;
    }
    st = adrf6850_calc_freq(pfd_hz, cfg->lo_hz, &rfdiv, &n_int, &n_frac, &f_actual);
    if (st != ADRF6850_OK) {
        return st;
    }

    /* Valid: commit the configuration. The driver stays "not initialized" until every write has gone through. */
    g_cfg    = *cfg;
    g_pfd_hz = pfd_hz;
    g_dev.initialized = 0U;
    adrf6850_clear_verify_stats();

    vgain_mv = adrf6850_gain_to_mv(g_cfg.gain_mdb, g_cfg.vga_polarity);

    /* Park VGAIN at minimum gain before the VGA is powered up. */
    adrf6850_hw_vgain_set_mv(adrf6850_gain_to_mv(0, g_cfg.vga_polarity));

    adrf6850_spi_lock();

    /*  1. CR30 = 0x00: VGA powered off and gain slope forced positive. */
    WR(ADRF6850_REG_CR30, 0x00U);

    /*  2. Demodulator on, baseband mode/filter, VOCM source. */
    WR(ADRF6850_REG_CR29,
       (uint8_t)((g_cfg.vocm_internal << 6) |
                 (((uint8_t)g_cfg.bb_fc & 0x3U) << 4) |
                 ((g_cfg.bb_wideband & 0x1U) << 3) |
                 0x01U));

    /*  3. RFDIV from Table 6; Bit 3 must be set to 1. */
    WR(ADRF6850_REG_CR28, (uint8_t)(0x08U | (rfdiv & 0x07U)));

    /*  4. LO monitor outputs. */
    WR(ADRF6850_REG_CR27,
       (uint8_t)(((g_cfg.lomon_en & 0x1U) << 2) |
                 ((uint8_t)g_cfg.lomon_pwr & 0x3U)));

    /*  5..16. Reserved registers, values mandated by the data sheet. */
    WR(ADRF6850_REG_CR26, 0x00U);

    /*  6. Autocalibration timer, Equation 3 (0x70 = 100 us at 27 MHz PFD). */
    WR(ADRF6850_REG_CR25, bscdiv);

    /*  7. Autocalibration enabled (Bit 0 = 0). */
    WR(ADRF6850_REG_CR24, 0x38U);

    /*  8. Lock detector enabled, 3072 up/down pulses. */
    WR(ADRF6850_REG_CR23, 0x70U);

    WR(ADRF6850_REG_CR22, 0x00U);
    WR(ADRF6850_REG_CR21, 0x00U);
    WR(ADRF6850_REG_CR20, 0x00U);
    WR(ADRF6850_REG_CR19, 0x00U);
    WR(ADRF6850_REG_CR18, 0x60U);
    WR(ADRF6850_REG_CR17, 0x00U);
    WR(ADRF6850_REG_CR16, 0x00U);
    WR(ADRF6850_REG_CR15, 0x00U);

    /* 17. Lock detector control 2: 2048/3072 pulse option. */
    WR(ADRF6850_REG_CR14, 0x00U);

    WR(ADRF6850_REG_CR13, 0x08U);

    /* 19. PLL (and VCO) powered up. */
    WR(ADRF6850_REG_CR12, 0x18U);

    WR(ADRF6850_REG_CR11, 0x00U);

    /* 21. Reference path: doubler, divide-by-2, 5-bit R value. */
    WR(ADRF6850_REG_CR10,
       (uint8_t)(((g_cfg.ref_div2_en & 0x1U) << 6) |
                 ((g_cfg.ref_doubler_en & 0x1U) << 5) |
                 ((g_cfg.ref_rdiv == 32U) ? 0x00U :
                  (g_cfg.ref_rdiv & 0x1FU))));

    /* 22. Charge pump current (0x7 => 2.50 mA with RSET = 4.7 kOhm). */
    WR(ADRF6850_REG_CR9,
       (uint8_t)((g_cfg.cp_code & 0x0FU) << 4));

    WR(ADRF6850_REG_CR8, 0x00U);

    /* 24..25. Integer word: MUXOUT in CR7[7:4], INT[11:8] in CR7[3:0]. */
    WR(ADRF6850_REG_CR7,
       (uint8_t)(((g_cfg.muxout & 0x0FU) << 4) |
                 ((n_int >> 8) & 0x0FU)));
    WR(ADRF6850_REG_CR6, (uint8_t)(n_int & 0xFFU));

    /* 26. 5-bit reference divider enable. */
    WR(ADRF6850_REG_CR5,
       (uint8_t)((g_cfg.ref_rdiv_en & 0x1U) << 4));

    WR(ADRF6850_REG_CR4, 0x01U);

    /* 28..31. Fractional word, MSB first; CR0 last => starts acquisition. */
    WR(ADRF6850_REG_CR3, (uint8_t)((n_frac >> 24) & 0x01U));
    WR(ADRF6850_REG_CR2, (uint8_t)((n_frac >> 16) & 0xFFU));
    WR(ADRF6850_REG_CR1, (uint8_t)((n_frac >> 8) & 0xFFU));
    WR(ADRF6850_REG_CR0, (uint8_t)( n_frac & 0xFFU));

    /* 32. Wait for lock (260 us typical to a 1 kHz frequency error). */
    st = adrf6850_wait_lock(g_cfg.lock_timeout_us);

    /* 33. Apply the operating gain and power up the VGA. */
    if (adrf6850_hw_vgain_set_mv(vgain_mv) != 0) {
        return ADRF6850_ERR_HW;
    }
    WR(ADRF6850_REG_CR30,
       (uint8_t)((g_cfg.vga_polarity << 2) | 0x01U));

    g_dev.initialized = 1U;
    g_dev.lo_hz = g_cfg.lo_hz;
    g_dev.lo_actual_hz = f_actual;
    g_dev.rfdiv = rfdiv;
    g_dev.n_int = n_int;
    g_dev.n_frac = n_frac;
    g_dev.gain_mdb = g_cfg.gain_mdb;
    g_dev.vgain_mv = vgain_mv;
    g_dev.bb_wideband = g_cfg.bb_wideband;
    g_dev.bb_fc = g_cfg.bb_fc;
    g_dev.cp_code = g_cfg.cp_code;
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
        WR(ADRF6850_REG_CR29,
           (uint8_t)((g_cfg.vocm_internal << 6) |
                     (((uint8_t)p->bb_fc & 0x3U) << 4)  |
                     ((p->bb_wideband & 0x1U) << 3)     |
                     0x01U));
        g_dev.bb_wideband = (uint8_t)(p->bb_wideband & 0x1U);
        g_dev.bb_fc       = p->bb_fc;
    }

    /* ---- LO monitor outputs (immediate) ----------------------------- */
    if ((p->mask & ADRF6850_UPD_LOMON) != 0U) {
        WR(ADRF6850_REG_CR27,
           (uint8_t)(((p->lomon_en & 0x1U) << 2) |
                     ((uint8_t)p->lomon_pwr & 0x3U)));
    }

    /* ---- Charge pump current (double buffered) ---------------------- */
    if ((p->mask & ADRF6850_UPD_CP) != 0U) {
        if (p->cp_code > 0x0FU) {
            return ADRF6850_ERR_PARAM;
        }
        WR(ADRF6850_REG_CR9, (uint8_t)(p->cp_code << 4));
        g_dev.cp_code = p->cp_code;
        need_cr0 = 1U;
    }

    /* ---- LO frequency (double buffered) ----------------------------- */
    if ((p->mask & ADRF6850_UPD_LO) != 0U) {
        uint32_t step;
        uint8_t  use_fast;

        st = adrf6850_calc_freq(g_pfd_hz, p->lo_hz, &rfdiv, &n_int, &n_frac, &f_actual);
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
            WR(ADRF6850_REG_CR24, 0x39U);   /* autocal off */
            g_dev.autocal_off = 1U;
        } else if (!use_fast && (g_dev.autocal_off != 0U)) {
            WR(ADRF6850_REG_CR24, 0x38U);   /* autocal on  */
            g_dev.autocal_off = 0U;
        }
        if (!use_fast) {
            s_cal_ref_hz = p->lo_hz;
        }

        WR(ADRF6850_REG_CR28,
           (uint8_t)(0x08U | (rfdiv & 0x07U)));
        WR(ADRF6850_REG_CR7,
           (uint8_t)(((g_cfg.muxout & 0x0FU) << 4) |
                     ((n_int >> 8) & 0x0FU)));
        WR(ADRF6850_REG_CR6, (uint8_t)(n_int & 0xFFU));
        WR(ADRF6850_REG_CR3, (uint8_t)((n_frac >> 24) & 0x01U));
        WR(ADRF6850_REG_CR2, (uint8_t)((n_frac >> 16) & 0xFFU));
        WR(ADRF6850_REG_CR1, (uint8_t)((n_frac >>  8) & 0xFFU));

        need_cr0 = 1U;
    }

    /* ---- Latch double-buffered fields and re-acquire ---------------- */
    if (need_cr0 != 0U) {
        WR(ADRF6850_REG_CR0, (uint8_t)(n_frac & 0xFFU));

        g_dev.rfdiv        = rfdiv;
        g_dev.n_int        = n_int;
        g_dev.n_frac       = n_frac;
        g_dev.lo_actual_hz = f_actual;
        if ((p->mask & ADRF6850_UPD_LO) != 0U) {
            g_dev.lo_hz = p->lo_hz;
        }

        st = adrf6850_wait_lock(g_cfg.lock_timeout_us);
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
        mv = adrf6850_gain_to_mv(p->gain_mdb, g_cfg.vga_polarity);
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
