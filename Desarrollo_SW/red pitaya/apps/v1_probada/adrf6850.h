/**
 * @file    adrf6850.h
 * @brief   Bare-metal driver for the Analog Devices ADRF6850 broadband
 *          receiver (IQ demodulator + fractional-N PLL/VCO + VGA).
 *
 * Reference: ADRF6850 Data Sheet, Rev. A (7/2022).
 *
 * The driver talks to the device over the 4-wire SPI port (CS, CLK, SDI and
 * SDO): 24-bit writes with command byte 0xD4, and 16-bit register reads with
 * read command 0xD5 (data out on SDO). The part powers up in I2C mode,
 * so adrf6850_init() first issues the three CS pulses required to latch the
 * SPI protocol (Data Sheet, Figure 65).
 *
 */

#ifndef ADRF6850_H
#define ADRF6850_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* =========================================================================
 * 1. CONFIGURATION
 *
 * The driver has NO built-in defaults: everything it needs is passed to
 * adrf6850_init() in an adrf6850_config_t (section 3). In this project
 * adrf6850_conf.c fills it from adrf6850.conf, which documents each value and
 * flags the ones the board hardware imposes.
 * ========================================================================= */

/* Limits of the part (Data Sheet). */
#define ADRF6850_LO_MIN_HZ              100000000UL
#define ADRF6850_LO_MAX_HZ              1000000000UL
#define ADRF6850_FRAC_MOD               (1UL << 25)     /* 25-bit fixed modulus */

/* =========================================================================
 * 2. REGISTER MAP (Data Sheet, Table 8)
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
 * 3. PUBLIC TYPES
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
    ADRF6850_ERR_HW       = -5,   /**< Platform hook reported a failure    */
    ADRF6850_ERR_VERIFY   = -6    /**< A register did not read back as written, even after the retries */
} adrf6850_status_t;

/** Field selectors for adrf6850_update(). OR them together. */
#define ADRF6850_UPD_LO         (1U << 0)   /**< lo_hz                      */
#define ADRF6850_UPD_GAIN       (1U << 1)   /**< gain_mdb                   */
#define ADRF6850_UPD_BB         (1U << 2)   /**< bb_wideband + bb_fc        */
#define ADRF6850_UPD_LOMON      (1U << 3)   /**< lomon_en + lomon_pwr       */
#define ADRF6850_UPD_CP         (1U << 4)   /**< cp_code                    */
#define ADRF6850_UPD_ALL        (0x1FU)

/**
 * Everything adrf6850_init() needs. The driver validates it (adrf6850_init()
 * returns ADRF6850_ERR_PARAM without touching the part if anything is out of
 * range): PFD between 10 and 30 MHz, autocalibration timer between 1 and 255,
 * gain 0..60000 mdB, LO 100..1000 MHz, flags 0/1, cp_code and muxout 0..15,
 * verify_retries 0..3.
 */
typedef struct {
    /* --- board: fixed by the hardware design --- */
    uint32_t              refin_hz;         /**< frequency at REFIN (Pin 17), Hz        */
    uint8_t               ref_doubler_en;   /**< CR10 bit 5: reference doubler          */
    uint8_t               ref_div2_en;      /**< CR10 bit 6: reference divide-by-2      */
    uint8_t               ref_rdiv_en;      /**< CR5 bit 4: 5-bit R divider enable      */
    uint8_t               ref_rdiv;         /**< R divider 1..32 (used if ref_rdiv_en)  */
    uint8_t               vocm_internal;    /**< CR29 bit 6: 1 = internal common mode   */
    uint8_t               vga_polarity;     /**< CR30 bit 2: 0 = positive gain slope    */
    uint8_t               muxout;           /**< CR7[7:4]: MUXOUT control               */
    uint32_t              autocal_time_us;  /**< autocalibration time (-> CR25)         */
    uint32_t              lock_timeout_us;  /**< LDET polling timeout (if LDET wired)   */
    /* --- operating point after init --- */
    uint32_t              lo_hz;            /**< LO frequency, 100e6 to 1000e6          */
    int32_t               gain_mdb;         /**< VGA gain in milli-dB, 0..60000         */
    uint8_t               bb_wideband;      /**< 0 = narrow-band, 1 = wideband          */
    adrf6850_bb_fc_t      bb_fc;            /**< narrow-band corner frequency           */
    uint8_t               cp_code;          /**< charge pump code 0x0..0xF              */
    uint8_t               lomon_en;         /**< LO monitor power-up                    */
    adrf6850_lomon_pwr_t  lomon_pwr;        /**< LO monitor output level                */
    /* --- link --- */
    uint8_t               verify_retries;   /**< 0 = write only (SDO not needed). 1..3 = after every register
                                                 write, read it back; if it differs, write it again and re-read,
                                                 at most this many times (then ADRF6850_ERR_VERIFY)          */
} adrf6850_config_t;

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

