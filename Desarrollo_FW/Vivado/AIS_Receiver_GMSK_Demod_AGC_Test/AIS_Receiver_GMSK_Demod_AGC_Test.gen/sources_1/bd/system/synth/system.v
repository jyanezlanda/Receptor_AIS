//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2025.2 (win64) Build 6299465 Fri Nov 14 19:35:11 GMT 2025
//Date        : Wed Nov 11 10:21:49 2026
//Host        : DESKTOP-KIRSTEN running 64-bit major release  (build 9200)
//Command     : generate_target system.bd
//Design      : system
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module GMSK_Demod_imp_1G913PW
   (activo_confirmado,
    activo_ext,
    aresetn_0,
    clk_0,
    dispersion_dbg,
    m_axis_salida_tdata,
    m_axis_salida_tvalid,
    nivel,
    pico_cont,
    piso_ruido_dbg,
    rafaga_info,
    s_axis_tdata,
    s_axis_tvalid,
    sel_out);
  output activo_confirmado;
  output activo_ext;
  input aresetn_0;
  input clk_0;
  output [19:0]dispersion_dbg;
  output [31:0]m_axis_salida_tdata;
  output m_axis_salida_tvalid;
  output [19:0]nivel;
  output [31:0]pico_cont;
  output [19:0]piso_ruido_dbg;
  output [31:0]rafaga_info;
  input [63:0]s_axis_tdata;
  input s_axis_tvalid;
  input sel_out;

  wire activo_confirmado;
  wire activo_ext;
  wire aresetn_0;
  wire aresetn_1;
  wire clk_0;
  wire [19:0]dispersion_dbg;
  wire [63:0]gmsk_axis_broadcast2_0_m1_axis_TDATA;
  wire gmsk_axis_broadcast2_0_m1_axis_TVALID;
  wire [63:0]gmsk_axis_broadcast2_1_m0_axis1_TDATA;
  wire gmsk_axis_broadcast2_1_m0_axis1_TVALID;
  wire [19:0]gmsk_discriminador_dout;
  wire gmsk_discriminador_m2_axis_tvalid;
  wire [23:0]gmsk_discriminador_m_axis_soft_TDATA;
  wire gmsk_discriminador_m_axis_soft_TVALID;
  wire [31:0]gmsk_iq_unpack32_fir_m_axis_TDATA;
  wire gmsk_iq_unpack32_fir_m_axis_TVALID;
  wire [0:0]gmsk_simbolo_bit_crudo_tdata;
  wire gmsk_simbolo_bit_crudo_tvalid;
  wire [31:0]gmsk_squelch_calib_m_axis_TDATA;
  wire gmsk_squelch_calib_m_axis_TVALID;
  wire [31:0]m_axis_salida_tdata;
  wire m_axis_salida_tvalid;
  wire [19:0]nivel;
  wire [31:0]pico_cont;
  wire [19:0]piso_ruido_dbg;
  wire [31:0]rafaga_info;
  wire [63:0]s_axis_tdata;
  wire s_axis_tvalid;
  wire sel_out;

  system_gmsk_axis_broadcast2_0_4 gmsk_axis_broadcast2_fir
       (.aresetn(aresetn_0),
        .clk(clk_0),
        .m0_axis_tdata(gmsk_axis_broadcast2_1_m0_axis1_TDATA),
        .m0_axis_tvalid(gmsk_axis_broadcast2_1_m0_axis1_TVALID),
        .m1_axis_tdata(gmsk_axis_broadcast2_0_m1_axis_TDATA),
        .m1_axis_tvalid(gmsk_axis_broadcast2_0_m1_axis_TVALID),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid));
  system_gmsk_axis_mux2_out_0 gmsk_axis_mux2_out
       (.aresetn(aresetn_0),
        .clk(clk_0),
        .m_axis_tdata(m_axis_salida_tdata),
        .m_axis_tvalid(m_axis_salida_tvalid),
        .s_axis_a_tdata(gmsk_squelch_calib_m_axis_TDATA),
        .s_axis_a_tvalid(gmsk_squelch_calib_m_axis_TVALID),
        .s_axis_b_tdata(gmsk_iq_unpack32_fir_m_axis_TDATA),
        .s_axis_b_tvalid(gmsk_iq_unpack32_fir_m_axis_TVALID),
        .sel(sel_out));
  gmsk_discriminador_imp_1LMKRV4 gmsk_discriminador
       (.aresetn_0(aresetn_0),
        .clk_0(clk_0),
        .dout(gmsk_discriminador_dout),
        .m_axis_soft_tdata(gmsk_discriminador_m_axis_soft_TDATA),
        .m_axis_soft_tvalid(gmsk_discriminador_m_axis_soft_TVALID),
        .mag_disc_tvalid(gmsk_discriminador_m2_axis_tvalid),
        .s_axis_iq_tdata(gmsk_axis_broadcast2_1_m0_axis1_TDATA),
        .s_axis_iq_tvalid(gmsk_axis_broadcast2_1_m0_axis1_TVALID));
  system_gmsk_iq_unpack32_0_1 gmsk_iq_unpack32_fir
       (.aresetn(aresetn_0),
        .clk(clk_0),
        .m_axis_tdata(gmsk_iq_unpack32_fir_m_axis_TDATA),
        .m_axis_tvalid(gmsk_iq_unpack32_fir_m_axis_TVALID),
        .s_axis_tdata(gmsk_axis_broadcast2_0_m1_axis_TDATA),
        .s_axis_tvalid(gmsk_axis_broadcast2_0_m1_axis_TVALID));
  system_gmsk_nivel_senal_0_0 gmsk_nivel_senal_0
       (.aresetn(aresetn_0),
        .clk(clk_0),
        .mag_tdata(gmsk_discriminador_dout),
        .mag_tvalid(gmsk_discriminador_m2_axis_tvalid),
        .nivel(nivel));
  system_gmsk_pico_rafaga_0_0 gmsk_pico_rafaga_0
       (.activo(activo_confirmado),
        .aresetn(aresetn_0),
        .clk(clk_0),
        .nivel(nivel),
        .pico_cont(pico_cont),
        .rafaga_info(rafaga_info),
        .tick(gmsk_discriminador_m2_axis_tvalid));
  gmsk_salida_imp_LIGAA3 gmsk_salida
       (.aresetn(aresetn_0),
        .bit_in(gmsk_simbolo_bit_crudo_tdata),
        .bit_in_valid(gmsk_simbolo_bit_crudo_tvalid),
        .clk_0(clk_0),
        .m_axis_tdata(gmsk_squelch_calib_m_axis_TDATA),
        .m_axis_tvalid(gmsk_squelch_calib_m_axis_TVALID));
  gmsk_simbolo_imp_N1U41C gmsk_simbolo
       (.S_AXIS_DATA_tdata(gmsk_discriminador_m_axis_soft_TDATA),
        .S_AXIS_DATA_tvalid(gmsk_discriminador_m_axis_soft_TVALID),
        .aresetn(aresetn_1),
        .aresetn_0(aresetn_0),
        .bit_crudo_tdata(gmsk_simbolo_bit_crudo_tdata),
        .bit_crudo_tvalid(gmsk_simbolo_bit_crudo_tvalid),
        .clk_0(clk_0));
  gmsk_squelch_calib_imp_6IJ2Y1 gmsk_squelch_calib
       (.activo_confirmado(activo_confirmado),
        .activo_ext(activo_ext),
        .aresetn_0(aresetn_0),
        .aresetn_simbolo(aresetn_1),
        .clk_0(clk_0),
        .dispersion_dbg(dispersion_dbg),
        .piso_ruido_dbg(piso_ruido_dbg),
        .s_axis_mag_tdata(gmsk_discriminador_dout),
        .s_axis_mag_tvalid(gmsk_discriminador_m2_axis_tvalid));
endmodule

