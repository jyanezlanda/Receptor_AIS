
//------------------------------------------------------------------------------
// (c) Copyright 2023 Advanced Micro Devices. All rights reserved.
//
// This file contains confidential and proprietary information
// of AMD, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// AMD, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND AMD HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) AMD shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or AMD had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// AMD products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of AMD products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//------------------------------------------------------------------------------ 
//
// C Model configuration for the "system_fir_0_2" instance.
//
//------------------------------------------------------------------------------
//
// coefficients: 1.1896509788e-07,6.9660228675e-05,1.8425018915e-04,3.2960570394e-04,4.7279860336e-04,5.6454358018e-04,5.4730828786e-04,3.6883610405e-04,-9.5501433577e-07,-5.5323682079e-04,-1.2281903741e-03,-1.9121033747e-03,-2.4470597682e-03,-2.6544152007e-03,-2.3702213517e-03,-1.4874792911e-03,2.7116524257e-06,1.9806444192e-03,4.1874630308e-03,6.2416178231e-03,7.6850822476e-03,8.0564557276e-03,6.9820306278e-03,4.2706497456e-03,-5.0750014526e-06,-5.4589249828e-03,-1.1387267116e-02,-1.6819594829e-02,-2.0623007315e-02,-2.1650489475e-02,-1.8913867874e-02,-1.1755829839e-02,7.1619023374e-06,1.5997042827e-02,3.5260495169e-02,5.6337852597e-02,7.7410091897e-02,9.6506595624e-02,1.1174577702e-01,1.2157425767e-01,1.2496933198e-01,1.2157425767e-01,1.1174577702e-01,9.6506595624e-02,7.7410091897e-02,5.6337852597e-02,3.5260495169e-02,1.5997042827e-02,7.1619023374e-06,-1.1755829839e-02,-1.8913867874e-02,-2.1650489475e-02,-2.0623007315e-02,-1.6819594829e-02,-1.1387267116e-02,-5.4589249828e-03,-5.0750014526e-06,4.2706497456e-03,6.9820306278e-03,8.0564557276e-03,7.6850822476e-03,6.2416178231e-03,4.1874630308e-03,1.9806444192e-03,2.7116524257e-06,-1.4874792911e-03,-2.3702213517e-03,-2.6544152007e-03,-2.4470597682e-03,-1.9121033747e-03,-1.2281903741e-03,-5.5323682079e-04,-9.5501433577e-07,3.6883610405e-04,5.4730828786e-04,5.6454358018e-04,4.7279860336e-04,3.2960570394e-04,1.8425018915e-04,6.9660228675e-05,1.1896509788e-07
// chanpats: 173
// name: system_fir_0_2
// data_coefficient_type: 0
// filter_type: 0
// rate_change: 0
// interp_rate: 1
// decim_rate: 1
// zero_pack_factor: 1
// coeff_padding: 0
// num_coeffs: 81
// coeff_sets: 1
// reloadable: 0
// is_halfband: 0
// quantization: 1
// coeff_width: 24
// coeff_fract_width: 26
// chan_seq: 0
// num_channels: 1
// num_paths: 1
// data_width: 32
// data_fract_width: 0
// output_rounding_mode: 4
// output_width: 32
// accum_width: 59
// output_fract_width: 0
// config_method: 0

const double system_fir_0_2_coefficients[81] = {1.1896509788e-07,6.9660228675e-05,1.8425018915e-04,3.2960570394e-04,4.7279860336e-04,5.6454358018e-04,5.4730828786e-04,3.6883610405e-04,-9.5501433577e-07,-5.5323682079e-04,-1.2281903741e-03,-1.9121033747e-03,-2.4470597682e-03,-2.6544152007e-03,-2.3702213517e-03,-1.4874792911e-03,2.7116524257e-06,1.9806444192e-03,4.1874630308e-03,6.2416178231e-03,7.6850822476e-03,8.0564557276e-03,6.9820306278e-03,4.2706497456e-03,-5.0750014526e-06,-5.4589249828e-03,-1.1387267116e-02,-1.6819594829e-02,-2.0623007315e-02,-2.1650489475e-02,-1.8913867874e-02,-1.1755829839e-02,7.1619023374e-06,1.5997042827e-02,3.5260495169e-02,5.6337852597e-02,7.7410091897e-02,9.6506595624e-02,1.1174577702e-01,1.2157425767e-01,1.2496933198e-01,1.2157425767e-01,1.1174577702e-01,9.6506595624e-02,7.7410091897e-02,5.6337852597e-02,3.5260495169e-02,1.5997042827e-02,7.1619023374e-06,-1.1755829839e-02,-1.8913867874e-02,-2.1650489475e-02,-2.0623007315e-02,-1.6819594829e-02,-1.1387267116e-02,-5.4589249828e-03,-5.0750014526e-06,4.2706497456e-03,6.9820306278e-03,8.0564557276e-03,7.6850822476e-03,6.2416178231e-03,4.1874630308e-03,1.9806444192e-03,2.7116524257e-06,-1.4874792911e-03,-2.3702213517e-03,-2.6544152007e-03,-2.4470597682e-03,-1.9121033747e-03,-1.2281903741e-03,-5.5323682079e-04,-9.5501433577e-07,3.6883610405e-04,5.4730828786e-04,5.6454358018e-04,4.7279860336e-04,3.2960570394e-04,1.8425018915e-04,6.9660228675e-05,1.1896509788e-07};

const xip_fir_v7_2_pattern system_fir_0_2_chanpats[1] = {P_BASIC};

static xip_fir_v7_2_config gen_system_fir_0_2_config() {
  xip_fir_v7_2_config config;
  config.name                = "system_fir_0_2";
  config.data_coefficient_type = XIP_FIR_REAL_TYPE;
  config.filter_type         = 0;
  config.rate_change         = XIP_FIR_INTEGER_RATE;
  config.interp_rate         = 1;
  config.decim_rate          = 1;
  config.zero_pack_factor    = 1;
  config.coeff               = &system_fir_0_2_coefficients[0];
  config.coeff_padding       = 0;
  config.num_coeffs          = 81;
  config.coeff_sets          = 1;
  config.reloadable          = 0;
  config.is_halfband         = 0;
  config.quantization        = XIP_FIR_QUANTIZED_ONLY;
  config.coeff_width         = 24;
  config.coeff_fract_width   = 26;
  config.chan_seq            = XIP_FIR_BASIC_CHAN_SEQ;
  config.num_channels        = 1;
  config.init_pattern        = system_fir_0_2_chanpats[0];
  config.num_paths           = 1;
  config.data_width          = 32;
  config.data_fract_width    = 0;
  config.output_rounding_mode= XIP_FIR_CONVERGENT_EVEN;
  config.output_width        = 32;
  config.accum_width         = 59;
  config.output_fract_width  = 0;
  config.config_method       = XIP_FIR_CONFIG_SINGLE;
  return config;
}

const xip_fir_v7_2_config system_fir_0_2_config = gen_system_fir_0_2_config();

