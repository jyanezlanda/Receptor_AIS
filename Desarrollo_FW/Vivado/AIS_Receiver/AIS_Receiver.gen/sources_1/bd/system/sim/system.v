//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2025.2 (win64) Build 6299465 Fri Nov 14 19:35:11 GMT 2025
//Date        : Mon Jul 20 23:38:16 2026
//Host        : DESKTOP-KIRSTEN running 64-bit major release  (build 9200)
//Command     : generate_target system.bd
//Design      : system
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module rx_0_imp_178AHDX
   (aclk,
    aresetn,
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
    s_axi_wvalid,
    s_axis_adc_tdata,
    s_axis_adc_tvalid);
  input aclk;
  input aresetn;
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
  input [31:0]s_axis_adc_tdata;
  input s_axis_adc_tvalid;

  wire aclk;
  wire aresetn;
  wire [23:0]bcast_0_M00_AXIS_TDATA;
  wire [0:0]bcast_0_M00_AXIS_TVALID;
  wire [47:24]bcast_0_M01_AXIS_TDATA;
  wire [1:1]bcast_0_M01_AXIS_TVALID;
  wire [31:0]cic_0_M_AXIS_DATA_TDATA;
  wire cic_0_M_AXIS_DATA_TVALID;
  wire [31:0]cic_1_M_AXIS_DATA_TDATA;
  wire cic_1_M_AXIS_DATA_TVALID;
  wire [63:0]comb_0_M_AXIS_TDATA;
  wire comb_0_M_AXIS_TREADY;
  wire comb_0_M_AXIS_TVALID;
  wire [31:0]conv_0_M_AXIS_TDATA;
  wire conv_0_M_AXIS_TREADY;
  wire conv_0_M_AXIS_TVALID;
  wire [47:0]dds_0_M_AXIS_DATA_TDATA;
  wire dds_0_M_AXIS_DATA_TVALID;
  wire [31:0]fir_0_M_AXIS_DATA_TDATA;
  wire fir_0_M_AXIS_DATA_TVALID;
  wire [63:0]hub_0_cfg_data;
  wire [63:0]lfsr_0_m_axis_TDATA;
  wire lfsr_0_m_axis_TVALID;
  wire [63:0]mult_0_M_AXIS_DOUT_TDATA;
  wire mult_0_M_AXIS_DOUT_TVALID;
  wire [39:0]phase_0_m_axis_TDATA;
  wire phase_0_m_axis_TVALID;
  wire [31:0]rx_0_m_axis_TDATA;
  wire rx_0_m_axis_TREADY;
  wire rx_0_m_axis_TVALID;
  wire [15:0]rx_0_read_count;
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
  wire [31:0]s_axis_adc_tdata;
  wire s_axis_adc_tvalid;
  wire [0:0]slice_0_dout;
  wire [39:0]slice_1_dout;

  system_bcast_0_1 bcast_0
       (.aclk(aclk),
        .aresetn(aresetn),
        .m_axis_tdata({bcast_0_M01_AXIS_TDATA,bcast_0_M00_AXIS_TDATA}),
        .m_axis_tvalid({bcast_0_M01_AXIS_TVALID,bcast_0_M00_AXIS_TVALID}),
        .s_axis_tdata(mult_0_M_AXIS_DOUT_TDATA),
        .s_axis_tvalid(mult_0_M_AXIS_DOUT_TVALID));
  system_cic_0_0 cic_0
       (.aclk(aclk),
        .aresetn(aresetn),
        .m_axis_data_tdata(cic_0_M_AXIS_DATA_TDATA),
        .m_axis_data_tvalid(cic_0_M_AXIS_DATA_TVALID),
        .s_axis_data_tdata(bcast_0_M00_AXIS_TDATA),
        .s_axis_data_tvalid(bcast_0_M00_AXIS_TVALID));
  system_cic_0_1 cic_1
       (.aclk(aclk),
        .aresetn(aresetn),
        .m_axis_data_tdata(cic_1_M_AXIS_DATA_TDATA),
        .m_axis_data_tvalid(cic_1_M_AXIS_DATA_TVALID),
        .s_axis_data_tdata(bcast_0_M01_AXIS_TDATA),
        .s_axis_data_tvalid(bcast_0_M01_AXIS_TVALID));
  system_comb_0_1 comb_0
       (.aclk(aclk),
        .aresetn(aresetn),
        .m_axis_tdata(comb_0_M_AXIS_TDATA),
        .m_axis_tready(comb_0_M_AXIS_TREADY),
        .m_axis_tvalid(comb_0_M_AXIS_TVALID),
        .s_axis_tdata({cic_1_M_AXIS_DATA_TDATA,cic_0_M_AXIS_DATA_TDATA}),
        .s_axis_tvalid({cic_1_M_AXIS_DATA_TVALID,cic_0_M_AXIS_DATA_TVALID}));
  system_conv_0_0 conv_0
       (.aclk(aclk),
        .aresetn(aresetn),
        .m_axis_tdata(conv_0_M_AXIS_TDATA),
        .m_axis_tready(conv_0_M_AXIS_TREADY),
        .m_axis_tvalid(conv_0_M_AXIS_TVALID),
        .s_axis_tdata(comb_0_M_AXIS_TDATA),
        .s_axis_tready(comb_0_M_AXIS_TREADY),
        .s_axis_tvalid(comb_0_M_AXIS_TVALID));
  /* Enter Comments here */
  system_fifo_0_0 fifo_0
       (.aclk(aclk),
        .aresetn(slice_0_dout),
        .m_axis_tdata(rx_0_m_axis_TDATA),
        .m_axis_tready(rx_0_m_axis_TREADY),
        .m_axis_tvalid(rx_0_m_axis_TVALID),
        .read_count(rx_0_read_count),
        .s_axis_tdata(fir_0_M_AXIS_DATA_TDATA),
        .s_axis_tvalid(fir_0_M_AXIS_DATA_TVALID));
  system_fir_0_0 fir_0
       (.aclk(aclk),
        .aresetn(aresetn),
        .m_axis_data_tdata(fir_0_M_AXIS_DATA_TDATA),
        .m_axis_data_tvalid(fir_0_M_AXIS_DATA_TVALID),
        .s_axis_data_tdata(conv_0_M_AXIS_TDATA),
        .s_axis_data_tready(conv_0_M_AXIS_TREADY),
        .s_axis_data_tvalid(conv_0_M_AXIS_TVALID));
  system_hub_0_0 hub_0
       (.aclk(aclk),
        .aresetn(aresetn),
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
        .sts_data({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,rx_0_read_count}));
  system_lfsr_0_0 lfsr_0
       (.aclk(aclk),
        .aresetn(aresetn),
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
       (.din(hub_0_cfg_data),
        .dout(slice_0_dout));
  system_slice_1_0 slice_1
       (.din(hub_0_cfg_data),
        .dout(slice_1_dout));
endmodule

(* CORE_GENERATION_INFO = "system,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=system,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=28,numReposBlks=26,numNonXlnxBlks=0,numHierBlks=2,maxHierDepth=1,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=15,numPkgbdBlks=0,bdsource=USER,\"\"\"\"\"\"\"\"\"da_axi4_cnt\"\"\"\"\"\"\"\"\"=1,\"\"\"\"\"\"\"\"\"da_axi4_s2mm_cnt\"\"\"\"\"\"\"\"\"=1,synth_mode=None}" *) (* HW_HANDOFF = "system.hwdef" *) 
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
    adc_enc_n_o,
    adc_enc_p_o,
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
  output adc_enc_n_o;
  output adc_enc_p_o;
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
  wire [31:0]S00_AXI_1_ARADDR;
  wire [11:0]S00_AXI_1_ARID;
  wire [3:0]S00_AXI_1_ARLEN;
  wire S00_AXI_1_ARREADY;
  wire S00_AXI_1_ARVALID;
  wire [31:0]S00_AXI_1_AWADDR;
  wire [11:0]S00_AXI_1_AWID;
  wire S00_AXI_1_AWREADY;
  wire S00_AXI_1_AWVALID;
  wire [11:0]S00_AXI_1_BID;
  wire S00_AXI_1_BREADY;
  wire S00_AXI_1_BVALID;
  wire [31:0]S00_AXI_1_RDATA;
  wire [11:0]S00_AXI_1_RID;
  wire S00_AXI_1_RLAST;
  wire S00_AXI_1_RREADY;
  wire S00_AXI_1_RVALID;
  wire [31:0]S00_AXI_1_WDATA;
  wire S00_AXI_1_WLAST;
  wire S00_AXI_1_WREADY;
  wire [3:0]S00_AXI_1_WSTRB;
  wire S00_AXI_1_WVALID;
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
  wire [0:0]rst_0_peripheral_aresetn;
  wire [31:0]test_0_m_axi_ram_ARADDR;
  wire [1:0]test_0_m_axi_ram_ARBURST;
  wire [3:0]test_0_m_axi_ram_ARCACHE;
  wire [2:0]test_0_m_axi_ram_ARID;
  wire [3:0]test_0_m_axi_ram_ARLEN;
  wire test_0_m_axi_ram_ARREADY;
  wire [2:0]test_0_m_axi_ram_ARSIZE;
  wire test_0_m_axi_ram_ARVALID;
  wire [63:0]test_0_m_axi_ram_RDATA;
  wire [5:0]test_0_m_axi_ram_RID;
  wire test_0_m_axi_ram_RLAST;
  wire test_0_m_axi_ram_RREADY;
  wire test_0_m_axi_ram_RVALID;
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
        .M_AXI_GP1_ARADDR(S00_AXI_1_ARADDR),
        .M_AXI_GP1_ARID(S00_AXI_1_ARID),
        .M_AXI_GP1_ARLEN(S00_AXI_1_ARLEN),
        .M_AXI_GP1_ARREADY(S00_AXI_1_ARREADY),
        .M_AXI_GP1_ARVALID(S00_AXI_1_ARVALID),
        .M_AXI_GP1_AWADDR(S00_AXI_1_AWADDR),
        .M_AXI_GP1_AWID(S00_AXI_1_AWID),
        .M_AXI_GP1_AWREADY(S00_AXI_1_AWREADY),
        .M_AXI_GP1_AWVALID(S00_AXI_1_AWVALID),
        .M_AXI_GP1_BID(S00_AXI_1_BID),
        .M_AXI_GP1_BREADY(S00_AXI_1_BREADY),
        .M_AXI_GP1_BRESP({1'b0,1'b0}),
        .M_AXI_GP1_BVALID(S00_AXI_1_BVALID),
        .M_AXI_GP1_RDATA(S00_AXI_1_RDATA),
        .M_AXI_GP1_RID(S00_AXI_1_RID),
        .M_AXI_GP1_RLAST(S00_AXI_1_RLAST),
        .M_AXI_GP1_RREADY(S00_AXI_1_RREADY),
        .M_AXI_GP1_RRESP({1'b0,1'b0}),
        .M_AXI_GP1_RVALID(S00_AXI_1_RVALID),
        .M_AXI_GP1_WDATA(S00_AXI_1_WDATA),
        .M_AXI_GP1_WLAST(S00_AXI_1_WLAST),
        .M_AXI_GP1_WREADY(S00_AXI_1_WREADY),
        .M_AXI_GP1_WSTRB(S00_AXI_1_WSTRB),
        .M_AXI_GP1_WVALID(S00_AXI_1_WVALID),
        .PS_CLK(FIXED_IO_ps_clk),
        .PS_PORB(FIXED_IO_ps_porb),
        .PS_SRSTB(FIXED_IO_ps_srstb),
        .SPI0_MISO_I(1'b0),
        .SPI0_MOSI_I(1'b0),
        .SPI0_SCLK_I(1'b0),
        .SPI0_SS_I(1'b0),
        .S_AXI_HP0_ACLK(pll_0_clk_out1),
        .S_AXI_HP0_ARADDR(test_0_m_axi_ram_ARADDR),
        .S_AXI_HP0_ARBURST(test_0_m_axi_ram_ARBURST),
        .S_AXI_HP0_ARCACHE(test_0_m_axi_ram_ARCACHE),
        .S_AXI_HP0_ARID({1'b0,1'b0,1'b0,test_0_m_axi_ram_ARID}),
        .S_AXI_HP0_ARLEN(test_0_m_axi_ram_ARLEN),
        .S_AXI_HP0_ARLOCK({1'b0,1'b0}),
        .S_AXI_HP0_ARPROT({1'b0,1'b0,1'b0}),
        .S_AXI_HP0_ARQOS({1'b0,1'b0,1'b0,1'b0}),
        .S_AXI_HP0_ARREADY(test_0_m_axi_ram_ARREADY),
        .S_AXI_HP0_ARSIZE(test_0_m_axi_ram_ARSIZE),
        .S_AXI_HP0_ARVALID(test_0_m_axi_ram_ARVALID),
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
        .S_AXI_HP0_RDATA(test_0_m_axi_ram_RDATA),
        .S_AXI_HP0_RDISSUECAP1_EN(1'b0),
        .S_AXI_HP0_RID(test_0_m_axi_ram_RID),
        .S_AXI_HP0_RLAST(test_0_m_axi_ram_RLAST),
        .S_AXI_HP0_RREADY(test_0_m_axi_ram_RREADY),
        .S_AXI_HP0_RVALID(test_0_m_axi_ram_RVALID),
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
        .aresetn(rst_0_peripheral_aresetn),
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
        .s_axis_adc_tdata(S_AXIS_A_1_TDATA),
        .s_axis_adc_tvalid(S_AXIS_A_1_TVALID));
  test_0_imp_VH0MW1 test_0
       (.aclk(pll_0_clk_out1),
        .aresetn(rst_0_peripheral_aresetn),
        .m_axi_ram_araddr(test_0_m_axi_ram_ARADDR),
        .m_axi_ram_arburst(test_0_m_axi_ram_ARBURST),
        .m_axi_ram_arcache(test_0_m_axi_ram_ARCACHE),
        .m_axi_ram_arid(test_0_m_axi_ram_ARID),
        .m_axi_ram_arlen(test_0_m_axi_ram_ARLEN),
        .m_axi_ram_arready(test_0_m_axi_ram_ARREADY),
        .m_axi_ram_arsize(test_0_m_axi_ram_ARSIZE),
        .m_axi_ram_arvalid(test_0_m_axi_ram_ARVALID),
        .m_axi_ram_rdata(test_0_m_axi_ram_RDATA),
        .m_axi_ram_rid(test_0_m_axi_ram_RID),
        .m_axi_ram_rlast(test_0_m_axi_ram_RLAST),
        .m_axi_ram_rready(test_0_m_axi_ram_RREADY),
        .m_axi_ram_rvalid(test_0_m_axi_ram_RVALID),
        .m_axis_fifo_tdata(test_0_m_axis_0_TDATA),
        .m_axis_fifo_tready(test_0_m_axis_0_TREADY),
        .m_axis_fifo_tvalid(test_0_m_axis_0_TVALID),
        .s_axi_0_araddr(S00_AXI_1_ARADDR),
        .s_axi_0_arid(S00_AXI_1_ARID),
        .s_axi_0_arlen(S00_AXI_1_ARLEN),
        .s_axi_0_arready(S00_AXI_1_ARREADY),
        .s_axi_0_arvalid(S00_AXI_1_ARVALID),
        .s_axi_0_awaddr(S00_AXI_1_AWADDR),
        .s_axi_0_awid(S00_AXI_1_AWID),
        .s_axi_0_awready(S00_AXI_1_AWREADY),
        .s_axi_0_awvalid(S00_AXI_1_AWVALID),
        .s_axi_0_bid(S00_AXI_1_BID),
        .s_axi_0_bready(S00_AXI_1_BREADY),
        .s_axi_0_bvalid(S00_AXI_1_BVALID),
        .s_axi_0_rdata(S00_AXI_1_RDATA),
        .s_axi_0_rid(S00_AXI_1_RID),
        .s_axi_0_rlast(S00_AXI_1_RLAST),
        .s_axi_0_rready(S00_AXI_1_RREADY),
        .s_axi_0_rvalid(S00_AXI_1_RVALID),
        .s_axi_0_wdata(S00_AXI_1_WDATA),
        .s_axi_0_wlast(S00_AXI_1_WLAST),
        .s_axi_0_wready(S00_AXI_1_WREADY),
        .s_axi_0_wstrb(S00_AXI_1_WSTRB),
        .s_axi_0_wvalid(S00_AXI_1_WVALID));
endmodule

module test_0_imp_VH0MW1
   (aclk,
    aresetn,
    m_axi_ram_araddr,
    m_axi_ram_arburst,
    m_axi_ram_arcache,
    m_axi_ram_arid,
    m_axi_ram_arlen,
    m_axi_ram_arready,
    m_axi_ram_arsize,
    m_axi_ram_arvalid,
    m_axi_ram_rdata,
    m_axi_ram_rid,
    m_axi_ram_rlast,
    m_axi_ram_rready,
    m_axi_ram_rvalid,
    m_axis_fifo_tdata,
    m_axis_fifo_tready,
    m_axis_fifo_tvalid,
    s_axi_0_araddr,
    s_axi_0_arid,
    s_axi_0_arlen,
    s_axi_0_arready,
    s_axi_0_arvalid,
    s_axi_0_awaddr,
    s_axi_0_awid,
    s_axi_0_awready,
    s_axi_0_awvalid,
    s_axi_0_bid,
    s_axi_0_bready,
    s_axi_0_bvalid,
    s_axi_0_rdata,
    s_axi_0_rid,
    s_axi_0_rlast,
    s_axi_0_rready,
    s_axi_0_rvalid,
    s_axi_0_wdata,
    s_axi_0_wlast,
    s_axi_0_wready,
    s_axi_0_wstrb,
    s_axi_0_wvalid);
  input aclk;
  input aresetn;
  output [31:0]m_axi_ram_araddr;
  output [1:0]m_axi_ram_arburst;
  output [3:0]m_axi_ram_arcache;
  output [2:0]m_axi_ram_arid;
  output [3:0]m_axi_ram_arlen;
  input m_axi_ram_arready;
  output [2:0]m_axi_ram_arsize;
  output m_axi_ram_arvalid;
  input [63:0]m_axi_ram_rdata;
  input [5:0]m_axi_ram_rid;
  input m_axi_ram_rlast;
  output m_axi_ram_rready;
  input m_axi_ram_rvalid;
  output [31:0]m_axis_fifo_tdata;
  input m_axis_fifo_tready;
  output m_axis_fifo_tvalid;
  input [31:0]s_axi_0_araddr;
  input [11:0]s_axi_0_arid;
  input [3:0]s_axi_0_arlen;
  output s_axi_0_arready;
  input s_axi_0_arvalid;
  input [31:0]s_axi_0_awaddr;
  input [11:0]s_axi_0_awid;
  output s_axi_0_awready;
  input s_axi_0_awvalid;
  output [11:0]s_axi_0_bid;
  input s_axi_0_bready;
  output s_axi_0_bvalid;
  output [31:0]s_axi_0_rdata;
  output [11:0]s_axi_0_rid;
  output s_axi_0_rlast;
  input s_axi_0_rready;
  output s_axi_0_rvalid;
  input [31:0]s_axi_0_wdata;
  input s_axi_0_wlast;
  output s_axi_0_wready;
  input [3:0]s_axi_0_wstrb;
  input s_axi_0_wvalid;

  wire aclk;
  wire [31:0]addr_slice_dout;
  wire aresetn;
  wire [95:0]axi_hub_0_cfg_data;
  wire [31:0]axis_ram_reader_1_m_axis_TDATA;
  wire axis_ram_reader_1_m_axis_TREADY;
  wire axis_ram_reader_1_m_axis_TVALID;
  wire [17:0]axis_ram_reader_1_sts_data;
  wire [31:0]m_axi_ram_araddr;
  wire [1:0]m_axi_ram_arburst;
  wire [3:0]m_axi_ram_arcache;
  wire [2:0]m_axi_ram_arid;
  wire [3:0]m_axi_ram_arlen;
  wire m_axi_ram_arready;
  wire [2:0]m_axi_ram_arsize;
  wire m_axi_ram_arvalid;
  wire [63:0]m_axi_ram_rdata;
  wire [5:0]m_axi_ram_rid;
  wire m_axi_ram_rlast;
  wire m_axi_ram_rready;
  wire m_axi_ram_rvalid;
  wire [31:0]m_axis_fifo_tdata;
  wire m_axis_fifo_tready;
  wire m_axis_fifo_tvalid;
  wire [31:0]s_axi_0_araddr;
  wire [11:0]s_axi_0_arid;
  wire [3:0]s_axi_0_arlen;
  wire s_axi_0_arready;
  wire s_axi_0_arvalid;
  wire [31:0]s_axi_0_awaddr;
  wire [11:0]s_axi_0_awid;
  wire s_axi_0_awready;
  wire s_axi_0_awvalid;
  wire [11:0]s_axi_0_bid;
  wire s_axi_0_bready;
  wire s_axi_0_bvalid;
  wire [31:0]s_axi_0_rdata;
  wire [11:0]s_axi_0_rid;
  wire s_axi_0_rlast;
  wire s_axi_0_rready;
  wire s_axi_0_rvalid;
  wire [31:0]s_axi_0_wdata;
  wire s_axi_0_wlast;
  wire s_axi_0_wready;
  wire [3:0]s_axi_0_wstrb;
  wire s_axi_0_wvalid;
  wire [17:0]size_slice_dout;
  wire [0:0]slicer_reset_dout;

  system_slicer_reset_0 addr_slice
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
        .s_axi_araddr(s_axi_0_araddr),
        .s_axi_arid(s_axi_0_arid),
        .s_axi_arlen(s_axi_0_arlen),
        .s_axi_arready(s_axi_0_arready),
        .s_axi_arvalid(s_axi_0_arvalid),
        .s_axi_awaddr(s_axi_0_awaddr),
        .s_axi_awid(s_axi_0_awid),
        .s_axi_awready(s_axi_0_awready),
        .s_axi_awvalid(s_axi_0_awvalid),
        .s_axi_bid(s_axi_0_bid),
        .s_axi_bready(s_axi_0_bready),
        .s_axi_bvalid(s_axi_0_bvalid),
        .s_axi_rdata(s_axi_0_rdata),
        .s_axi_rid(s_axi_0_rid),
        .s_axi_rlast(s_axi_0_rlast),
        .s_axi_rready(s_axi_0_rready),
        .s_axi_rvalid(s_axi_0_rvalid),
        .s_axi_wdata(s_axi_0_wdata),
        .s_axi_wlast(s_axi_0_wlast),
        .s_axi_wready(s_axi_0_wready),
        .s_axi_wstrb(s_axi_0_wstrb),
        .s_axi_wvalid(s_axi_0_wvalid),
        .sts_data({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,axis_ram_reader_1_sts_data}));
  system_axis_fifo_0_1 axis_fifo_0
       (.aclk(aclk),
        .aresetn(aresetn),
        .m_axis_tdata(m_axis_fifo_tdata),
        .m_axis_tready(m_axis_fifo_tready),
        .m_axis_tvalid(m_axis_fifo_tvalid),
        .s_axis_tdata(axis_ram_reader_1_m_axis_TDATA),
        .s_axis_tready(axis_ram_reader_1_m_axis_TREADY),
        .s_axis_tvalid(axis_ram_reader_1_m_axis_TVALID));
  system_axis_ram_reader_1_0 axis_ram_reader_0
       (.aclk(aclk),
        .aresetn(slicer_reset_dout),
        .cfg_data(size_slice_dout),
        .m_axi_araddr(m_axi_ram_araddr),
        .m_axi_arburst(m_axi_ram_arburst),
        .m_axi_arcache(m_axi_ram_arcache),
        .m_axi_arid(m_axi_ram_arid),
        .m_axi_arlen(m_axi_ram_arlen),
        .m_axi_arready(m_axi_ram_arready),
        .m_axi_arsize(m_axi_ram_arsize),
        .m_axi_arvalid(m_axi_ram_arvalid),
        .m_axi_rdata(m_axi_ram_rdata),
        .m_axi_rid(m_axi_ram_rid[2:0]),
        .m_axi_rlast(m_axi_ram_rlast),
        .m_axi_rready(m_axi_ram_rready),
        .m_axi_rvalid(m_axi_ram_rvalid),
        .m_axis_tdata(axis_ram_reader_1_m_axis_TDATA),
        .m_axis_tready(axis_ram_reader_1_m_axis_TREADY),
        .m_axis_tvalid(axis_ram_reader_1_m_axis_TVALID),
        .min_addr(addr_slice_dout),
        .sts_data(axis_ram_reader_1_sts_data));
  system_port_slicer_0_0 rst_slice
       (.din(axi_hub_0_cfg_data),
        .dout(slicer_reset_dout));
  system_rst_slice_0 size_slice
       (.din(axi_hub_0_cfg_data),
        .dout(size_slice_dout));
endmodule
