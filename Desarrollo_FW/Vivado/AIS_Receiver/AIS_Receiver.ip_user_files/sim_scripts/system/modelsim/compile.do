vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xilinx_vip
vlib modelsim_lib/msim/xpm
vlib modelsim_lib/msim/xil_defaultlib
vlib modelsim_lib/msim/axi_infrastructure_v1_1_0
vlib modelsim_lib/msim/axi_vip_v1_1_22
vlib modelsim_lib/msim/processing_system7_vip_v1_0_24
vlib modelsim_lib/msim/proc_sys_reset_v5_0_17
vlib modelsim_lib/msim/xbip_utils_v3_0_15
vlib modelsim_lib/msim/axi_utils_v2_0_11
vlib modelsim_lib/msim/cic_compiler_v4_0_22
vlib modelsim_lib/msim/axis_infrastructure_v1_1_1
vlib modelsim_lib/msim/axis_register_slice_v1_1_35
vlib modelsim_lib/msim/axis_dwidth_converter_v1_1_34
vlib modelsim_lib/msim/xbip_pipe_v3_0_11
vlib modelsim_lib/msim/fir_compiler_v7_2_26
vlib modelsim_lib/msim/axis_subset_converter_v1_1_36
vlib modelsim_lib/msim/xbip_dsp48_wrapper_v3_0_7
vlib modelsim_lib/msim/mult_gen_v12_0_24
vlib modelsim_lib/msim/floating_point_v7_1_21
vlib modelsim_lib/msim/axis_combiner_v1_1_33
vlib modelsim_lib/msim/c_reg_fd_v12_0_11
vlib modelsim_lib/msim/c_addsub_v12_0_21

vmap xilinx_vip modelsim_lib/msim/xilinx_vip
vmap xpm modelsim_lib/msim/xpm
vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib
vmap axi_infrastructure_v1_1_0 modelsim_lib/msim/axi_infrastructure_v1_1_0
vmap axi_vip_v1_1_22 modelsim_lib/msim/axi_vip_v1_1_22
vmap processing_system7_vip_v1_0_24 modelsim_lib/msim/processing_system7_vip_v1_0_24
vmap proc_sys_reset_v5_0_17 modelsim_lib/msim/proc_sys_reset_v5_0_17
vmap xbip_utils_v3_0_15 modelsim_lib/msim/xbip_utils_v3_0_15
vmap axi_utils_v2_0_11 modelsim_lib/msim/axi_utils_v2_0_11
vmap cic_compiler_v4_0_22 modelsim_lib/msim/cic_compiler_v4_0_22
vmap axis_infrastructure_v1_1_1 modelsim_lib/msim/axis_infrastructure_v1_1_1
vmap axis_register_slice_v1_1_35 modelsim_lib/msim/axis_register_slice_v1_1_35
vmap axis_dwidth_converter_v1_1_34 modelsim_lib/msim/axis_dwidth_converter_v1_1_34
vmap xbip_pipe_v3_0_11 modelsim_lib/msim/xbip_pipe_v3_0_11
vmap fir_compiler_v7_2_26 modelsim_lib/msim/fir_compiler_v7_2_26
vmap axis_subset_converter_v1_1_36 modelsim_lib/msim/axis_subset_converter_v1_1_36
vmap xbip_dsp48_wrapper_v3_0_7 modelsim_lib/msim/xbip_dsp48_wrapper_v3_0_7
vmap mult_gen_v12_0_24 modelsim_lib/msim/mult_gen_v12_0_24
vmap floating_point_v7_1_21 modelsim_lib/msim/floating_point_v7_1_21
vmap axis_combiner_v1_1_33 modelsim_lib/msim/axis_combiner_v1_1_33
vmap c_reg_fd_v12_0_11 modelsim_lib/msim/c_reg_fd_v12_0_11
vmap c_addsub_v12_0_21 modelsim_lib/msim/c_addsub_v12_0_21

vlog -work xilinx_vip  -incr -mfcu  -sv -L axi_vip_v1_1_22 -L processing_system7_vip_v1_0_24 -L xilinx_vip "+incdir+D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/include" \
"D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/hdl/axi_vip_if.sv" \
"D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/hdl/clk_vip_if.sv" \
"D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/hdl/rst_vip_if.sv" \

