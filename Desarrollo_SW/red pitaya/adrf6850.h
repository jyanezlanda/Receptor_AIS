/**
 * @file    adrf6850.h
 * @brief   Bare-metal driver for the Analog Devices ADRF6850 broadband
 *          receiver (IQ demodulator + fractional-N PLL/VCO + VGA).
 *
 * Reference: ADRF6850 Data Sheet, Rev. A (7/2022).
 *
 * The driver talks to the device over the 3-wire SPI port (24-bit writes,
 * command byte 0xD4 / read command 0xD5). The part powers up in I2C mode,
 * so adrf6850_init() first issues the three CS pulses required to latch the
 * SPI protocol (Data Sheet, Figure 65).
 *
 * NOTE ON THE VGA GAIN: the VGA gain is *not* an SPI setting. It is an analog
 * control voltage applied to pin 43 (VGAIN), 0 V to 1.5 V, 25 mV/dB nominal.
 * The driver therefore only computes the required voltage and delegates the
 * actual output to the platform hook adrf6850_hw_vgain_set_mv(), which must
 * drive a DAC (or a filtered PWM) on the board.
 */

#ifndef ADRF6850_H
#define ADRF6850_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* =========================================================================
 * 1. STATIC CONFIGURATION - edit these to match the board
 * ========================================================================= */

/** Reference frequency present at the REFIN pin (Pin 17), in Hz. */
#define ADRF6850_REFIN_HZ               13500000UL

/** Reference doubler enable (CR10, Bit 5). 0 = off, 1 = on. */
#define ADRF6850_CFG_REF_DOUBLER_EN     1

/** Reference divide-by-2 enable (CR10, Bit 6). 0 = bypass, 1 = enable. */
#define ADRF6850_CFG_REF_DIV2_EN        0

/** 5-bit R-divider enable (CR5, Bit 4). 0 = bypass, 1 = enable. */
#define ADRF6850_CFG_REF_RDIV_EN        0

/** 5-bit R-divider ratio, 1 to 32. Only relevant if RDIV_EN == 1. */
#define ADRF6850_CFG_REF_RDIV           1

/** Default LO frequency after init, in Hz (100 MHz to 1000 MHz). */
#define ADRF6850_CFG_LO_HZ              330000000UL

/** Default VGA gain after init, in milli-dB (0 to 60000 => 0 dB to 60 dB). */
#define ADRF6850_CFG_GAIN_MDB           20000

/** VGA gain slope polarity (CR30, Bit 2). 0 = positive, 1 = negative. */
#define ADRF6850_CFG_VGA_POLARITY       0

/** Baseband path: 0 = narrow-band (filtered), 1 = wideband (filter bypassed). */
#define ADRF6850_CFG_BB_WIDEBAND        0

/** Narrow-band filter corner (CR29, Bits[5:4]): 0=50, 1=43, 2=37, 3=30 MHz. */
#define ADRF6850_CFG_BB_FC              ADRF6850_BB_FC_50MHZ

/** Baseband common-mode source (CR29, Bit 6). 1 = internal, 0 = external VOCM. */
#define ADRF6850_CFG_VOCM_INTERNAL      1

/** Charge pump current code (CR9, Bits[7:4]). 0x7 => 2.50 mA with RSET = 4.7 k. */
#define ADRF6850_CFG_CP_CODE            0x7U

/** Autocalibration time in microseconds. 100 us is the recommended value. */
#define ADRF6850_CFG_AUTOCAL_TIME_US    100U

/** LO monitor outputs (CR27, Bit 2): 0 = powered down, 1 = powered up. */
#define ADRF6850_CFG_LOMON_EN           0

/** LO monitor power (CR27, Bits[1:0]): 0=-24, 1=-18, 2=-12, 3=-6 dBm. */
#define ADRF6850_CFG_LOMON_PWR          0

/** MUXOUT control (CR7, Bits[7:4]). 0x0 = tri-state (diagnostic use only). */
#define ADRF6850_CFG_MUXOUT             0x0U

/** Lock timeout in microseconds when polling LDET. */
#define ADRF6850_CFG_LOCK_TIMEOUT_US    2000U

/* =========================================================================
 * 2. DERIVED COMPILE-TIME CONSTANTS
 * ========================================================================= */

#if ADRF6850_CFG_REF_RDIV_EN
#define ADRF6850_R_EFF                  ((uint32_t)ADRF6850_CFG_REF_RDIV)
#else
#define ADRF6850_R_EFF                  1UL
#endif

/** PFD frequency, Equation 1: fPFD = fREFIN * (1 + D) / (R * (1 + T)). */
#define ADRF6850_PFD_HZ \
    ((uint32_t)(((uint64_t)ADRF6850_REFIN_HZ * (1UL + ADRF6850_CFG_REF_DOUBLER_EN)) \
                / (ADRF6850_R_EFF * (1UL + ADRF6850_CFG_REF_DIV2_EN))))

