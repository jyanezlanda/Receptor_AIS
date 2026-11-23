
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
// C Model configuration for the "system_fir_compiler_0_0" instance.
//
//------------------------------------------------------------------------------
//
// coefficients: -1.8496877595e-04,-3.1966502107e-04,-3.9983572604e-04,-3.3380304983e-04,5.2790132615e-07,7.4938218967e-04,2.0714362252e-03,4.1213150936e-03,7.0296910521e-03,1.0882164433e-02,1.5699626911e-02,2.1422977056e-02,2.7904815002e-02,3.4910084326e-02,4.2126619127e-02,4.9185317972e-02,5.5688373221e-02,6.1242822589e-02,6.5495838016e-02,6.8167763599e-02,6.9079035719e-02,6.8167763599e-02,6.5495838016e-02,6.1242822589e-02,5.5688373221e-02,4.9185317972e-02,4.2126619127e-02,3.4910084326e-02,2.7904815002e-02,2.1422977056e-02,1.5699626911e-02,1.0882164433e-02,7.0296910521e-03,4.1213150936e-03,2.0714362252e-03,7.4938218967e-04,5.2790132615e-07,-3.3380304983e-04,-3.9983572604e-04,-3.1966502107e-04,-1.8496877595e-04
// chanpats: 173
// name: system_fir_compiler_0_0
// data_coefficient_type: 0
// filter_type: 0
// rate_change: 0
// interp_rate: 1
// decim_rate: 1
// zero_pack_factor: 1
// coeff_padding: 0
// num_coeffs: 41
// coeff_sets: 1
// reloadable: 0
// is_halfband: 0
// quantization: 1
// coeff_width: 24
// coeff_fract_width: 26
// chan_seq: 0
// num_channels: 1
// num_paths: 1
// data_width: 24
// data_fract_width: 23
// output_rounding_mode: 4
// output_width: 24
// accum_width: 51
// output_fract_width: 22
// config_method: 0

const double system_fir_compiler_0_0_coefficients[41] = {-1.8496877595e-04,-3.1966502107e-04,-3.9983572604e-04,-3.3380304983e-04,5.2790132615e-07,7.4938218967e-04,2.0714362252e-03,4.1213150936e-03,7.0296910521e-03,1.0882164433e-02,1.5699626911e-02,2.1422977056e-02,2.7904815002e-02,3.4910084326e-02,4.2126619127e-02,4.9185317972e-02,5.5688373221e-02,6.1242822589e-02,6.5495838016e-02,6.8167763599e-02,6.9079035719e-02,6.8167763599e-02,6.5495838016e-02,6.1242822589e-02,5.5688373221e-02,4.9185317972e-02,4.2126619127e-02,3.4910084326e-02,2.7904815002e-02,2.1422977056e-02,1.5699626911e-02,1.0882164433e-02,7.0296910521e-03,4.1213150936e-03,2.0714362252e-03,7.4938218967e-04,5.2790132615e-07,-3.3380304983e-04,-3.9983572604e-04,-3.1966502107e-04,-1.8496877595e-04};

const xip_fir_v7_2_pattern system_fir_compiler_0_0_chanpats[1] = {P_BASIC};

static xip_fir_v7_2_config gen_system_fir_compiler_0_0_config() {
  xip_fir_v7_2_config config;
  config.name                = "system_fir_compiler_0_0";
  config.data_coefficient_type = XIP_FIR_REAL_TYPE;
  config.filter_type         = 0;
  config.rate_change         = XIP_FIR_INTEGER_RATE;
  config.interp_rate         = 1;
  config.decim_rate          = 1;
  config.zero_pack_factor    = 1;
  config.coeff               = &system_fir_compiler_0_0_coefficients[0];
  config.coeff_padding       = 0;
  config.num_coeffs          = 41;
  config.coeff_sets          = 1;
  config.reloadable          = 0;
  config.is_halfband         = 0;
  config.quantization        = XIP_FIR_QUANTIZED_ONLY;
  config.coeff_width         = 24;
  config.coeff_fract_width   = 26;
  config.chan_seq            = XIP_FIR_BASIC_CHAN_SEQ;
  config.num_channels        = 1;
  config.init_pattern        = system_fir_compiler_0_0_chanpats[0];
  config.num_paths           = 1;
  config.data_width          = 24;
  config.data_fract_width    = 23;
  config.output_rounding_mode= XIP_FIR_CONVERGENT_EVEN;
  config.output_width        = 24;
  config.accum_width         = 51;
  config.output_fract_width  = 22;
  config.config_method       = XIP_FIR_CONFIG_SINGLE;
  return config;
}

const xip_fir_v7_2_config system_fir_compiler_0_0_config = gen_system_fir_compiler_0_0_config();

