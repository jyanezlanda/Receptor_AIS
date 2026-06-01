//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2025.2 (win64) Build 6299465 Fri Nov 14 19:35:11 GMT 2025
//Date        : Sun May 31 20:00:13 2026
//Host        : DESKTOP-KIRSTEN running 64-bit major release  (build 9200)
//Command     : generate_target system.bd
//Design      : system
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module rx_0_imp_178AHDX
   (aclk,
    aresetn,
    din,
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
  input [31:0]din;
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
  wire [13:0]adc_slicer_I_dout;
  wire [13:0]adc_slicer_Q_dout;
  wire aresetn;
  wire [63:0]axis_combiner_0_M_AXIS_TDATA;
  wire axis_combiner_0_M_AXIS_TREADY;
  wire axis_combiner_0_M_AXIS_TVALID;
  wire [24:0]c_addsub_0_S;
  wire [24:0]c_addsub_1_S;
  wire [31:0]cic_I_M_AXIS_DATA_TDATA;
  wire cic_I_M_AXIS_DATA_TVALID;
  wire [31:0]cic_Q_M_AXIS_DATA_TDATA;
  wire cic_Q_M_AXIS_DATA_TVALID;
  wire [0:0]const_0_dout;
  wire [31:0]conv_0_M_AXIS_TDATA;
  wire conv_0_M_AXIS_TREADY;
  wire conv_0_M_AXIS_TVALID;
  wire [511:0]conv_1_M_AXIS_TDATA;
  wire conv_1_M_AXIS_TREADY;
  wire conv_1_M_AXIS_TVALID;
  wire [31:0]conv_2_M_AXIS_TDATA;
  wire conv_2_M_AXIS_TREADY;
  wire conv_2_M_AXIS_TVALID;
  wire [47:0]dds_0_dout;
  wire [47:0]dds_1_dout;
  wire [23:0]dds_slicer_1_dout;
  wire [23:0]dds_slicer_cos_2_dout;
  wire [23:0]dds_slicer_sin_1_dout;
  wire [31:0]din;
  wire [511:0]fifo_0_m_axis_TDATA;
  wire fifo_0_m_axis_TREADY;
  wire fifo_0_m_axis_TVALID;
  wire [15:0]fifo_0_read_count;
  wire [31:0]fir_0_M_AXIS_DATA_TDATA;
  wire fir_0_M_AXIS_DATA_TVALID;
  wire [39:0]fir_1_M_AXIS_DATA_TDATA;
  wire fir_1_M_AXIS_DATA_TVALID;
  wire [31:0]fp_0_M_AXIS_RESULT_TDATA;
  wire fp_0_M_AXIS_RESULT_TREADY;
  wire fp_0_M_AXIS_RESULT_TVALID;
  wire [63:0]hub_0_cfg_data;
  wire [23:0]mult_I_cos_P;
  wire [23:0]mult_I_sin_P;
  wire [23:0]mult_Q_asin_P;
  wire [23:0]mult_Q_cos_P;
  wire [31:0]port_slicer_0_dout;
  wire [23:0]port_slicer_0_dout1;
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
  wire [0:0]slice_0_dout;
  wire [23:0]subset_0_M_AXIS_TDATA;
  wire subset_0_M_AXIS_TVALID;
  wire [31:0]subset_1_M_AXIS_TDATA;
  wire subset_1_M_AXIS_TVALID;

  system_port_slicer_0_0 adc_slicer_I
       (.din(din),
        .dout(adc_slicer_I_dout));
  system_adc_slicer_0_0 adc_slicer_Q
       (.din(din),
        .dout(adc_slicer_Q_dout));
  system_axis_combiner_0_0 axis_combiner_0
       (.aclk(aclk),
        .aresetn(aresetn),
        .m_axis_tdata(axis_combiner_0_M_AXIS_TDATA),
        .m_axis_tready(axis_combiner_0_M_AXIS_TREADY),
        .m_axis_tvalid(axis_combiner_0_M_AXIS_TVALID),
        .s_axis_tdata({cic_Q_M_AXIS_DATA_TDATA,cic_I_M_AXIS_DATA_TDATA}),
        .s_axis_tvalid({cic_Q_M_AXIS_DATA_TVALID,cic_I_M_AXIS_DATA_TVALID}));
  system_c_addsub_0_0 c_addsub_0
       (.A(mult_I_cos_P),
        .B(mult_I_sin_P),
        .CLK(aclk),
        .S(c_addsub_0_S));
  system_c_addsub_0_1 c_addsub_1
       (.A(mult_Q_cos_P),
        .B(mult_Q_asin_P),
        .CLK(aclk),
        .S(c_addsub_1_S));
  system_port_slicer_0_1 cfg_slicer_0
       (.din(hub_0_cfg_data),
        .dout(port_slicer_0_dout));
  system_cic_0_0 cic_I
       (.aclk(aclk),
        .aresetn(aresetn),
        .m_axis_data_tdata(cic_I_M_AXIS_DATA_TDATA),
        .m_axis_data_tvalid(cic_I_M_AXIS_DATA_TVALID),
        .s_axis_data_tdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,c_addsub_0_S}),
        .s_axis_data_tvalid(const_0_dout));
  system_cic_10_0 cic_Q
       (.aclk(aclk),
        .aresetn(aresetn),
        .m_axis_data_tdata(cic_Q_M_AXIS_DATA_TDATA),
        .m_axis_data_tvalid(cic_Q_M_AXIS_DATA_TVALID),
        .s_axis_data_tdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,c_addsub_1_S}),
        .s_axis_data_tvalid(const_0_dout));
  system_const_0_1 const_0
       (.dout(const_0_dout));
  system_conv_0_0 conv_0
       (.aclk(aclk),
        .aresetn(aresetn),
        .m_axis_tdata(conv_0_M_AXIS_TDATA),
        .m_axis_tready(conv_0_M_AXIS_TREADY),
        .m_axis_tvalid(conv_0_M_AXIS_TVALID),
        .s_axis_tdata(axis_combiner_0_M_AXIS_TDATA),
        .s_axis_tready(axis_combiner_0_M_AXIS_TREADY),
        .s_axis_tvalid(axis_combiner_0_M_AXIS_TVALID));
  system_conv_1_0 conv_1
       (.aclk(aclk),
        .aresetn(aresetn),
        .m_axis_tdata(conv_1_M_AXIS_TDATA),
        .m_axis_tready(conv_1_M_AXIS_TREADY),
        .m_axis_tvalid(conv_1_M_AXIS_TVALID),
        .s_axis_tdata(fp_0_M_AXIS_RESULT_TDATA),
        .s_axis_tready(fp_0_M_AXIS_RESULT_TREADY),
        .s_axis_tvalid(fp_0_M_AXIS_RESULT_TVALID));
  system_conv_2_0 conv_2
       (.aclk(aclk),
        .aresetn(slice_0_dout),
        .m_axis_tdata(conv_2_M_AXIS_TDATA),
        .m_axis_tready(conv_2_M_AXIS_TREADY),
        .m_axis_tvalid(conv_2_M_AXIS_TVALID),
        .s_axis_tdata(fifo_0_m_axis_TDATA),
        .s_axis_tready(fifo_0_m_axis_TREADY),
        .s_axis_tvalid(fifo_0_m_axis_TVALID));
  system_dds_0_0 dds_0
       (.aclk(aclk),
        .aresetn(aresetn),
        .dout(dds_0_dout),
        .pinc(port_slicer_0_dout));
  system_dds_0_1 dds_1
       (.aclk(aclk),
        .aresetn(aresetn),
        .dout(dds_1_dout),
        .pinc(port_slicer_0_dout));
  system_port_slicer_0_3 dds_slicer_asin_1
       (.din(dds_1_dout),
        .dout(dds_slicer_sin_1_dout));
  system_port_slicer_0_2 dds_slicer_cos_0
       (.din(dds_0_dout),
        .dout(port_slicer_0_dout1));
  system_dds_slicer_0_0 dds_slicer_cos_1
       (.din(dds_1_dout),
        .dout(dds_slicer_1_dout));
  system_dds_slicer_cos_0_0 dds_slicer_sin_0
       (.din(dds_0_dout),
        .dout(dds_slicer_cos_2_dout));
  system_fifo_0_0 fifo_0
       (.aclk(aclk),
        .aresetn(slice_0_dout),
        .m_axis_tdata(fifo_0_m_axis_TDATA),
        .m_axis_tready(fifo_0_m_axis_TREADY),
        .m_axis_tvalid(fifo_0_m_axis_TVALID),
        .read_count(fifo_0_read_count),
        .s_axis_tdata(conv_1_M_AXIS_TDATA),
        .s_axis_tready(conv_1_M_AXIS_TREADY),
        .s_axis_tvalid(conv_1_M_AXIS_TVALID));
  system_slice_0_0 fifo_reset_slice_0
       (.din(hub_0_cfg_data),
        .dout(slice_0_dout));
  system_fir_0_0 fir_0
       (.aclk(aclk),
        .aresetn(aresetn),
        .m_axis_data_tdata(fir_0_M_AXIS_DATA_TDATA),
        .m_axis_data_tvalid(fir_0_M_AXIS_DATA_TVALID),
        .s_axis_data_tdata(conv_0_M_AXIS_TDATA),
        .s_axis_data_tready(conv_0_M_AXIS_TREADY),
        .s_axis_data_tvalid(conv_0_M_AXIS_TVALID));
  system_fir_1_0 fir_1
       (.aclk(aclk),
        .aresetn(aresetn),
        .m_axis_data_tdata(fir_1_M_AXIS_DATA_TDATA),
        .m_axis_data_tvalid(fir_1_M_AXIS_DATA_TVALID),
        .s_axis_data_tdata(subset_0_M_AXIS_TDATA),
        .s_axis_data_tvalid(subset_0_M_AXIS_TVALID));
  system_fp_0_0 fp_0
       (.aclk(aclk),
        .aresetn(aresetn),
        .m_axis_result_tdata(fp_0_M_AXIS_RESULT_TDATA),
        .m_axis_result_tready(fp_0_M_AXIS_RESULT_TREADY),
        .m_axis_result_tvalid(fp_0_M_AXIS_RESULT_TVALID),
        .s_axis_a_tdata(subset_1_M_AXIS_TDATA),
        .s_axis_a_tvalid(subset_1_M_AXIS_TVALID));
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
        .s00_axis_tdata(conv_2_M_AXIS_TDATA),
        .s00_axis_tready(conv_2_M_AXIS_TREADY),
        .s00_axis_tvalid(conv_2_M_AXIS_TVALID),
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
        .sts_data({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,fifo_0_read_count}));
  system_dsp48_0_0 mult_I_cos
       (.A(port_slicer_0_dout1),
        .B(adc_slicer_I_dout),
        .CLK(aclk),
        .P(mult_I_cos_P));
  system_dsp48_0_2 mult_I_sin
       (.A(dds_slicer_cos_2_dout),
        .B(adc_slicer_I_dout),
        .CLK(aclk),
        .P(mult_I_sin_P));
  system_mult_I_cos_0 mult_Q_asin
       (.A(dds_slicer_sin_1_dout),
        .B(adc_slicer_Q_dout),
        .CLK(aclk),
        .P(mult_Q_asin_P));
  system_dsp48_0_1 mult_Q_cos
       (.A(dds_slicer_1_dout),
        .B(adc_slicer_Q_dout),
        .CLK(aclk),
        .P(mult_Q_cos_P));
  system_subset_0_0 subset_0
       (.aclk(aclk),
        .aresetn(aresetn),
        .m_axis_tdata(subset_0_M_AXIS_TDATA),
        .m_axis_tvalid(subset_0_M_AXIS_TVALID),
        .s_axis_tdata(fir_0_M_AXIS_DATA_TDATA),
        .s_axis_tvalid(fir_0_M_AXIS_DATA_TVALID));
  system_subset_1_0 subset_1
       (.aclk(aclk),
        .aresetn(aresetn),
        .m_axis_tdata(subset_1_M_AXIS_TDATA),
        .m_axis_tvalid(subset_1_M_AXIS_TVALID),
        .s_axis_tdata(fir_1_M_AXIS_DATA_TDATA),
        .s_axis_tvalid(fir_1_M_AXIS_DATA_TVALID));
