
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
// C Model configuration for the "system_fir_1_0" instance.
//
//------------------------------------------------------------------------------
//
// coefficients: -3.5697091863e-04,-3.7965365920e-04,-4.0623279373e-04,-4.3714261414e-04,-4.7261126568e-04,-5.1263855732e-04,-5.5697708210e-04,-6.0511706310e-04,-6.5627529071e-04,-7.0938845999e-04,-7.6311115443e-04,-8.1581865526e-04,-8.6561468410e-04,-9.1034411229e-04,-9.4761059484e-04,-9.7479900961e-04,-9.8910250665e-04,-9.8755389784e-04,-9.6706104507e-04,-9.2444583766e-04,-8.5648628635e-04,-7.5996120453e-04,-6.3169689716e-04,-4.6861523546e-04,-2.6778246175e-04,-2.6458043649e-05,2.5785711801e-04,5.8737382894e-04,9.6396978521e-04,1.3891474829e-03,1.8639955101e-03,2.3891538437e-03,2.9647837280e-03,3.5905426614e-03,4.2655649526e-03,4.9884482441e-03,5.7572463201e-03,6.5694684397e-03,7.4220853489e-03,8.3115420375e-03,9.2337772158e-03,1.0184249398e-02,1.1157969381e-02,1.2149538836e-02,1.3153194615e-02,1.4162858331e-02,1.5172190661e-02,1.6174649775e-02,1.7163553224e-02,1.8132142554e-02,1.9073649913e-02,1.9981365826e-02,2.0848707332e-02,2.1669285656e-02,2.2436972584e-02,2.3145964707e-02,2.3790844764e-02,2.4366639285e-02,2.4868871838e-02,2.5293611191e-02,2.5637513799e-02,2.5897860057e-02,2.6072583878e-02,2.6160295210e-02,2.6160295210e-02,2.6072583878e-02,2.5897860057e-02,2.5637513799e-02,2.5293611191e-02,2.4868871838e-02,2.4366639285e-02,2.3790844764e-02,2.3145964707e-02,2.2436972584e-02,2.1669285656e-02,2.0848707332e-02,1.9981365826e-02,1.9073649913e-02,1.8132142554e-02,1.7163553224e-02,1.6174649775e-02,1.5172190661e-02,1.4162858331e-02,1.3153194615e-02,1.2149538836e-02,1.1157969381e-02,1.0184249398e-02,9.2337772158e-03,8.3115420375e-03,7.4220853489e-03,6.5694684397e-03,5.7572463201e-03,4.9884482441e-03,4.2655649526e-03,3.5905426614e-03,2.9647837280e-03,2.3891538437e-03,1.8639955101e-03,1.3891474829e-03,9.6396978521e-04,5.8737382894e-04,2.5785711801e-04,-2.6458043649e-05,-2.6778246175e-04,-4.6861523546e-04,-6.3169689716e-04,-7.5996120453e-04,-8.5648628635e-04,-9.2444583766e-04,-9.6706104507e-04,-9.8755389784e-04,-9.8910250665e-04,-9.7479900961e-04,-9.4761059484e-04,-9.1034411229e-04,-8.6561468410e-04,-8.1581865526e-04,-7.6311115443e-04,-7.0938845999e-04,-6.5627529071e-04,-6.0511706310e-04,-5.5697708210e-04,-5.1263855732e-04,-4.7261126568e-04,-4.3714261414e-04,-4.0623279373e-04,-3.7965365920e-04,-3.5697091863e-04
// chanpats: 173
// name: system_fir_1_0
// data_coefficient_type: 0
// filter_type: 2
// rate_change: 1
// interp_rate: 8
// decim_rate: 25
// zero_pack_factor: 1
// coeff_padding: 0
// num_coeffs: 128
// coeff_sets: 1
// reloadable: 0
// is_halfband: 0
// quantization: 1
// coeff_width: 24
// coeff_fract_width: 28
// chan_seq: 0
// num_channels: 1
// num_paths: 1
// data_width: 24
// data_fract_width: 0
// output_rounding_mode: 4
// output_width: 34
// accum_width: 50
// output_fract_width: 12
// config_method: 0