/** Autocalibration timer, Equation 3: BSCDIV = tCAL * fPFD / 24, raw value. */
#define ADRF6850_BSCDIV_RAW \
    (((uint64_t)ADRF6850_PFD_HZ * ADRF6850_CFG_AUTOCAL_TIME_US) / 24000000ULL)

/** Autocalibration timer as written to CR25 (8-bit field). */
#define ADRF6850_BSCDIV                 ((uint8_t)ADRF6850_BSCDIV_RAW)

#if defined(__STDC_VERSION__) && (__STDC_VERSION__ >= 201112L)
_Static_assert(ADRF6850_PFD_HZ >= 10000000UL && ADRF6850_PFD_HZ <= 30000000UL,
               "PFD frequency out of the 10 MHz to 30 MHz specified range");
/* Checked on the raw value: casting to uint8_t first would silently wrap. */
_Static_assert(ADRF6850_BSCDIV_RAW >= 1 && ADRF6850_BSCDIV_RAW <= 255,
               "BSCDIV out of range: adjust ADRF6850_CFG_AUTOCAL_TIME_US");
_Static_assert(ADRF6850_CFG_GAIN_MDB >= 0 && ADRF6850_CFG_GAIN_MDB <= 60000,
               "VGA gain must be within 0 dB to 60 dB");
#endif

#define ADRF6850_LO_MIN_HZ              100000000UL
#define ADRF6850_LO_MAX_HZ              1000000000UL
#define ADRF6850_FRAC_MOD               (1UL << 25)     /* 25-bit fixed modulus */

/* =========================================================================
 * 3. REGISTER MAP (Data Sheet, Table 8)
 * ========================================================================= */

#define ADRF6850_REG_CR0                0x00U   /* Fractional word 4 (LSB)   */
#define ADRF6850_REG_CR1                0x01U   /* Fractional word 3         */
#define ADRF6850_REG_CR2                0x02U   /* Fractional word 2         */
#define ADRF6850_REG_CR3                0x03U   /* Fractional word 1 (MSB)   */
#define ADRF6850_REG_CR4                0x04U
#define ADRF6850_REG_CR5                0x05U   /* R-divider enable          */
#define ADRF6850_REG_CR6                0x06U   /* Integer word 2 (LSB)      */
#define ADRF6850_REG_CR7                0x07U   /* Integer word 1 + MUXOUT   */
#define ADRF6850_REG_CR8                0x08U
#define ADRF6850_REG_CR9                0x09U   /* Charge pump current       */
#define ADRF6850_REG_CR10               0x0AU   /* Reference frequency ctrl  */
#define ADRF6850_REG_CR11               0x0BU
#define ADRF6850_REG_CR12               0x0CU   /* PLL power-up              */
#define ADRF6850_REG_CR13               0x0DU
#define ADRF6850_REG_CR14               0x0EU   /* Lock detector control 2   */
#define ADRF6850_REG_CR15               0x0FU
#define ADRF6850_REG_CR16               0x10U
#define ADRF6850_REG_CR17               0x11U
#define ADRF6850_REG_CR18               0x12U
#define ADRF6850_REG_CR19               0x13U
#define ADRF6850_REG_CR20               0x14U
#define ADRF6850_REG_CR21               0x15U
#define ADRF6850_REG_CR22               0x16U
#define ADRF6850_REG_CR23               0x17U   /* Lock detector control 1   */
#define ADRF6850_REG_CR24               0x18U   /* Autocalibration           */
#define ADRF6850_REG_CR25               0x19U   /* Autocalibration timer     */
#define ADRF6850_REG_CR26               0x1AU
#define ADRF6850_REG_CR27               0x1BU   /* LO monitor output         */
#define ADRF6850_REG_CR28               0x1CU   /* LO selection (RFDIV)      */
#define ADRF6850_REG_CR29               0x1DU   /* Demod power + filters     */
#define ADRF6850_REG_CR30               0x1EU   /* VGA                       */
#define ADRF6850_REG_CR31               0x1FU   /* Read only                 */
#define ADRF6850_REG_CR32               0x20U   /* Read only                 */
#define ADRF6850_REG_CR33               0x21U   /* Revision code (read only) */

#define ADRF6850_SPI_CMD_WRITE          0xD4U
#define ADRF6850_SPI_CMD_READ           0xD5U

/* =========================================================================
 * 4. PUBLIC TYPES
 * ========================================================================= */

/** Narrow-band low-pass filter corner (CR29, Bits[5:4], Table 7). */
typedef enum {
    ADRF6850_BB_FC_50MHZ = 0,
    ADRF6850_BB_FC_43MHZ = 1,
    ADRF6850_BB_FC_37MHZ = 2,
    ADRF6850_BB_FC_30MHZ = 3
} adrf6850_bb_fc_t;

/** LO monitor output power (CR27, Bits[1:0]). */
typedef enum {
    ADRF6850_LOMON_M24DBM = 0,
    ADRF6850_LOMON_M18DBM = 1,
    ADRF6850_LOMON_M12DBM = 2,
    ADRF6850_LOMON_M6DBM  = 3
} adrf6850_lomon_pwr_t;