vlog -work xpm  -incr -mfcu  -sv -L axi_vip_v1_1_22 -L processing_system7_vip_v1_0_24 -L xilinx_vip "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/a415" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/9a25/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/434f/hdl" "+incdir+../../../../../../Programas/AMDDesignTools/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/include" \
"D:/Programas/AMDDesignTools/2025.2/Vivado/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"D:/Programas/AMDDesignTools/2025.2/Vivado/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"D:/Programas/AMDDesignTools/2025.2/Vivado/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm  -93  \
"D:/Programas/AMDDesignTools/2025.2/Vivado/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib  -incr -mfcu  "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/a415" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/9a25/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/434f/hdl" "+incdir+../../../../../../Programas/AMDDesignTools/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/include" \
"../../../bd/system/ip/system_pll_0_0/system_pll_0_0_clk_wiz.v" \
"../../../bd/system/ip/system_pll_0_0/system_pll_0_0.v" \

vlog -work axi_infrastructure_v1_1_0  -incr -mfcu  "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/a415" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/9a25/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/434f/hdl" "+incdir+../../../../../../Programas/AMDDesignTools/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/include" \
"../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \

vlog -work axi_vip_v1_1_22  -incr -mfcu  -sv -L axi_vip_v1_1_22 -L processing_system7_vip_v1_0_24 -L xilinx_vip "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/a415" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/9a25/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/434f/hdl" "+incdir+../../../../../../Programas/AMDDesignTools/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/include" \
"../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/b16a/hdl/axi_vip_v1_1_vl_rfs.sv" \

vlog -work processing_system7_vip_v1_0_24  -incr -mfcu  -sv -L axi_vip_v1_1_22 -L processing_system7_vip_v1_0_24 -L xilinx_vip "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/a415" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/9a25/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/434f/hdl" "+incdir+../../../../../../Programas/AMDDesignTools/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/include" \
"../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/9a25/hdl/processing_system7_vip_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr -mfcu  "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/a415" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/9a25/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/434f/hdl" "+incdir+../../../../../../Programas/AMDDesignTools/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/include" \
"../../../bd/system/ip/system_ps_0_0/sim/system_ps_0_0.v" \
"../../../bd/system/ip/system_const_0_0/sim/system_const_0_0.v" \

vcom -work proc_sys_reset_v5_0_17  -93  \
"../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/9438/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \

vcom -work xil_defaultlib  -93  \
"../../../bd/system/ip/system_rst_0_0/sim/system_rst_0_0.vhd" \

vlog -work xil_defaultlib  -incr -mfcu  "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/a415" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/9a25/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/434f/hdl" "+incdir+../../../../../../Programas/AMDDesignTools/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/include" \
"../../../bd/system/ip/system_adc_0_0/sim/system_adc_0_0.v" \
"../../../bd/system/ip/system_hub_0_0/sim/system_hub_0_0.v" \
"../../../bd/system/ip/system_slice_0_0/sim/system_slice_0_0.v" \
"../../../bd/system/ip/system_const_0_1/sim/system_const_0_1.v" \

vcom -work xbip_utils_v3_0_15  -93  \
"../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/fb6f/hdl/xbip_utils_v3_0_vh_rfs.vhd" \

vcom -work axi_utils_v2_0_11  -93  \
"../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/c6be/hdl/axi_utils_v2_0_vh_rfs.vhd" \

vcom -work cic_compiler_v4_0_22  -93  \
"../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/0e3c/hdl/cic_compiler_v4_0_vh_rfs.vhd" \

vcom -work xil_defaultlib  -93  \
"../../../bd/system/ip/system_cic_0_0/sim/system_cic_0_0.vhd" \

vlog -work axis_infrastructure_v1_1_1  -incr -mfcu  "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/a415" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/9a25/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/434f/hdl" "+incdir+../../../../../../Programas/AMDDesignTools/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/include" \
"../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/434f/hdl/axis_infrastructure_v1_1_vl_rfs.v" \