endmodule

(* CORE_GENERATION_INFO = "system,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=system,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=36,numReposBlks=35,numNonXlnxBlks=0,numHierBlks=1,maxHierDepth=1,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=19,numPkgbdBlks=0,bdsource=USER,synth_mode=None}" *) (* HW_HANDOFF = "system.hwdef" *) 
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
  inout [7:0]exp_p_tri_io;
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
  wire [31:0]adc_0_m_axis_tdata;
  wire adc_clk_n_i;
  wire adc_clk_p_i;
  wire adc_csn_o;
  wire [15:0]adc_dat_a_i;
  wire [15:0]adc_dat_b_i;
  wire [0:0]const_0_dout;
  wire pll_0_clk_out1;
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

  system_adc_0_0 adc_0
       (.aclk(pll_0_clk_out1),
        .adc_csn(adc_csn_o),
        .adc_dat_a(adc_dat_a_i),
        .adc_dat_b(adc_dat_b_i),
        .m_axis_tdata(adc_0_m_axis_tdata));
  system_const_0_0 const_0
       (.dout(const_0_dout));
  system_pll_0_0 pll_0
       (.clk_in1_n(adc_clk_n_i),
        .clk_in1_p(adc_clk_p_i),
        .clk_out1(pll_0_clk_out1),
        .locked(pll_0_locked));
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
        .PS_CLK(FIXED_IO_ps_clk),
        .PS_PORB(FIXED_IO_ps_porb),
        .PS_SRSTB(FIXED_IO_ps_srstb),
        .SPI0_MISO_I(1'b0),
        .SPI0_MOSI_I(1'b0),
        .SPI0_SCLK_I(1'b0),
        .SPI0_SS_I(1'b0),
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
        .din(adc_0_m_axis_tdata),
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
        .s_axi_wvalid(ps_0_M_AXI_GP0_WVALID));
endmodule