const double system_fir_1_0_coefficients[128] = {-3.5697091863e-04,-3.7965365920e-04,-4.0623279373e-04,-4.3714261414e-04,-4.7261126568e-04,-5.1263855732e-04,-5.5697708210e-04,-6.0511706310e-04,-6.5627529071e-04,-7.0938845999e-04,-7.6311115443e-04,-8.1581865526e-04,-8.6561468410e-04,-9.1034411229e-04,-9.4761059484e-04,-9.7479900961e-04,-9.8910250665e-04,-9.8755389784e-04,-9.6706104507e-04,-9.2444583766e-04,-8.5648628635e-04,-7.5996120453e-04,-6.3169689716e-04,-4.6861523546e-04,-2.6778246175e-04,-2.6458043649e-05,2.5785711801e-04,5.8737382894e-04,9.6396978521e-04,1.3891474829e-03,1.8639955101e-03,2.3891538437e-03,2.9647837280e-03,3.5905426614e-03,4.2655649526e-03,4.9884482441e-03,5.7572463201e-03,6.5694684397e-03,7.4220853489e-03,8.3115420375e-03,9.2337772158e-03,1.0184249398e-02,1.1157969381e-02,1.2149538836e-02,1.3153194615e-02,1.4162858331e-02,1.5172190661e-02,1.6174649775e-02,1.7163553224e-02,1.8132142554e-02,1.9073649913e-02,1.9981365826e-02,2.0848707332e-02,2.1669285656e-02,2.2436972584e-02,2.3145964707e-02,2.3790844764e-02,2.4366639285e-02,2.4868871838e-02,2.5293611191e-02,2.5637513799e-02,2.5897860057e-02,2.6072583878e-02,2.6160295210e-02,2.6160295210e-02,2.6072583878e-02,2.5897860057e-02,2.5637513799e-02,2.5293611191e-02,2.4868871838e-02,2.4366639285e-02,2.3790844764e-02,2.3145964707e-02,2.2436972584e-02,2.1669285656e-02,2.0848707332e-02,1.9981365826e-02,1.9073649913e-02,1.8132142554e-02,1.7163553224e-02,1.6174649775e-02,1.5172190661e-02,1.4162858331e-02,1.3153194615e-02,1.2149538836e-02,1.1157969381e-02,1.0184249398e-02,9.2337772158e-03,8.3115420375e-03,7.4220853489e-03,6.5694684397e-03,5.7572463201e-03,4.9884482441e-03,4.2655649526e-03,3.5905426614e-03,2.9647837280e-03,2.3891538437e-03,1.8639955101e-03,1.3891474829e-03,9.6396978521e-04,5.8737382894e-04,2.5785711801e-04,-2.6458043649e-05,-2.6778246175e-04,-4.6861523546e-04,-6.3169689716e-04,-7.5996120453e-04,-8.5648628635e-04,-9.2444583766e-04,-9.6706104507e-04,-9.8755389784e-04,-9.8910250665e-04,-9.7479900961e-04,-9.4761059484e-04,-9.1034411229e-04,-8.6561468410e-04,-8.1581865526e-04,-7.6311115443e-04,-7.0938845999e-04,-6.5627529071e-04,-6.0511706310e-04,-5.5697708210e-04,-5.1263855732e-04,-4.7261126568e-04,-4.3714261414e-04,-4.0623279373e-04,-3.7965365920e-04,-3.5697091863e-04};

const xip_fir_v7_2_pattern system_fir_1_0_chanpats[1] = {P_BASIC};

static xip_fir_v7_2_config gen_system_fir_1_0_config() {
  xip_fir_v7_2_config config;
  config.name                = "system_fir_1_0";
  config.data_coefficient_type = XIP_FIR_REAL_TYPE;
  config.filter_type         = 2;
  config.rate_change         = XIP_FIR_FRACTIONAL_RATE;
  config.interp_rate         = 8;
  config.decim_rate          = 25;
  config.zero_pack_factor    = 1;
  config.coeff               = &system_fir_1_0_coefficients[0];
  config.coeff_padding       = 0;
  config.num_coeffs          = 128;
  config.coeff_sets          = 1;
  config.reloadable          = 0;
  config.is_halfband         = 0;
  config.quantization        = XIP_FIR_QUANTIZED_ONLY;
  config.coeff_width         = 24;
  config.coeff_fract_width   = 28;
  config.chan_seq            = XIP_FIR_BASIC_CHAN_SEQ;
  config.num_channels        = 1;
  config.init_pattern        = system_fir_1_0_chanpats[0];
  config.num_paths           = 1;
  config.data_width          = 24;
  config.data_fract_width    = 0;
  config.output_rounding_mode= XIP_FIR_CONVERGENT_EVEN;
  config.output_width        = 34;
  config.accum_width         = 50;
  config.output_fract_width  = 12;
  config.config_method       = XIP_FIR_CONFIG_SINGLE;
  return config;
}

const xip_fir_v7_2_config system_fir_1_0_config = gen_system_fir_1_0_config();

