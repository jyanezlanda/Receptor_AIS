
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
// C Model configuration for the "system_fir_0_0" instance.
//
//------------------------------------------------------------------------------
//
// coefficients: 2.9466840486e-09,3.3577459706e-07,5.2774188936e-08,5.6874919592e-07,-6.8573704542e-08,-3.5766058774e-06,-3.7445820520e-07,-2.4372735901e-06,4.5284934196e-07,1.7212787680e-05,1.4660670498e-06,5.2674209604e-06,-1.9471646386e-06,-5.9602663375e-05,-4.3146891773e-06,-3.0964946903e-06,6.5848523038e-06,1.7033632291e-04,1.0655592747e-05,-2.7046103666e-05,-1.9199606054e-05,-4.3242936040e-04,-2.3569186830e-05,1.5484387454e-04,5.1569747555e-05,1.0349758428e-03,4.9671241508e-05,-5.9293933382e-04,-1.3703742588e-04,-2.5156618346e-03,-1.1036788447e-04,2.1448524123e-03,4.0615851503e-04,7.1916550197e-03,3.4148109819e-04,-1.0021228449e-02,-1.8791964808e-03,-4.0592719623e-02,-5.5493835884e-03,2.9353068712e-01,5.1371473159e-01,2.9353068712e-01,-5.5493835884e-03,-4.0592719623e-02,-1.8791964808e-03,-1.0021228449e-02,3.4148109819e-04,7.1916550197e-03,4.0615851503e-04,2.1448524123e-03,-1.1036788447e-04,-2.5156618346e-03,-1.3703742588e-04,-5.9293933382e-04,4.9671241508e-05,1.0349758428e-03,5.1569747555e-05,1.5484387454e-04,-2.3569186830e-05,-4.3242936040e-04,-1.9199606054e-05,-2.7046103666e-05,1.0655592747e-05,1.7033632291e-04,6.5848523038e-06,-3.0964946903e-06,-4.3146891773e-06,-5.9602663375e-05,-1.9471646386e-06,5.2674209604e-06,1.4660670498e-06,1.7212787680e-05,4.5284934196e-07,-2.4372735901e-06,-3.7445820520e-07,-3.5766058774e-06,-6.8573704542e-08,5.6874919592e-07,5.2774188936e-08,3.3577459706e-07,2.9466840486e-09
// chanpats: 173
// name: system_fir_0_0
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
// coeff_fract_width: 23
// chan_seq: 0
// num_channels: 2
// num_paths: 1
// data_width: 32
// data_fract_width: 0
// output_rounding_mode: 4
// output_width: 32
// accum_width: 56
// output_fract_width: 0
// config_method: 0

const double system_fir_0_0_coefficients[81] = {2.9466840486e-09,3.3577459706e-07,5.2774188936e-08,5.6874919592e-07,-6.8573704542e-08,-3.5766058774e-06,-3.7445820520e-07,-2.4372735901e-06,4.5284934196e-07,1.7212787680e-05,1.4660670498e-06,5.2674209604e-06,-1.9471646386e-06,-5.9602663375e-05,-4.3146891773e-06,-3.0964946903e-06,6.5848523038e-06,1.7033632291e-04,1.0655592747e-05,-2.7046103666e-05,-1.9199606054e-05,-4.3242936040e-04,-2.3569186830e-05,1.5484387454e-04,5.1569747555e-05,1.0349758428e-03,4.9671241508e-05,-5.9293933382e-04,-1.3703742588e-04,-2.5156618346e-03,-1.1036788447e-04,2.1448524123e-03,4.0615851503e-04,7.1916550197e-03,3.4148109819e-04,-1.0021228449e-02,-1.8791964808e-03,-4.0592719623e-02,-5.5493835884e-03,2.9353068712e-01,5.1371473159e-01,2.9353068712e-01,-5.5493835884e-03,-4.0592719623e-02,-1.8791964808e-03,-1.0021228449e-02,3.4148109819e-04,7.1916550197e-03,4.0615851503e-04,2.1448524123e-03,-1.1036788447e-04,-2.5156618346e-03,-1.3703742588e-04,-5.9293933382e-04,4.9671241508e-05,1.0349758428e-03,5.1569747555e-05,1.5484387454e-04,-2.3569186830e-05,-4.3242936040e-04,-1.9199606054e-05,-2.7046103666e-05,1.0655592747e-05,1.7033632291e-04,6.5848523038e-06,-3.0964946903e-06,-4.3146891773e-06,-5.9602663375e-05,-1.9471646386e-06,5.2674209604e-06,1.4660670498e-06,1.7212787680e-05,4.5284934196e-07,-2.4372735901e-06,-3.7445820520e-07,-3.5766058774e-06,-6.8573704542e-08,5.6874919592e-07,5.2774188936e-08,3.3577459706e-07,2.9466840486e-09};

const xip_fir_v7_2_pattern system_fir_0_0_chanpats[1] = {P_BASIC};

static xip_fir_v7_2_config gen_system_fir_0_0_config() {
  xip_fir_v7_2_config config;
  config.name                = "system_fir_0_0";
  config.data_coefficient_type = XIP_FIR_REAL_TYPE;
  config.filter_type         = 0;
  config.rate_change         = XIP_FIR_INTEGER_RATE;
  config.interp_rate         = 1;
  config.decim_rate          = 1;
  config.zero_pack_factor    = 1;
  config.coeff               = &system_fir_0_0_coefficients[0];
  config.coeff_padding       = 0;
  config.num_coeffs          = 81;
  config.coeff_sets          = 1;
  config.reloadable          = 0;
  config.is_halfband         = 0;
  config.quantization        = XIP_FIR_QUANTIZED_ONLY;
  config.coeff_width         = 24;
  config.coeff_fract_width   = 23;
  config.chan_seq            = XIP_FIR_BASIC_CHAN_SEQ;
  config.num_channels        = 2;
  config.init_pattern        = system_fir_0_0_chanpats[0];
  config.num_paths           = 1;
  config.data_width          = 32;
  config.data_fract_width    = 0;
  config.output_rounding_mode= XIP_FIR_CONVERGENT_EVEN;
  config.output_width        = 32;
  config.accum_width         = 56;
  config.output_fract_width  = 0;
  config.config_method       = XIP_FIR_CONFIG_SINGLE;
  return config;
}

const xip_fir_v7_2_config system_fir_0_0_config = gen_system_fir_0_0_config();