/** Return codes. */
typedef enum {
    ADRF6850_OK           =  0,
    ADRF6850_ERR_PARAM    = -1,   /**< Parameter out of range              */
    ADRF6850_ERR_RANGE    = -2,   /**< Resulting N-divider out of range    */
    ADRF6850_ERR_LOCK     = -3,   /**< PLL did not assert LDET in time     */
    ADRF6850_ERR_STATE    = -4,   /**< Driver not initialized              */
    ADRF6850_ERR_HW       = -5    /**< Platform hook reported a failure    */
} adrf6850_status_t;

/** Field selectors for adrf6850_update(). OR them together. */
#define ADRF6850_UPD_LO         (1U << 0)   /**< lo_hz                      */
#define ADRF6850_UPD_GAIN       (1U << 1)   /**< gain_mdb                   */
#define ADRF6850_UPD_BB         (1U << 2)   /**< bb_wideband + bb_fc        */
#define ADRF6850_UPD_LOMON      (1U << 3)   /**< lomon_en + lomon_pwr       */
#define ADRF6850_UPD_CP         (1U << 4)   /**< cp_code                    */
#define ADRF6850_UPD_ALL        (0x1FU)

/** Runtime parameter set. Only the fields flagged in @c mask are applied. */
typedef struct {
    uint32_t              mask;         /**< OR of ADRF6850_UPD_* flags     */
    uint32_t              lo_hz;        /**< LO frequency, 100e6 to 1000e6  */
    int32_t               gain_mdb;     /**< VGA gain in milli-dB, 0..60000 */
    uint8_t               bb_wideband;  /**< 0 = narrow-band, 1 = wideband  */
    adrf6850_bb_fc_t      bb_fc;        /**< Narrow-band corner frequency   */
    uint8_t               lomon_en;     /**< LO monitor power-up            */
    adrf6850_lomon_pwr_t  lomon_pwr;    /**< LO monitor output level        */
    uint8_t               cp_code;      /**< Charge pump code 0x0..0xF      */
    uint8_t               fast_hop;     /**< 1 = skip autocal if |df|<=100k */
} adrf6850_params_t;

/** Snapshot of the current device state maintained by the driver. */
typedef struct {
    uint8_t   initialized;
    uint32_t  lo_hz;        /**< Requested LO frequency                     */
    uint32_t  lo_actual_hz; /**< Frequency actually synthesized             */
    uint8_t   rfdiv;        /**< CR28[2:0]                                  */
    uint16_t  n_int;        /**< 12-bit INT                                 */
    uint32_t  n_frac;       /**< 25-bit FRAC                                */
    int32_t   gain_mdb;
    uint16_t  vgain_mv;
    uint8_t   bb_wideband;
    adrf6850_bb_fc_t bb_fc;
    uint8_t   cp_code;
    uint8_t   autocal_off;
} adrf6850_state_t;

/* =========================================================================
 * 5. PLATFORM HOOKS - implement these for your board
 * ========================================================================= */

/** Drive the CS pin. @param level 0 = low (asserted), 1 = high. */
void     adrf6850_hw_cs(uint8_t level);

/** Send @p len bytes MSB first on the SPI bus (CS handled by the caller). */
void     adrf6850_hw_spi_write(const uint8_t *buf, uint32_t len);

/** Receive @p len bytes MSB first on the SPI bus (CS handled by the caller). */
void     adrf6850_hw_spi_read(uint8_t *buf, uint32_t len);

/** Busy-wait for at least @p us microseconds. */
void     adrf6850_hw_delay_us(uint32_t us);

/**
 * Read the LDET pin (Pin 40).
 * @return 1 if locked, 0 if not locked, negative if no GPIO is wired
 *         (the driver then falls back to a fixed 300 us settling delay).
 */
int      adrf6850_hw_ldet_read(void);

/**
 * Apply @p mv millivolts to the VGAIN pin (Pin 43) through a DAC or PWM.
 * @return 0 on success, negative on failure.
 */
int      adrf6850_hw_vgain_set_mv(uint16_t mv);

/* =========================================================================
 * 6. PUBLIC API
 * ========================================================================= */

adrf6850_status_t adrf6850_init(void);
adrf6850_status_t adrf6850_update(const adrf6850_params_t *p);

/* Convenience wrappers built on adrf6850_update(). */
adrf6850_status_t adrf6850_set_lo(uint32_t lo_hz);
adrf6850_status_t adrf6850_set_gain_mdb(int32_t gain_mdb);
adrf6850_status_t adrf6850_set_baseband(uint8_t wideband, adrf6850_bb_fc_t fc);
adrf6850_status_t adrf6850_set_lo_monitor(uint8_t enable, adrf6850_lomon_pwr_t pwr);

/* Low-level helpers, exported for debug / CLI use. */
void              adrf6850_write_reg(uint8_t addr, uint8_t data);
uint8_t           adrf6850_read_reg(uint8_t addr);
const adrf6850_state_t *adrf6850_get_state(void);
adrf6850_status_t adrf6850_wait_lock(uint32_t timeout_us);

#ifdef __cplusplus
}
#endif

#endif /* ADRF6850_H */