vlog -work axis_register_slice_v1_1_35  -incr -mfcu  "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/a415" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/9a25/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/434f/hdl" "+incdir+../../../../../../Programas/AMDDesignTools/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/include" \
"../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/be12/hdl/axis_register_slice_v1_1_vl_rfs.v" \

vlog -work axis_dwidth_converter_v1_1_34  -incr -mfcu  "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/a415" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/9a25/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/434f/hdl" "+incdir+../../../../../../Programas/AMDDesignTools/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/include" \
"../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/80a6/hdl/axis_dwidth_converter_v1_1_vl_rfs.v" \

vlog -work xil_defaultlib  -incr -mfcu  "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/a415" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/9a25/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/434f/hdl" "+incdir+../../../../../../Programas/AMDDesignTools/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/include" \
"../../../bd/system/ip/system_conv_0_0/sim/system_conv_0_0.v" \

vcom -work xbip_pipe_v3_0_11  -93  \
"../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/6a79/hdl/xbip_pipe_v3_0_vh_rfs.vhd" \

vcom -work fir_compiler_v7_2_26  -93  \
"../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/655f/hdl/fir_compiler_v7_2_vh_rfs.vhd" \

vcom -work xil_defaultlib  -93  \
"../../../bd/system/ip/system_fir_0_0/sim/system_fir_0_0.vhd" \

vlog -work xil_defaultlib  -incr -mfcu  "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/a415" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/9a25/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/434f/hdl" "+incdir+../../../../../../Programas/AMDDesignTools/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/include" \
"../../../bd/system/ip/system_subset_0_0/hdl/tdata_system_subset_0_0.v" \
"../../../bd/system/ip/system_subset_0_0/hdl/tuser_system_subset_0_0.v" \
"../../../bd/system/ip/system_subset_0_0/hdl/tstrb_system_subset_0_0.v" \
"../../../bd/system/ip/system_subset_0_0/hdl/tkeep_system_subset_0_0.v" \
"../../../bd/system/ip/system_subset_0_0/hdl/tid_system_subset_0_0.v" \
"../../../bd/system/ip/system_subset_0_0/hdl/tdest_system_subset_0_0.v" \
"../../../bd/system/ip/system_subset_0_0/hdl/tlast_system_subset_0_0.v" \

vlog -work axis_subset_converter_v1_1_36  -incr -mfcu  "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/a415" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/9a25/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/434f/hdl" "+incdir+../../../../../../Programas/AMDDesignTools/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/include" \
"../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/5e96/hdl/axis_subset_converter_v1_1_vl_rfs.v" \

vlog -work xil_defaultlib  -incr -mfcu  "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/a415" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/9a25/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/434f/hdl" "+incdir+../../../../../../Programas/AMDDesignTools/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/include" \
"../../../bd/system/ip/system_subset_0_0/hdl/top_system_subset_0_0.v" \
"../../../bd/system/ip/system_subset_0_0/sim/system_subset_0_0.v" \

vcom -work xil_defaultlib  -93  \
"../../../bd/system/ip/system_fir_1_0/sim/system_fir_1_0.vhd" \

vlog -work xil_defaultlib  -incr -mfcu  "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/a415" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/9a25/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/434f/hdl" "+incdir+../../../../../../Programas/AMDDesignTools/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/include" \
"../../../bd/system/ip/system_subset_1_0/hdl/tdata_system_subset_1_0.v" \
"../../../bd/system/ip/system_subset_1_0/hdl/tuser_system_subset_1_0.v" \
"../../../bd/system/ip/system_subset_1_0/hdl/tstrb_system_subset_1_0.v" \
"../../../bd/system/ip/system_subset_1_0/hdl/tkeep_system_subset_1_0.v" \
"../../../bd/system/ip/system_subset_1_0/hdl/tid_system_subset_1_0.v" \
"../../../bd/system/ip/system_subset_1_0/hdl/tdest_system_subset_1_0.v" \
"../../../bd/system/ip/system_subset_1_0/hdl/tlast_system_subset_1_0.v" \
"../../../bd/system/ip/system_subset_1_0/hdl/top_system_subset_1_0.v" \
"../../../bd/system/ip/system_subset_1_0/sim/system_subset_1_0.v" \