/** Link health, counted over the verified writes since the last adrf6850_clear_verify_stats(). */
typedef struct {
    uint32_t writes;       /**< register writes that were verified                          */
    uint32_t retries;      /**< extra attempts needed: each one is a link error that was caught */
    uint32_t failures;     /**< writes that still did not verify after every retry          */
    uint8_t  fail_addr;    /**< last failure: register ...                                  */
    uint8_t  fail_wrote;   /**< ... value written ...                                       */
    uint8_t  fail_read;    /**< ... value read back                                         */
} adrf6850_verify_stats_t;

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
 * 4. PLATFORM HOOKS - implement these for your board
 * ========================================================================= */

/** Send @p len bytes MSB first on the SPI bus (CS handled by spidev). */
void adrf6850_hw_spi_write(const uint8_t *buf, uint32_t len);

/**
 * Full-duplex SPI transfer: shift out @p tx[0..len) and capture @p rx[0..len)
 * in the same transfer, with CS low for the whole transfer (one spidev message
 * does exactly that). A register read needs it: the data comes out on SDO in
 * the same frame as the 0xD5 command (Data Sheet, Figure 67).
 */
void adrf6850_hw_spi_xfer(const uint8_t *tx, uint8_t *rx, uint32_t len);

/**
 * Read the LDET pin (Pin 40).
 * @return 1 if locked, 0 if not locked, negative if no GPIO is wired
 *         (the driver then falls back to a fixed 300 us settling delay).
 */
int adrf6850_hw_ldet_read(void);

/**
 * Apply @p mv millivolts to the VGAIN pin (Pin 43) through a DAC or PWM.
 * @return 0 on success, negative on failure.
 */
int adrf6850_hw_vgain_set_mv(uint16_t mv);

/* =========================================================================
 * 5. PUBLIC API
 * ========================================================================= */

/** Check a configuration exactly as adrf6850_init() does, without touching the part. */
adrf6850_status_t adrf6850_validate_config(const adrf6850_config_t *cfg);

/** Full power-up with the given configuration (validated; see adrf6850_config_t). */
adrf6850_status_t adrf6850_init(const adrf6850_config_t *cfg);
adrf6850_status_t adrf6850_update(const adrf6850_params_t *p);

/* Convenience wrappers built on adrf6850_update(). */
adrf6850_status_t adrf6850_set_lo(uint32_t lo_hz);
adrf6850_status_t adrf6850_set_gain_mdb(int32_t gain_mdb);
adrf6850_status_t adrf6850_set_baseband(uint8_t wideband, adrf6850_bb_fc_t fc);
adrf6850_status_t adrf6850_set_lo_monitor(uint8_t enable, adrf6850_lomon_pwr_t pwr);

/* Low-level helpers for debug. adrf6850_write_reg() is the RAW write: it never verifies. init() and update()
 * use the verified write internally. */
void adrf6850_write_reg(uint8_t addr, uint8_t data);
/* Register readback over SDO (CR0..CR33). Needs the 4-wire SPI with SDO wired.
 * While the part is still in I2C mode, the two frames count as CS pulses of the
 * SPI selection and the returned value is meaningless. */
uint8_t adrf6850_read_reg(uint8_t addr);
const adrf6850_state_t *adrf6850_get_state(void);
/* Write-verify statistics (see adrf6850_config_t.verify_retries). */
void adrf6850_get_verify_stats(adrf6850_verify_stats_t *s);
void adrf6850_clear_verify_stats(void);
adrf6850_status_t adrf6850_wait_lock(uint32_t timeout_us);

#ifdef __cplusplus
}
#endif

#endif /* ADRF6850_H */