module gmsk_discriminador_imp_1LMKRV4
   (aresetn_0,
    clk_0,
    dout,
    m_axis_soft_tdata,
    m_axis_soft_tvalid,
    mag_disc_tvalid,
    s_axis_iq_tdata,
    s_axis_iq_tvalid);
  input aresetn_0;
  input clk_0;
  output [19:0]dout;
  output [23:0]m_axis_soft_tdata;
  output m_axis_soft_tvalid;
  output mag_disc_tvalid;
  input [63:0]s_axis_iq_tdata;
  input s_axis_iq_tvalid;

  wire aresetn_0;
  wire [63:0]axis_lfsr_0_m_axis_TDATA;
  wire axis_lfsr_0_m_axis_TVALID;
  wire clk_0;
  wire [47:0]cmpy_discriminador_M_AXIS_DOUT_TDATA;
  wire cmpy_discriminador_M_AXIS_DOUT_TVALID;
  wire [47:0]cordic_discriminador_m_axis_dout_tdata;
  wire [19:0]dout;
  wire [63:0]gmsk_discriminator_p_0_m_axis_a_TDATA;
  wire gmsk_discriminator_p_0_m_axis_a_TVALID;
  wire [63:0]gmsk_discriminator_p_0_m_axis_b_TDATA;
  wire gmsk_discriminator_p_0_m_axis_b_TVALID;
  wire [23:0]m_axis_soft_tdata;
  wire m_axis_soft_tvalid;
  wire mag_disc_tvalid;
  wire [15:0]phase_slice_disc_0_dout;
  wire [63:0]s_axis_iq_tdata;
  wire s_axis_iq_tvalid;

  system_axis_lfsr_0_1 axis_lfsr_disc
       (.aclk(clk_0),
        .aresetn(aresetn_0),
        .m_axis_tdata(axis_lfsr_0_m_axis_TDATA),
        .m_axis_tready(1'b1),
        .m_axis_tvalid(axis_lfsr_0_m_axis_TVALID));
  system_cmpy_discriminator_0_0 cmpy_discriminador
       (.aclk(clk_0),
        .aresetn(aresetn_0),
        .m_axis_dout_tdata(cmpy_discriminador_M_AXIS_DOUT_TDATA),
        .m_axis_dout_tvalid(cmpy_discriminador_M_AXIS_DOUT_TVALID),
        .s_axis_a_tdata(gmsk_discriminator_p_0_m_axis_a_TDATA),
        .s_axis_a_tvalid(gmsk_discriminator_p_0_m_axis_a_TVALID),
        .s_axis_b_tdata(gmsk_discriminator_p_0_m_axis_b_TDATA),
        .s_axis_b_tvalid(gmsk_discriminator_p_0_m_axis_b_TVALID),
        .s_axis_ctrl_tdata(axis_lfsr_0_m_axis_TDATA[7:0]),
        .s_axis_ctrl_tvalid(axis_lfsr_0_m_axis_TVALID));
  system_cordic_0_1 cordic_discriminador
       (.aclk(clk_0),
        .aresetn(aresetn_0),
        .m_axis_dout_tdata(cordic_discriminador_m_axis_dout_tdata),
        .m_axis_dout_tvalid(mag_disc_tvalid),
        .s_axis_cartesian_tdata(cmpy_discriminador_M_AXIS_DOUT_TDATA),
        .s_axis_cartesian_tvalid(cmpy_discriminador_M_AXIS_DOUT_TVALID));
  system_gmsk_discriminator_p_0_1 gmsk_discriminator_p_0
       (.aresetn(aresetn_0),
        .clk(clk_0),
        .m_axis_a_tdata(gmsk_discriminator_p_0_m_axis_a_TDATA),
        .m_axis_a_tvalid(gmsk_discriminator_p_0_m_axis_a_TVALID),
        .m_axis_b_tdata(gmsk_discriminator_p_0_m_axis_b_TDATA),
        .m_axis_b_tvalid(gmsk_discriminator_p_0_m_axis_b_TVALID),
        .s_axis_iq_tdata(s_axis_iq_tdata),
        .s_axis_iq_tvalid(s_axis_iq_tvalid));
  system_gmsk_soft_scale_0_2 gmsk_soft_scale_0
       (.aresetn(aresetn_0),
        .clk(clk_0),
        .m_axis_soft_tdata(m_axis_soft_tdata),
        .m_axis_soft_tvalid(m_axis_soft_tvalid),
        .s_axis_phase_tdata(phase_slice_disc_0_dout),
        .s_axis_phase_tvalid(mag_disc_tvalid));
  system_phase_slice_disc_0_0 mag_slice_disc_0
       (.din(cordic_discriminador_m_axis_dout_tdata),
        .dout(dout));
  system_port_slicer_0_6 phase_slice_disc_0
       (.din(cordic_discriminador_m_axis_dout_tdata),
        .dout(phase_slice_disc_0_dout));
endmodule

module gmsk_salida_imp_LIGAA3
   (aresetn,
    bit_in,
    bit_in_valid,
    clk_0,
    m_axis_tdata,
    m_axis_tvalid);
  input aresetn;
  input bit_in;
  input bit_in_valid;
  input clk_0;
  output [31:0]m_axis_tdata;
  output m_axis_tvalid;

  wire aresetn;
  wire bit_in;
  wire bit_in_valid;
  wire clk_0;
  wire gmsk_nrzi_decode_0_bit_out;
  wire gmsk_nrzi_decode_0_bit_out_valid;
  wire [31:0]m_axis_tdata;
  wire m_axis_tvalid;

  system_gmsk_bit_pack32_0_0 gmsk_bit_pack32_out
       (.aresetn(aresetn),
        .bit_in(gmsk_nrzi_decode_0_bit_out),
        .bit_in_valid(gmsk_nrzi_decode_0_bit_out_valid),
        .clk(clk_0),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tready(1'b1),
        .m_axis_tvalid(m_axis_tvalid));
  system_gmsk_nrzi_decode_0_0 gmsk_nrzi_decode_0
       (.aresetn(aresetn),
        .bit_in(bit_in),
        .bit_in_valid(bit_in_valid),
        .bit_out(gmsk_nrzi_decode_0_bit_out),
        .bit_out_valid(gmsk_nrzi_decode_0_bit_out_valid),
        .clk(clk_0));
endmodule

module gmsk_simbolo_imp_N1U41C
   (S_AXIS_DATA_tdata,
    S_AXIS_DATA_tvalid,
    aresetn,
    aresetn_0,
    bit_crudo_tdata,
    bit_crudo_tvalid,
    clk_0);
  input [23:0]S_AXIS_DATA_tdata;
  input S_AXIS_DATA_tvalid;
  input aresetn;
  input aresetn_0;
  output [0:0]bit_crudo_tdata;
  output bit_crudo_tvalid;
  input clk_0;

  wire [23:0]S_AXIS_DATA_tdata;
  wire S_AXIS_DATA_tvalid;
  wire aresetn;
  wire aresetn_0;
  wire \^bit_crudo_tdata ;
  wire bit_crudo_tvalid;
  wire clk_0;
  wire [31:0]cordic_goertzel_M_AXIS_DOUT_TDATA;
  wire cordic_goertzel_M_AXIS_DOUT_TVALID;
  wire [47:0]dds_fixed_goertzel_m_axis_data_tdata;
  wire dds_fixed_goertzel_m_axis_data_tvalid;
  wire [23:0]gmsk_axis_broadcast2_0_m0_axis_tdata;
  wire gmsk_axis_broadcast2_0_m0_axis_tvalid;
  wire [23:0]gmsk_dc_tracker_1_dc_tdata;
  wire [23:0]gmsk_delay_line_0_m_axis_TDATA;
  wire gmsk_delay_line_0_m_axis_TVALID;
  wire [47:0]gmsk_iq_pack_0_m_axis_TDATA;
  wire gmsk_iq_pack_0_m_axis_TVALID;
  wire [23:0]gmsk_soft_menos_dc_0_dout_tdata;
  wire [23:0]gmsk_symbol_phase_ac_0_m_axis_acc_i_tdata;
  wire [23:0]gmsk_symbol_phase_ac_0_m_axis_acc_q_tdata;
  wire gmsk_symbol_phase_ac_0_m_axis_acc_tvalid;
  wire gmsk_symbol_strobe_0_strobe;
  wire [31:0]gmsk_tau_to_fase_0_m_axis_carga_TDATA;
  wire gmsk_tau_to_fase_0_m_axis_carga_TVALID;

  assign bit_crudo_tdata[0] = \^bit_crudo_tdata ;
  system_cordic_cfo_0 cordic_goertzel
       (.aclk(clk_0),
        .aresetn(aresetn_0),
        .m_axis_dout_tdata(cordic_goertzel_M_AXIS_DOUT_TDATA),
        .m_axis_dout_tvalid(cordic_goertzel_M_AXIS_DOUT_TVALID),
        .s_axis_cartesian_tdata(gmsk_iq_pack_0_m_axis_TDATA),
        .s_axis_cartesian_tvalid(gmsk_iq_pack_0_m_axis_TVALID));
  system_osc_0_1 dds_fixed_goertzel
       (.aclk(clk_0),
        .aresetn(aresetn),
        .m_axis_data_tdata(dds_fixed_goertzel_m_axis_data_tdata),
        .m_axis_data_tready(gmsk_axis_broadcast2_0_m0_axis_tvalid),
        .m_axis_data_tvalid(dds_fixed_goertzel_m_axis_data_tvalid));
  system_fir_compiler_0_0 fir_soft_0
       (.aclk(clk_0),
        .aresetn(aresetn_0),
        .m_axis_data_tdata(gmsk_axis_broadcast2_0_m0_axis_tdata),
        .m_axis_data_tvalid(gmsk_axis_broadcast2_0_m0_axis_tvalid),
        .s_axis_data_tdata(S_AXIS_DATA_tdata),
        .s_axis_data_tvalid(S_AXIS_DATA_tvalid));
  system_gmsk_dc_tracker_1_0 gmsk_dc_tracker_symb
       (.aresetn(aresetn),
        .clk(clk_0),
        .dc_tdata(gmsk_dc_tracker_1_dc_tdata),
        .s_axis_soft_tdata(gmsk_axis_broadcast2_0_m0_axis_tdata),
        .s_axis_soft_tvalid(gmsk_axis_broadcast2_0_m0_axis_tvalid));
  system_gmsk_delay_line_0_0 gmsk_delay_line_0
       (.aresetn(aresetn_0),
        .clk(clk_0),
        .m_axis_tdata(gmsk_delay_line_0_m_axis_TDATA),
        .m_axis_tvalid(gmsk_delay_line_0_m_axis_TVALID),
        .s_axis_tdata(gmsk_soft_menos_dc_0_dout_tdata),
        .s_axis_tvalid(gmsk_axis_broadcast2_0_m0_axis_tvalid));
  system_gmsk_iq_pack_0_1 gmsk_iq_pack_symb
       (.aresetn(aresetn_0),
        .clk(clk_0),
        .m_axis_tdata(gmsk_iq_pack_0_m_axis_TDATA),
        .m_axis_tvalid(gmsk_iq_pack_0_m_axis_TVALID),
        .s_axis_i_tdata(gmsk_symbol_phase_ac_0_m_axis_acc_i_tdata),
        .s_axis_i_tvalid(gmsk_symbol_phase_ac_0_m_axis_acc_tvalid),
        .s_axis_q_tdata(gmsk_symbol_phase_ac_0_m_axis_acc_q_tdata),
        .s_axis_q_tvalid(gmsk_symbol_phase_ac_0_m_axis_acc_tvalid));
  system_gmsk_slicer_0_0 gmsk_slicer_0
       (.aresetn(aresetn_0),
        .bit_crudo_tdata(\^bit_crudo_tdata ),
        .bit_crudo_tvalid(bit_crudo_tvalid),
        .clk(clk_0),
        .dc_tdata(gmsk_dc_tracker_1_dc_tdata),
        .soft_tdata(gmsk_axis_broadcast2_0_m0_axis_tdata),
        .strobe(gmsk_symbol_strobe_0_strobe));
  system_gmsk_soft_menos_dc_0_0 gmsk_soft_menos_dc_0
       (.dc_tdata(gmsk_dc_tracker_1_dc_tdata),
        .dout_tdata(gmsk_soft_menos_dc_0_dout_tdata),
        .soft_tdata(gmsk_axis_broadcast2_0_m0_axis_tdata));
  system_gmsk_symbol_phase_ac_0_0 gmsk_symbol_phase_ac_0
       (.aresetn(aresetn),
        .clk(clk_0),
        .m_axis_acc_i_tdata(gmsk_symbol_phase_ac_0_m_axis_acc_i_tdata),
        .m_axis_acc_q_tdata(gmsk_symbol_phase_ac_0_m_axis_acc_q_tdata),
        .m_axis_acc_tvalid(gmsk_symbol_phase_ac_0_m_axis_acc_tvalid),
        .s_axis_nco_tdata(dds_fixed_goertzel_m_axis_data_tdata),
        .s_axis_nco_tvalid(dds_fixed_goertzel_m_axis_data_tvalid),
        .s_axis_soft_tdata(gmsk_delay_line_0_m_axis_TDATA),
        .s_axis_soft_tvalid(gmsk_delay_line_0_m_axis_TVALID));
  system_gmsk_symbol_strobe_0_2 gmsk_symbol_strobe_0
       (.aresetn(aresetn_0),
        .clk(clk_0),
        .s_axis_carga_tdata(gmsk_tau_to_fase_0_m_axis_carga_TDATA),
        .s_axis_carga_tvalid(gmsk_tau_to_fase_0_m_axis_carga_TVALID),
        .s_axis_soft_tvalid(gmsk_axis_broadcast2_0_m0_axis_tvalid),
        .strobe(gmsk_symbol_strobe_0_strobe));
  system_gmsk_tau_to_fase_0_0 gmsk_tau_to_fase_0
       (.aresetn(aresetn),
        .clk(clk_0),
        .m_axis_carga_tdata(gmsk_tau_to_fase_0_m_axis_carga_TDATA),
        .m_axis_carga_tvalid(gmsk_tau_to_fase_0_m_axis_carga_TVALID),
        .s_axis_cordic_tdata(cordic_goertzel_M_AXIS_DOUT_TDATA),
        .s_axis_cordic_tvalid(cordic_goertzel_M_AXIS_DOUT_TVALID));
endmodule

module gmsk_squelch_calib_imp_6IJ2Y1
   (activo_confirmado,
    activo_ext,
    aresetn_0,
    aresetn_simbolo,
    clk_0,
    dispersion_dbg,
    piso_ruido_dbg,
    s_axis_mag_tdata,
    s_axis_mag_tvalid);
  output activo_confirmado;
  output activo_ext;
  input aresetn_0;
  output aresetn_simbolo;
  input clk_0;
  output [19:0]dispersion_dbg;
  output [19:0]piso_ruido_dbg;
  input [19:0]s_axis_mag_tdata;
  input s_axis_mag_tvalid;

  wire activo_confirmado;
  wire activo_ext;
  wire aresetn_0;
  wire aresetn_simbolo;
  wire clk_0;
  wire [19:0]dispersion_dbg;
  wire gmsk_squelch_0_activo;
  wire [19:0]gmsk_squelch_autocal_0_umbral_alto;
  wire [19:0]gmsk_squelch_autocal_0_umbral_bajo;
  wire [19:0]piso_ruido_dbg;
  wire [19:0]s_axis_mag_tdata;
  wire s_axis_mag_tvalid;

  system_gmsk_activo_extendido_0_0 gmsk_activo_extendido_0
       (.activo(activo_confirmado),
        .activo_ext(activo_ext),
        .aresetn(aresetn_0),
        .clk(clk_0),
        .tick(s_axis_mag_tvalid));
  system_gmsk_reset_rafaga_0_0 gmsk_reset_rafaga_0
       (.activo(activo_confirmado),
        .aresetn_global(aresetn_0),
        .aresetn_simbolo(aresetn_simbolo),
        .clk(clk_0));
  system_gmsk_squelch_0_0 gmsk_squelch_0
       (.activo(gmsk_squelch_0_activo),
        .aresetn(aresetn_0),
        .clk(clk_0),
        .s_axis_mag_tdata(s_axis_mag_tdata),
        .s_axis_mag_tvalid(s_axis_mag_tvalid),
        .umbral_alto(gmsk_squelch_autocal_0_umbral_alto),
        .umbral_bajo(gmsk_squelch_autocal_0_umbral_bajo));
  system_gmsk_squelch_autocal_0_0 gmsk_squelch_autocal_0
       (.activo(activo_confirmado),
        .aresetn(aresetn_0),
        .clk(clk_0),
        .dispersion_dbg(dispersion_dbg),
        .mag_tdata(s_axis_mag_tdata),
        .mag_tvalid(s_axis_mag_tvalid),
        .piso_ruido_dbg(piso_ruido_dbg),
        .umbral_alto(gmsk_squelch_autocal_0_umbral_alto),
        .umbral_bajo(gmsk_squelch_autocal_0_umbral_bajo));
  system_gmsk_squelch_debounce_0_0 gmsk_squelch_debounce_0
       (.activo_confirmado(activo_confirmado),
        .activo_crudo(gmsk_squelch_0_activo),
        .activo_crudo_tvalid(s_axis_mag_tvalid),
        .aresetn(aresetn_0),
        .clk(clk_0));
endmodule

module rx_0_imp_178AHDX
   (aclk,
    aresetn_0,
    din,
    dout,
    m_axis_tdata,
    m_axis_tready,
    m_axis_tvalid,
    s_axis_adc_tdata,
    s_axis_adc_tvalid);
  input aclk;
  input aresetn_0;
  input [127:0]din;
  output [159:0]dout;
  output [31:0]m_axis_tdata;
  input m_axis_tready;
  output m_axis_tvalid;
  input [31:0]s_axis_adc_tdata;
  input s_axis_adc_tvalid;

  wire GMSK_Demod_activo_confirmado;
  wire GMSK_Demod_activo_ext;
  wire [19:0]GMSK_Demod_dispersion_dbg;
  wire [31:0]GMSK_Demod_m_axis1_TDATA;
  wire GMSK_Demod_m_axis1_TVALID;
  wire [19:0]GMSK_Demod_nivel;
  wire [31:0]GMSK_Demod_pico_cont;
  wire [19:0]GMSK_Demod_piso_ruido_dbg;
  wire [31:0]GMSK_Demod_rafaga_info;
  wire aclk;
  wire aresetn_0;
  wire [23:0]bcast_0_M00_AXIS_TDATA;
  wire [0:0]bcast_0_M00_AXIS_TVALID;
  wire [47:24]bcast_0_M01_AXIS_TDATA;
  wire [1:1]bcast_0_M01_AXIS_TVALID;
  wire [31:0]cic_0_M_AXIS_DATA_TDATA;
  wire cic_0_M_AXIS_DATA_TREADY;
  wire cic_0_M_AXIS_DATA_TVALID;
  wire [31:0]cic_1_M_AXIS_DATA_TDATA;
  wire cic_1_M_AXIS_DATA_TREADY;
  wire cic_1_M_AXIS_DATA_TVALID;
  wire [47:0]dds_0_M_AXIS_DATA_TDATA;
  wire dds_0_M_AXIS_DATA_TVALID;
  wire [127:0]din;
  wire [159:0]dout;
  wire [15:0]fifo_0_read_count;
  wire [31:0]fir_0_M_AXIS_DATA_TDATA;
  wire fir_0_M_AXIS_DATA_TVALID;
  wire [31:0]fir_1_M_AXIS_DATA_TDATA;
  wire fir_1_M_AXIS_DATA_TVALID;
  wire [63:0]gmsk_iq_pack_fir_m_axis_TDATA;
  wire gmsk_iq_pack_fir_m_axis_TVALID;
  wire [63:0]lfsr_0_m_axis_TDATA;
  wire lfsr_0_m_axis_TVALID;
  wire [31:0]m_axis_tdata;
  wire m_axis_tready;
  wire m_axis_tvalid;
  wire [63:0]mult_0_M_AXIS_DOUT_TDATA;
  wire mult_0_M_AXIS_DOUT_TVALID;
  wire [39:0]phase_0_m_axis_TDATA;
  wire phase_0_m_axis_TVALID;
  wire [31:0]s_axis_adc_tdata;
  wire s_axis_adc_tvalid;
  wire [0:0]sel_out_1;
  wire [0:0]slice_0_dout;
  wire [39:0]slice_1_dout;
  wire [17:0]xlconstant_0_dout;

  GMSK_Demod_imp_1G913PW GMSK_Demod
       (.activo_confirmado(GMSK_Demod_activo_confirmado),
        .activo_ext(GMSK_Demod_activo_ext),
        .aresetn_0(aresetn_0),
        .clk_0(aclk),
        .dispersion_dbg(GMSK_Demod_dispersion_dbg),
        .m_axis_salida_tdata(GMSK_Demod_m_axis1_TDATA),
        .m_axis_salida_tvalid(GMSK_Demod_m_axis1_TVALID),
        .nivel(GMSK_Demod_nivel),
        .pico_cont(GMSK_Demod_pico_cont),
        .piso_ruido_dbg(GMSK_Demod_piso_ruido_dbg),
        .rafaga_info(GMSK_Demod_rafaga_info),
        .s_axis_tdata(gmsk_iq_pack_fir_m_axis_TDATA),
        .s_axis_tvalid(gmsk_iq_pack_fir_m_axis_TVALID),
        .sel_out(sel_out_1));
  system_bcast_0_1 bcast_0
       (.aclk(aclk),
        .aresetn(aresetn_0),
        .m_axis_tdata({bcast_0_M01_AXIS_TDATA,bcast_0_M00_AXIS_TDATA}),
        .m_axis_tvalid({bcast_0_M01_AXIS_TVALID,bcast_0_M00_AXIS_TVALID}),
        .s_axis_tdata(mult_0_M_AXIS_DOUT_TDATA),
        .s_axis_tvalid(mult_0_M_AXIS_DOUT_TVALID));
  system_cic_0_0 cic_0
       (.aclk(aclk),
        .aresetn(aresetn_0),
        .m_axis_data_tdata(cic_0_M_AXIS_DATA_TDATA),
        .m_axis_data_tready(cic_0_M_AXIS_DATA_TREADY),
        .m_axis_data_tvalid(cic_0_M_AXIS_DATA_TVALID),
        .s_axis_data_tdata(bcast_0_M00_AXIS_TDATA),
        .s_axis_data_tvalid(bcast_0_M00_AXIS_TVALID));
  system_cic_0_1 cic_1
       (.aclk(aclk),
        .aresetn(aresetn_0),
        .m_axis_data_tdata(cic_1_M_AXIS_DATA_TDATA),
        .m_axis_data_tready(cic_1_M_AXIS_DATA_TREADY),
        .m_axis_data_tvalid(cic_1_M_AXIS_DATA_TVALID),
        .s_axis_data_tdata(bcast_0_M01_AXIS_TDATA),
        .s_axis_data_tvalid(bcast_0_M01_AXIS_TVALID));
  system_fifo_0_0 fifo_0
       (.aclk(aclk),
        .aresetn(slice_0_dout),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tready(m_axis_tready),
        .m_axis_tvalid(m_axis_tvalid),
        .read_count(fifo_0_read_count),
        .s_axis_tdata(GMSK_Demod_m_axis1_TDATA),
        .s_axis_tvalid(GMSK_Demod_m_axis1_TVALID));
  system_fir_0_0 fir_0
       (.aclk(aclk),
        .aresetn(aresetn_0),
        .m_axis_data_tdata(fir_0_M_AXIS_DATA_TDATA),
        .m_axis_data_tvalid(fir_0_M_AXIS_DATA_TVALID),
        .s_axis_data_tdata(cic_0_M_AXIS_DATA_TDATA),
        .s_axis_data_tready(cic_0_M_AXIS_DATA_TREADY),
        .s_axis_data_tvalid(cic_0_M_AXIS_DATA_TVALID));
  system_fir_0_2 fir_1
       (.aclk(aclk),
        .aresetn(aresetn_0),
        .m_axis_data_tdata(fir_1_M_AXIS_DATA_TDATA),
        .m_axis_data_tvalid(fir_1_M_AXIS_DATA_TVALID),
        .s_axis_data_tdata(cic_1_M_AXIS_DATA_TDATA),
        .s_axis_data_tready(cic_1_M_AXIS_DATA_TREADY),
        .s_axis_data_tvalid(cic_1_M_AXIS_DATA_TVALID));
  system_gmsk_iq_pack_0_0 gmsk_iq_pack_fir
       (.aresetn(aresetn_0),
        .clk(aclk),
        .m_axis_tdata(gmsk_iq_pack_fir_m_axis_TDATA),
        .m_axis_tvalid(gmsk_iq_pack_fir_m_axis_TVALID),
        .s_axis_i_tdata(fir_0_M_AXIS_DATA_TDATA),
        .s_axis_i_tvalid(fir_0_M_AXIS_DATA_TVALID),
        .s_axis_q_tdata(fir_1_M_AXIS_DATA_TDATA),
        .s_axis_q_tvalid(fir_1_M_AXIS_DATA_TVALID));
  system_lfsr_0_0 lfsr_0
       (.aclk(aclk),
        .aresetn(aresetn_0),
        .m_axis_tdata(lfsr_0_m_axis_TDATA),
        .m_axis_tready(1'b1),
        .m_axis_tvalid(lfsr_0_m_axis_TVALID));
  system_mult_0_0 mult_0
       (.aclk(aclk),
        .m_axis_dout_tdata(mult_0_M_AXIS_DOUT_TDATA),
        .m_axis_dout_tvalid(mult_0_M_AXIS_DOUT_TVALID),
        .s_axis_a_tdata(s_axis_adc_tdata),
        .s_axis_a_tvalid(s_axis_adc_tvalid),
        .s_axis_b_tdata(dds_0_M_AXIS_DATA_TDATA),
        .s_axis_b_tvalid(dds_0_M_AXIS_DATA_TVALID),
        .s_axis_ctrl_tdata(lfsr_0_m_axis_TDATA[7:0]),
        .s_axis_ctrl_tvalid(lfsr_0_m_axis_TVALID));
  system_port_slicer_0_4 mux_out_sel_slice
       (.din(din),
        .dout(sel_out_1));
  system_dds_0_0 osc_0
       (.aclk(aclk),
        .m_axis_data_tdata(dds_0_M_AXIS_DATA_TDATA),
        .m_axis_data_tvalid(dds_0_M_AXIS_DATA_TVALID),
        .s_axis_phase_tdata(phase_0_m_axis_TDATA),
        .s_axis_phase_tvalid(phase_0_m_axis_TVALID));
  system_phase_0_0 phase_0
       (.aclk(aclk),
        .cfg_data(slice_1_dout),
        .m_axis_tdata(phase_0_m_axis_TDATA),
        .m_axis_tvalid(phase_0_m_axis_TVALID));
  system_slice_0_0 slice_0
       (.din(din),
        .dout(slice_0_dout));
  system_slice_1_0 slice_1
       (.din(din),
        .dout(slice_1_dout));
  system_xlconcat_0_0 xlconcat_0
       (.In0(fifo_0_read_count),
        .In1(GMSK_Demod_nivel),
        .In2(GMSK_Demod_activo_confirmado),
        .In3(GMSK_Demod_piso_ruido_dbg),
        .In4(GMSK_Demod_dispersion_dbg),
        .In5(GMSK_Demod_activo_ext),
        .In6(xlconstant_0_dout),
        .In7(GMSK_Demod_pico_cont),
        .In8(GMSK_Demod_rafaga_info),
        .dout(dout));
  system_xlconstant_0_0 xlconstant_0
       (.dout(xlconstant_0_dout));
endmodule

(* CORE_GENERATION_INFO = "system,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=system,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=66,numReposBlks=59,numNonXlnxBlks=0,numHierBlks=7,maxHierDepth=3,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=42,numPkgbdBlks=0,bdsource=USER,\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"da_axi4_cnt\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"=1,\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"da_axi4_s2mm_cnt\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"=1,synth_mode=None}" *) (* HW_HANDOFF = "system.hwdef" *) 
module system
   (DDR_addr,
    DDR_ba,
    DDR_cas_n,
    DDR_ck_n,
    DDR_ck_p,
    DDR_cke,
    DDR_cs_n,
    DDR_dm,
    DDR_dq,
    DDR_dqs_n,
    DDR_dqs_p,
    DDR_odt,
    DDR_ras_n,
    DDR_reset_n,
    DDR_we_n,
    FIXED_IO_ddr_vrn,
    FIXED_IO_ddr_vrp,
    FIXED_IO_mio,
    FIXED_IO_ps_clk,
    FIXED_IO_ps_porb,
    FIXED_IO_ps_srstb,
    adc_clk_n_i,
    adc_clk_p_i,
    adc_csn_o,
    adc_dat_a_i,
    adc_dat_b_i,
    dac_clk_o,
    dac_dat_o,
    dac_pwm_o,
    dac_rst_o,
    dac_sel_o,
    dac_wrt_o,
    exp_n_tri_io,
    exp_p_tri_io,
    led_o);
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR ADDR" *) (* X_INTERFACE_MODE = "Master" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME DDR, AXI_ARBITRATION_SCHEME TDM, BURST_LENGTH 8, CAN_DEBUG false, CAS_LATENCY 11, CAS_WRITE_LATENCY 11, CS_ENABLED true, DATA_MASK_ENABLED true, DATA_WIDTH 8, MEMORY_TYPE COMPONENTS, MEM_ADDR_MAP ROW_COLUMN_BANK, SLOT Single, TIMEPERIOD_PS 1250" *) inout [14:0]DDR_addr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR BA" *) inout [2:0]DDR_ba;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR CAS_N" *) inout DDR_cas_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR CK_N" *) inout DDR_ck_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR CK_P" *) inout DDR_ck_p;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR CKE" *) inout DDR_cke;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR CS_N" *) inout DDR_cs_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR DM" *) inout [3:0]DDR_dm;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR DQ" *) inout [31:0]DDR_dq;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR DQS_N" *) inout [3:0]DDR_dqs_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR DQS_P" *) inout [3:0]DDR_dqs_p;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR ODT" *) inout DDR_odt;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR RAS_N" *) inout DDR_ras_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR RESET_N" *) inout DDR_reset_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR WE_N" *) inout DDR_we_n;
  (* X_INTERFACE_INFO = "xilinx.com:display_processing_system7:fixedio:1.0 FIXED_IO DDR_VRN" *) (* X_INTERFACE_MODE = "Master" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME FIXED_IO, CAN_DEBUG false" *) inout FIXED_IO_ddr_vrn;
  (* X_INTERFACE_INFO = "xilinx.com:display_processing_system7:fixedio:1.0 FIXED_IO DDR_VRP" *) inout FIXED_IO_ddr_vrp;
  (* X_INTERFACE_INFO = "xilinx.com:display_processing_system7:fixedio:1.0 FIXED_IO MIO" *) inout [53:0]FIXED_IO_mio;
  (* X_INTERFACE_INFO = "xilinx.com:display_processing_system7:fixedio:1.0 FIXED_IO PS_CLK" *) inout FIXED_IO_ps_clk;
  (* X_INTERFACE_INFO = "xilinx.com:display_processing_system7:fixedio:1.0 FIXED_IO PS_PORB" *) inout FIXED_IO_ps_porb;
  (* X_INTERFACE_INFO = "xilinx.com:display_processing_system7:fixedio:1.0 FIXED_IO PS_SRSTB" *) inout FIXED_IO_ps_srstb;
  input adc_clk_n_i;
  input adc_clk_p_i;
  output adc_csn_o;
  input [15:0]adc_dat_a_i;
  input [15:0]adc_dat_b_i;
  output dac_clk_o;
  output [13:0]dac_dat_o;
  output [3:0]dac_pwm_o;
  output dac_rst_o;
  output dac_sel_o;
  output dac_wrt_o;
  inout [7:0]exp_n_tri_io;
  output [1:0]exp_p_tri_io;
  output [7:0]led_o;

  wire [14:0]DDR_addr;
  wire [2:0]DDR_ba;
  wire DDR_cas_n;
  wire DDR_ck_n;
  wire DDR_ck_p;
  wire DDR_cke;
  wire DDR_cs_n;
  wire [3:0]DDR_dm;
  wire [31:0]DDR_dq;
  wire [3:0]DDR_dqs_n;
  wire [3:0]DDR_dqs_p;
  wire DDR_odt;
  wire DDR_ras_n;
  wire DDR_reset_n;
  wire DDR_we_n;
  wire FIXED_IO_ddr_vrn;
  wire FIXED_IO_ddr_vrp;
  wire [53:0]FIXED_IO_mio;
  wire FIXED_IO_ps_clk;
  wire FIXED_IO_ps_porb;
  wire FIXED_IO_ps_srstb;
  wire [31:0]S_AXIS_A_1_TDATA;
  wire S_AXIS_A_1_TVALID;
  wire adc_clk_n_i;
  wire adc_clk_p_i;
  wire adc_csn_o;
  wire [15:0]adc_dat_a_i;
  wire [15:0]adc_dat_b_i;
  wire [0:0]const_0_dout;
  wire dac_clk_o;
  wire [13:0]dac_dat_o;
  wire dac_rst_o;
  wire dac_sel_o;
  wire dac_wrt_o;
  wire [127:0]hub_0_cfg_data;
  wire pll_0_clk_out1;
  wire pll_0_clk_out2;
  wire pll_0_clk_out3;
  wire pll_0_locked;
  wire [31:0]ps_0_M_AXI_GP0_ARADDR;
  wire [11:0]ps_0_M_AXI_GP0_ARID;
  wire [3:0]ps_0_M_AXI_GP0_ARLEN;
  wire ps_0_M_AXI_GP0_ARREADY;
  wire ps_0_M_AXI_GP0_ARVALID;
  wire [31:0]ps_0_M_AXI_GP0_AWADDR;
  wire [11:0]ps_0_M_AXI_GP0_AWID;
  wire ps_0_M_AXI_GP0_AWREADY;
  wire ps_0_M_AXI_GP0_AWVALID;
  wire [11:0]ps_0_M_AXI_GP0_BID;
  wire ps_0_M_AXI_GP0_BREADY;
  wire ps_0_M_AXI_GP0_BVALID;
  wire [31:0]ps_0_M_AXI_GP0_RDATA;
  wire [11:0]ps_0_M_AXI_GP0_RID;
  wire ps_0_M_AXI_GP0_RLAST;
  wire ps_0_M_AXI_GP0_RREADY;
  wire ps_0_M_AXI_GP0_RVALID;
  wire [31:0]ps_0_M_AXI_GP0_WDATA;
  wire ps_0_M_AXI_GP0_WLAST;
  wire ps_0_M_AXI_GP0_WREADY;
  wire [3:0]ps_0_M_AXI_GP0_WSTRB;
  wire ps_0_M_AXI_GP0_WVALID;
  wire [31:0]ps_0_M_AXI_GP1_ARADDR;
  wire [11:0]ps_0_M_AXI_GP1_ARID;
  wire [3:0]ps_0_M_AXI_GP1_ARLEN;
  wire ps_0_M_AXI_GP1_ARREADY;
  wire ps_0_M_AXI_GP1_ARVALID;
  wire [31:0]ps_0_M_AXI_GP1_AWADDR;
  wire [11:0]ps_0_M_AXI_GP1_AWID;
  wire ps_0_M_AXI_GP1_AWREADY;
  wire ps_0_M_AXI_GP1_AWVALID;
  wire [11:0]ps_0_M_AXI_GP1_BID;
  wire ps_0_M_AXI_GP1_BREADY;
  wire ps_0_M_AXI_GP1_BVALID;
  wire [31:0]ps_0_M_AXI_GP1_RDATA;
  wire [11:0]ps_0_M_AXI_GP1_RID;
  wire ps_0_M_AXI_GP1_RLAST;
  wire ps_0_M_AXI_GP1_RREADY;
  wire ps_0_M_AXI_GP1_RVALID;
  wire [31:0]ps_0_M_AXI_GP1_WDATA;
  wire ps_0_M_AXI_GP1_WLAST;
  wire ps_0_M_AXI_GP1_WREADY;
  wire [3:0]ps_0_M_AXI_GP1_WSTRB;
  wire ps_0_M_AXI_GP1_WVALID;
  wire [0:0]rst_0_peripheral_aresetn;
  wire [159:0]rx_0_dout;
  wire [31:0]rx_0_m_axis_TDATA;
  wire rx_0_m_axis_TREADY;
  wire rx_0_m_axis_TVALID;
  wire [31:0]test_0_m_axi_ARADDR;
  wire [1:0]test_0_m_axi_ARBURST;
  wire [3:0]test_0_m_axi_ARCACHE;
  wire [2:0]test_0_m_axi_ARID;
  wire [3:0]test_0_m_axi_ARLEN;
  wire test_0_m_axi_ARREADY;
  wire [2:0]test_0_m_axi_ARSIZE;
  wire test_0_m_axi_ARVALID;
  wire [63:0]test_0_m_axi_RDATA;
  wire [5:0]test_0_m_axi_RID;
  wire test_0_m_axi_RLAST;
  wire test_0_m_axi_RREADY;
  wire test_0_m_axi_RVALID;
  wire [31:0]test_0_m_axis_0_TDATA;
  wire test_0_m_axis_0_TREADY;
  wire test_0_m_axis_0_TVALID;

  system_adc_0_0 adc_0
       (.aclk(pll_0_clk_out1),
        .adc_csn(adc_csn_o),
        .adc_dat_a(adc_dat_a_i),
        .adc_dat_b(adc_dat_b_i),
        .m_axis_tdata(S_AXIS_A_1_TDATA),
        .m_axis_tvalid(S_AXIS_A_1_TVALID));
  system_const_0_0 const_0
       (.dout(const_0_dout));
  system_dac_0_0 dac_0
       (.aclk(pll_0_clk_out1),
        .dac_clk(dac_clk_o),
        .dac_dat(dac_dat_o),
        .dac_rst(dac_rst_o),
        .dac_sel(dac_sel_o),
        .dac_wrt(dac_wrt_o),
        .ddr_clk(pll_0_clk_out2),
        .locked(pll_0_locked),
        .s_axis_tdata(test_0_m_axis_0_TDATA),
        .s_axis_tready(test_0_m_axis_0_TREADY),
        .s_axis_tvalid(test_0_m_axis_0_TVALID),
        .wrt_clk(pll_0_clk_out3));
  system_hub_0_0 hub_0
       (.aclk(pll_0_clk_out1),
        .aresetn(rst_0_peripheral_aresetn),
        .b00_bram_rdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b1,1'b0,1'b0,1'b0}),
        .b01_bram_rdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b1,1'b0,1'b0,1'b0}),
        .b02_bram_rdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b1,1'b0,1'b0,1'b0}),
        .b03_bram_rdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b1,1'b0,1'b0,1'b0}),
        .b04_bram_rdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b1,1'b0,1'b0,1'b0}),
        .b05_bram_rdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b1,1'b0,1'b0,1'b0}),
        .cfg_data(hub_0_cfg_data),
        .m00_axis_tready(1'b1),
        .m01_axis_tready(1'b1),
        .m02_axis_tready(1'b1),
        .m03_axis_tready(1'b1),
        .m04_axis_tready(1'b1),
        .m05_axis_tready(1'b1),
        .s00_axis_tdata(rx_0_m_axis_TDATA),
        .s00_axis_tready(rx_0_m_axis_TREADY),
        .s00_axis_tvalid(rx_0_m_axis_TVALID),
        .s01_axis_tdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s01_axis_tvalid(1'b0),
        .s02_axis_tdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s02_axis_tvalid(1'b0),
        .s03_axis_tdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s03_axis_tvalid(1'b0),
        .s04_axis_tdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s04_axis_tvalid(1'b0),
        .s05_axis_tdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s05_axis_tvalid(1'b0),
        .s_axi_araddr(ps_0_M_AXI_GP0_ARADDR),
        .s_axi_arid(ps_0_M_AXI_GP0_ARID),
        .s_axi_arlen(ps_0_M_AXI_GP0_ARLEN),
        .s_axi_arready(ps_0_M_AXI_GP0_ARREADY),
        .s_axi_arvalid(ps_0_M_AXI_GP0_ARVALID),
        .s_axi_awaddr(ps_0_M_AXI_GP0_AWADDR),
        .s_axi_awid(ps_0_M_AXI_GP0_AWID),
        .s_axi_awready(ps_0_M_AXI_GP0_AWREADY),
        .s_axi_awvalid(ps_0_M_AXI_GP0_AWVALID),
        .s_axi_bid(ps_0_M_AXI_GP0_BID),
        .s_axi_bready(ps_0_M_AXI_GP0_BREADY),
        .s_axi_bvalid(ps_0_M_AXI_GP0_BVALID),
        .s_axi_rdata(ps_0_M_AXI_GP0_RDATA),
        .s_axi_rid(ps_0_M_AXI_GP0_RID),
        .s_axi_rlast(ps_0_M_AXI_GP0_RLAST),
        .s_axi_rready(ps_0_M_AXI_GP0_RREADY),
        .s_axi_rvalid(ps_0_M_AXI_GP0_RVALID),
        .s_axi_wdata(ps_0_M_AXI_GP0_WDATA),
        .s_axi_wlast(ps_0_M_AXI_GP0_WLAST),
        .s_axi_wready(ps_0_M_AXI_GP0_WREADY),
        .s_axi_wstrb(ps_0_M_AXI_GP0_WSTRB),
        .s_axi_wvalid(ps_0_M_AXI_GP0_WVALID),
        .sts_data(rx_0_dout));
  system_pll_0_0 pll_0
       (.clk_in1_n(adc_clk_n_i),
        .clk_in1_p(adc_clk_p_i),
        .clk_out1(pll_0_clk_out1),
        .clk_out2(pll_0_clk_out2),
        .clk_out3(pll_0_clk_out3),
        .locked(pll_0_locked));
  (* BMM_INFO_PROCESSOR = "arm > system test_0/axi_bram_ctrl_0" *) 
  (* KEEP_HIERARCHY = "YES" *) 
  system_ps_0_0 ps_0
       (.DDR_Addr(DDR_addr),
        .DDR_BankAddr(DDR_ba),
        .DDR_CAS_n(DDR_cas_n),
        .DDR_CKE(DDR_cke),
        .DDR_CS_n(DDR_cs_n),
        .DDR_Clk(DDR_ck_p),
        .DDR_Clk_n(DDR_ck_n),
        .DDR_DM(DDR_dm),
        .DDR_DQ(DDR_dq),
        .DDR_DQS(DDR_dqs_p),
        .DDR_DQS_n(DDR_dqs_n),
        .DDR_DRSTB(DDR_reset_n),
        .DDR_ODT(DDR_odt),
        .DDR_RAS_n(DDR_ras_n),
        .DDR_VRN(FIXED_IO_ddr_vrn),
        .DDR_VRP(FIXED_IO_ddr_vrp),
        .DDR_WEB(DDR_we_n),
        .GPIO_I({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .MIO(FIXED_IO_mio),
        .M_AXI_GP0_ACLK(pll_0_clk_out1),
        .M_AXI_GP0_ARADDR(ps_0_M_AXI_GP0_ARADDR),
        .M_AXI_GP0_ARID(ps_0_M_AXI_GP0_ARID),
        .M_AXI_GP0_ARLEN(ps_0_M_AXI_GP0_ARLEN),
        .M_AXI_GP0_ARREADY(ps_0_M_AXI_GP0_ARREADY),
        .M_AXI_GP0_ARVALID(ps_0_M_AXI_GP0_ARVALID),
        .M_AXI_GP0_AWADDR(ps_0_M_AXI_GP0_AWADDR),
        .M_AXI_GP0_AWID(ps_0_M_AXI_GP0_AWID),
        .M_AXI_GP0_AWREADY(ps_0_M_AXI_GP0_AWREADY),
        .M_AXI_GP0_AWVALID(ps_0_M_AXI_GP0_AWVALID),
        .M_AXI_GP0_BID(ps_0_M_AXI_GP0_BID),
        .M_AXI_GP0_BREADY(ps_0_M_AXI_GP0_BREADY),
        .M_AXI_GP0_BRESP({1'b0,1'b0}),
        .M_AXI_GP0_BVALID(ps_0_M_AXI_GP0_BVALID),
        .M_AXI_GP0_RDATA(ps_0_M_AXI_GP0_RDATA),
        .M_AXI_GP0_RID(ps_0_M_AXI_GP0_RID),
        .M_AXI_GP0_RLAST(ps_0_M_AXI_GP0_RLAST),
        .M_AXI_GP0_RREADY(ps_0_M_AXI_GP0_RREADY),
        .M_AXI_GP0_RRESP({1'b0,1'b0}),
        .M_AXI_GP0_RVALID(ps_0_M_AXI_GP0_RVALID),
        .M_AXI_GP0_WDATA(ps_0_M_AXI_GP0_WDATA),
        .M_AXI_GP0_WLAST(ps_0_M_AXI_GP0_WLAST),
        .M_AXI_GP0_WREADY(ps_0_M_AXI_GP0_WREADY),
        .M_AXI_GP0_WSTRB(ps_0_M_AXI_GP0_WSTRB),
        .M_AXI_GP0_WVALID(ps_0_M_AXI_GP0_WVALID),
        .M_AXI_GP1_ACLK(pll_0_clk_out1),
        .M_AXI_GP1_ARADDR(ps_0_M_AXI_GP1_ARADDR),
        .M_AXI_GP1_ARID(ps_0_M_AXI_GP1_ARID),
        .M_AXI_GP1_ARLEN(ps_0_M_AXI_GP1_ARLEN),
        .M_AXI_GP1_ARREADY(ps_0_M_AXI_GP1_ARREADY),
        .M_AXI_GP1_ARVALID(ps_0_M_AXI_GP1_ARVALID),
        .M_AXI_GP1_AWADDR(ps_0_M_AXI_GP1_AWADDR),
        .M_AXI_GP1_AWID(ps_0_M_AXI_GP1_AWID),
        .M_AXI_GP1_AWREADY(ps_0_M_AXI_GP1_AWREADY),
        .M_AXI_GP1_AWVALID(ps_0_M_AXI_GP1_AWVALID),
        .M_AXI_GP1_BID(ps_0_M_AXI_GP1_BID),
        .M_AXI_GP1_BREADY(ps_0_M_AXI_GP1_BREADY),
        .M_AXI_GP1_BRESP({1'b0,1'b0}),
        .M_AXI_GP1_BVALID(ps_0_M_AXI_GP1_BVALID),
        .M_AXI_GP1_RDATA(ps_0_M_AXI_GP1_RDATA),
        .M_AXI_GP1_RID(ps_0_M_AXI_GP1_RID),
        .M_AXI_GP1_RLAST(ps_0_M_AXI_GP1_RLAST),
        .M_AXI_GP1_RREADY(ps_0_M_AXI_GP1_RREADY),
        .M_AXI_GP1_RRESP({1'b0,1'b0}),
        .M_AXI_GP1_RVALID(ps_0_M_AXI_GP1_RVALID),
        .M_AXI_GP1_WDATA(ps_0_M_AXI_GP1_WDATA),
        .M_AXI_GP1_WLAST(ps_0_M_AXI_GP1_WLAST),
        .M_AXI_GP1_WREADY(ps_0_M_AXI_GP1_WREADY),
        .M_AXI_GP1_WSTRB(ps_0_M_AXI_GP1_WSTRB),
        .M_AXI_GP1_WVALID(ps_0_M_AXI_GP1_WVALID),
        .PS_CLK(FIXED_IO_ps_clk),
        .PS_PORB(FIXED_IO_ps_porb),
        .PS_SRSTB(FIXED_IO_ps_srstb),
        .SPI0_MISO_I(1'b0),
        .SPI0_MOSI_I(1'b0),
        .SPI0_SCLK_I(1'b0),
        .SPI0_SS_I(1'b0),
        .S_AXI_HP0_ACLK(pll_0_clk_out1),
        .S_AXI_HP0_ARADDR(test_0_m_axi_ARADDR),
        .S_AXI_HP0_ARBURST(test_0_m_axi_ARBURST),
        .S_AXI_HP0_ARCACHE(test_0_m_axi_ARCACHE),
        .S_AXI_HP0_ARID({1'b0,1'b0,1'b0,test_0_m_axi_ARID}),
        .S_AXI_HP0_ARLEN(test_0_m_axi_ARLEN),
        .S_AXI_HP0_ARLOCK({1'b0,1'b0}),
        .S_AXI_HP0_ARPROT({1'b0,1'b0,1'b0}),
        .S_AXI_HP0_ARQOS({1'b0,1'b0,1'b0,1'b0}),
        .S_AXI_HP0_ARREADY(test_0_m_axi_ARREADY),
        .S_AXI_HP0_ARSIZE(test_0_m_axi_ARSIZE),
        .S_AXI_HP0_ARVALID(test_0_m_axi_ARVALID),
        .S_AXI_HP0_AWADDR({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .S_AXI_HP0_AWBURST({1'b0,1'b1}),
        .S_AXI_HP0_AWCACHE({1'b0,1'b0,1'b1,1'b1}),
        .S_AXI_HP0_AWID({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .S_AXI_HP0_AWLEN({1'b0,1'b0,1'b0,1'b0}),
        .S_AXI_HP0_AWLOCK({1'b0,1'b0}),
        .S_AXI_HP0_AWPROT({1'b0,1'b0,1'b0}),
        .S_AXI_HP0_AWQOS({1'b0,1'b0,1'b0,1'b0}),
        .S_AXI_HP0_AWSIZE({1'b0,1'b1,1'b1}),
        .S_AXI_HP0_AWVALID(1'b0),
        .S_AXI_HP0_BREADY(1'b0),
        .S_AXI_HP0_RDATA(test_0_m_axi_RDATA),
        .S_AXI_HP0_RDISSUECAP1_EN(1'b0),
        .S_AXI_HP0_RID(test_0_m_axi_RID),
        .S_AXI_HP0_RLAST(test_0_m_axi_RLAST),
        .S_AXI_HP0_RREADY(test_0_m_axi_RREADY),
        .S_AXI_HP0_RVALID(test_0_m_axi_RVALID),
        .S_AXI_HP0_WDATA({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .S_AXI_HP0_WID({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .S_AXI_HP0_WLAST(1'b0),
        .S_AXI_HP0_WRISSUECAP1_EN(1'b0),
        .S_AXI_HP0_WSTRB({1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1}),
        .S_AXI_HP0_WVALID(1'b0),
        .USB0_VBUS_PWRFAULT(1'b0));
  system_rst_0_0 rst_0
       (.aux_reset_in(1'b1),
        .dcm_locked(pll_0_locked),
        .ext_reset_in(const_0_dout),
        .mb_debug_sys_rst(1'b0),
        .peripheral_aresetn(rst_0_peripheral_aresetn),
        .slowest_sync_clk(pll_0_clk_out1));
  rx_0_imp_178AHDX rx_0
       (.aclk(pll_0_clk_out1),
        .aresetn_0(rst_0_peripheral_aresetn),
        .din(hub_0_cfg_data),
        .dout(rx_0_dout),
        .m_axis_tdata(rx_0_m_axis_TDATA),
        .m_axis_tready(rx_0_m_axis_TREADY),
        .m_axis_tvalid(rx_0_m_axis_TVALID),
        .s_axis_adc_tdata(S_AXIS_A_1_TDATA),
        .s_axis_adc_tvalid(S_AXIS_A_1_TVALID));
  test_0_imp_VH0MW1 test_0
       (.aclk(pll_0_clk_out1),
        .aresetn(rst_0_peripheral_aresetn),
        .m_axi_araddr(test_0_m_axi_ARADDR),
        .m_axi_arburst(test_0_m_axi_ARBURST),
        .m_axi_arcache(test_0_m_axi_ARCACHE),
        .m_axi_arid(test_0_m_axi_ARID),
        .m_axi_arlen(test_0_m_axi_ARLEN),
        .m_axi_arready(test_0_m_axi_ARREADY),
        .m_axi_arsize(test_0_m_axi_ARSIZE),
        .m_axi_arvalid(test_0_m_axi_ARVALID),
        .m_axi_rdata(test_0_m_axi_RDATA),
        .m_axi_rid(test_0_m_axi_RID),
        .m_axi_rlast(test_0_m_axi_RLAST),
        .m_axi_rready(test_0_m_axi_RREADY),
        .m_axi_rvalid(test_0_m_axi_RVALID),
        .m_axis_tdata(test_0_m_axis_0_TDATA),
        .m_axis_tready(test_0_m_axis_0_TREADY),
        .m_axis_tvalid(test_0_m_axis_0_TVALID),
        .s_axi_araddr(ps_0_M_AXI_GP1_ARADDR),
        .s_axi_arid(ps_0_M_AXI_GP1_ARID),
        .s_axi_arlen(ps_0_M_AXI_GP1_ARLEN),
        .s_axi_arready(ps_0_M_AXI_GP1_ARREADY),
        .s_axi_arvalid(ps_0_M_AXI_GP1_ARVALID),
        .s_axi_awaddr(ps_0_M_AXI_GP1_AWADDR),
        .s_axi_awid(ps_0_M_AXI_GP1_AWID),
        .s_axi_awready(ps_0_M_AXI_GP1_AWREADY),
        .s_axi_awvalid(ps_0_M_AXI_GP1_AWVALID),
        .s_axi_bid(ps_0_M_AXI_GP1_BID),
        .s_axi_bready(ps_0_M_AXI_GP1_BREADY),
        .s_axi_bvalid(ps_0_M_AXI_GP1_BVALID),
        .s_axi_rdata(ps_0_M_AXI_GP1_RDATA),
        .s_axi_rid(ps_0_M_AXI_GP1_RID),
        .s_axi_rlast(ps_0_M_AXI_GP1_RLAST),
        .s_axi_rready(ps_0_M_AXI_GP1_RREADY),
        .s_axi_rvalid(ps_0_M_AXI_GP1_RVALID),
        .s_axi_wdata(ps_0_M_AXI_GP1_WDATA),
        .s_axi_wlast(ps_0_M_AXI_GP1_WLAST),
        .s_axi_wready(ps_0_M_AXI_GP1_WREADY),
        .s_axi_wstrb(ps_0_M_AXI_GP1_WSTRB),
        .s_axi_wvalid(ps_0_M_AXI_GP1_WVALID));
endmodule

module test_0_imp_VH0MW1
   (aclk,
    aresetn,
    m_axi_araddr,
    m_axi_arburst,
    m_axi_arcache,
    m_axi_arid,
    m_axi_arlen,
    m_axi_arready,
    m_axi_arsize,
    m_axi_arvalid,
    m_axi_rdata,
    m_axi_rid,
    m_axi_rlast,
    m_axi_rready,
    m_axi_rvalid,
    m_axis_tdata,
    m_axis_tready,
    m_axis_tvalid,
    s_axi_araddr,
    s_axi_arid,
    s_axi_arlen,
    s_axi_arready,
    s_axi_arvalid,
    s_axi_awaddr,
    s_axi_awid,
    s_axi_awready,
    s_axi_awvalid,
    s_axi_bid,
    s_axi_bready,
    s_axi_bvalid,
    s_axi_rdata,
    s_axi_rid,
    s_axi_rlast,
    s_axi_rready,
    s_axi_rvalid,
    s_axi_wdata,
    s_axi_wlast,
    s_axi_wready,
    s_axi_wstrb,
    s_axi_wvalid);
  input aclk;
  input aresetn;
  output [31:0]m_axi_araddr;
  output [1:0]m_axi_arburst;
  output [3:0]m_axi_arcache;
  output [2:0]m_axi_arid;
  output [3:0]m_axi_arlen;
  input m_axi_arready;
  output [2:0]m_axi_arsize;
  output m_axi_arvalid;
  input [63:0]m_axi_rdata;
  input [5:0]m_axi_rid;
  input m_axi_rlast;
  output m_axi_rready;
  input m_axi_rvalid;
  output [31:0]m_axis_tdata;
  input m_axis_tready;
  output m_axis_tvalid;
  input [31:0]s_axi_araddr;
  input [11:0]s_axi_arid;
  input [3:0]s_axi_arlen;
  output s_axi_arready;
  input s_axi_arvalid;
  input [31:0]s_axi_awaddr;
  input [11:0]s_axi_awid;
  output s_axi_awready;
  input s_axi_awvalid;
  output [11:0]s_axi_bid;
  input s_axi_bready;
  output s_axi_bvalid;
  output [31:0]s_axi_rdata;
  output [11:0]s_axi_rid;
  output s_axi_rlast;
  input s_axi_rready;
  output s_axi_rvalid;
  input [31:0]s_axi_wdata;
  input s_axi_wlast;
  output s_axi_wready;
  input [3:0]s_axi_wstrb;
  input s_axi_wvalid;

  wire aclk;
  wire [31:0]addr_slice_dout;
  wire aresetn;
  wire [95:0]axi_hub_0_cfg_data;
  wire [31:0]axis_ram_reader_0_m_axis_TDATA;
  wire axis_ram_reader_0_m_axis_TREADY;
  wire axis_ram_reader_0_m_axis_TVALID;
  wire [17:0]axis_ram_reader_0_sts_data;
  wire [31:0]m_axi_araddr;
  wire [1:0]m_axi_arburst;
  wire [3:0]m_axi_arcache;
  wire [2:0]m_axi_arid;
  wire [3:0]m_axi_arlen;
  wire m_axi_arready;
  wire [2:0]m_axi_arsize;
  wire m_axi_arvalid;
  wire [63:0]m_axi_rdata;
  wire [5:0]m_axi_rid;
  wire m_axi_rlast;
  wire m_axi_rready;
  wire m_axi_rvalid;
  wire [31:0]m_axis_tdata;
  wire m_axis_tready;
  wire m_axis_tvalid;
  wire [0:0]rst_slice_dout;
  wire [31:0]s_axi_araddr;
  wire [11:0]s_axi_arid;
  wire [3:0]s_axi_arlen;
  wire s_axi_arready;
  wire s_axi_arvalid;
  wire [31:0]s_axi_awaddr;
  wire [11:0]s_axi_awid;
  wire s_axi_awready;
  wire s_axi_awvalid;
  wire [11:0]s_axi_bid;
  wire s_axi_bready;
  wire s_axi_bvalid;
  wire [31:0]s_axi_rdata;
  wire [11:0]s_axi_rid;
  wire s_axi_rlast;
  wire s_axi_rready;
  wire s_axi_rvalid;
  wire [31:0]s_axi_wdata;
  wire s_axi_wlast;
  wire s_axi_wready;
  wire [3:0]s_axi_wstrb;
  wire s_axi_wvalid;
  wire [17:0]size_slice_dout;

  system_port_slicer_0_8 addr_slice
       (.din(axi_hub_0_cfg_data),
        .dout(addr_slice_dout));
  system_axi_hub_0_0 axi_hub_0
       (.aclk(aclk),
        .aresetn(aresetn),
        .b00_bram_rdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b1,1'b0,1'b0,1'b0}),
        .b01_bram_rdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b1,1'b0,1'b0,1'b0}),
        .b02_bram_rdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b1,1'b0,1'b0,1'b0}),
        .b03_bram_rdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b1,1'b0,1'b0,1'b0}),
        .b04_bram_rdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b1,1'b0,1'b0,1'b0}),
        .b05_bram_rdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b1,1'b0,1'b0,1'b0}),
        .cfg_data(axi_hub_0_cfg_data),
        .m00_axis_tready(1'b1),
        .m01_axis_tready(1'b1),
        .m02_axis_tready(1'b1),
        .m03_axis_tready(1'b1),
        .m04_axis_tready(1'b1),
        .m05_axis_tready(1'b1),
        .s00_axis_tdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s00_axis_tvalid(1'b0),
        .s01_axis_tdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s01_axis_tvalid(1'b0),
        .s02_axis_tdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s02_axis_tvalid(1'b0),
        .s03_axis_tdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s03_axis_tvalid(1'b0),
        .s04_axis_tdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s04_axis_tvalid(1'b0),
        .s05_axis_tdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s05_axis_tvalid(1'b0),
        .s_axi_araddr(s_axi_araddr),
        .s_axi_arid(s_axi_arid),
        .s_axi_arlen(s_axi_arlen),
        .s_axi_arready(s_axi_arready),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awid(s_axi_awid),
        .s_axi_awready(s_axi_awready),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_bid(s_axi_bid),
        .s_axi_bready(s_axi_bready),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_rdata(s_axi_rdata),
        .s_axi_rid(s_axi_rid),
        .s_axi_rlast(s_axi_rlast),
        .s_axi_rready(s_axi_rready),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_wdata(s_axi_wdata),
        .s_axi_wlast(s_axi_wlast),
        .s_axi_wready(s_axi_wready),
        .s_axi_wstrb(s_axi_wstrb),
        .s_axi_wvalid(s_axi_wvalid),
        .sts_data({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,axis_ram_reader_0_sts_data}));
  system_axis_fifo_0_0 axis_fifo_0
       (.aclk(aclk),
        .aresetn(aresetn),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tready(m_axis_tready),
        .m_axis_tvalid(m_axis_tvalid),
        .s_axis_tdata(axis_ram_reader_0_m_axis_TDATA),
        .s_axis_tready(axis_ram_reader_0_m_axis_TREADY),
        .s_axis_tvalid(axis_ram_reader_0_m_axis_TVALID));
  system_axis_ram_reader_0_0 axis_ram_reader_0
       (.aclk(aclk),
        .aresetn(rst_slice_dout),
        .cfg_data(size_slice_dout),
        .m_axi_araddr(m_axi_araddr),
        .m_axi_arburst(m_axi_arburst),
        .m_axi_arcache(m_axi_arcache),
        .m_axi_arid(m_axi_arid),
        .m_axi_arlen(m_axi_arlen),
        .m_axi_arready(m_axi_arready),
        .m_axi_arsize(m_axi_arsize),
        .m_axi_arvalid(m_axi_arvalid),
        .m_axi_rdata(m_axi_rdata),
        .m_axi_rid(m_axi_rid[2:0]),
        .m_axi_rlast(m_axi_rlast),
        .m_axi_rready(m_axi_rready),
        .m_axi_rvalid(m_axi_rvalid),
        .m_axis_tdata(axis_ram_reader_0_m_axis_TDATA),
        .m_axis_tready(axis_ram_reader_0_m_axis_TREADY),
        .m_axis_tvalid(axis_ram_reader_0_m_axis_TVALID),
        .min_addr(addr_slice_dout),
        .sts_data(axis_ram_reader_0_sts_data));
  system_addr_slice_0 rst_slice
       (.din(axi_hub_0_cfg_data),
        .dout(rst_slice_dout));
  system_rst_slice_0 size_slice
       (.din(axi_hub_0_cfg_data),
        .dout(size_slice_dout));
endmodule