vcom -work xbip_dsp48_wrapper_v3_0_7  -93  \
"../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/9bc6/hdl/xbip_dsp48_wrapper_v3_0_vh_rfs.vhd" \

vcom -work mult_gen_v12_0_24  -93  \
"../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/6d7a/hdl/mult_gen_v12_0_vh_rfs.vhd" \

vcom -work floating_point_v7_1_21  -93  \
"../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/c90d/hdl/floating_point_v7_1_vh_rfs.vhd" \

vcom -work xil_defaultlib  -93  \
"../../../bd/system/ip/system_fp_0_0/sim/system_fp_0_0.vhd" \

vlog -work xil_defaultlib  -incr -mfcu  "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/a415" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/9a25/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/434f/hdl" "+incdir+../../../../../../Programas/AMDDesignTools/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/include" \
"../../../bd/system/ip/system_conv_1_0/sim/system_conv_1_0.v" \
"../../../bd/system/ip/system_fifo_0_0/sim/system_fifo_0_0.v" \
"../../../bd/system/ip/system_conv_2_0/sim/system_conv_2_0.v" \

vcom -work xil_defaultlib  -93  \
"../../../bd/system/ip/system_cic_10_0/sim/system_cic_10_0.vhd" \

vlog -work axis_combiner_v1_1_33  -incr -mfcu  "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/a415" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/9a25/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/434f/hdl" "+incdir+../../../../../../Programas/AMDDesignTools/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/include" \
"../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/ef89/hdl/axis_combiner_v1_1_vl_rfs.v" \

vlog -work xil_defaultlib  -incr -mfcu  "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/a415" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/ec67/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/9a25/hdl" "+incdir+../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/434f/hdl" "+incdir+../../../../../../Programas/AMDDesignTools/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/Programas/AMDDesignTools/2025.2/Vivado/data/xilinx_vip/include" \
"../../../bd/system/ip/system_axis_combiner_0_0/sim/system_axis_combiner_0_0.v" \
"../../../bd/system/ip/system_port_slicer_0_0/sim/system_port_slicer_0_0.v" \
"../../../bd/system/ip/system_adc_slicer_0_0/sim/system_adc_slicer_0_0.v" \
"../../../bd/system/ip/system_dds_0_0/sim/system_dds_0_0.v" \
"../../../bd/system/ip/system_port_slicer_0_1/sim/system_port_slicer_0_1.v" \
"../../../bd/system/ip/system_dds_0_1/sim/system_dds_0_1.v" \
"../../../bd/system/ip/system_dsp48_0_0/sim/system_dsp48_0_0.v" \
"../../../bd/system/ip/system_port_slicer_0_2/sim/system_port_slicer_0_2.v" \
"../../../bd/system/ip/system_dds_slicer_0_0/sim/system_dds_slicer_0_0.v" \
"../../../bd/system/ip/system_dsp48_0_1/sim/system_dsp48_0_1.v" \
"../../../bd/system/sim/system.v" \
"../../../bd/system/ip/system_dds_slicer_cos_0_0/sim/system_dds_slicer_cos_0_0.v" \
"../../../bd/system/ip/system_dsp48_0_2/sim/system_dsp48_0_2.v" \
"../../../bd/system/ip/system_mult_I_cos_0/sim/system_mult_I_cos_0.v" \
"../../../bd/system/ip/system_port_slicer_0_3/sim/system_port_slicer_0_3.v" \

vcom -work c_reg_fd_v12_0_11  -93  \
"../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/0ff7/hdl/c_reg_fd_v12_0_vh_rfs.vhd" \

vcom -work c_addsub_v12_0_21  -93  \
"../../../../AIS_Receiver.gen/sources_1/bd/system/ipshared/ed70/hdl/c_addsub_v12_0_vh_rfs.vhd" \

vcom -work xil_defaultlib  -93  \
"../../../bd/system/ip/system_c_addsub_0_0/sim/system_c_addsub_0_0.vhd" \
"../../../bd/system/ip/system_c_addsub_0_1/sim/system_c_addsub_0_1.vhd" \

vlog -work xil_defaultlib \
"glbl.v"

