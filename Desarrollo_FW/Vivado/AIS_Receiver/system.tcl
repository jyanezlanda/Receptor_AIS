
################################################################
# This is a generated script based on design: system
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2025.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   if { [string compare $scripts_vivado_version $current_vivado_version] > 0 } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2042 -severity "ERROR" " This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Sourcing the script failed since it was created with a future version of Vivado."}

   } else {
     catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   }

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source system_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# constant, axis_red_pitaya_adc, axis_red_pitaya_dac, axi_hub, port_slicer, port_slicer, axis_constant, axis_lfsr, axis_fifo, axi_hub, port_slicer, port_slicer, port_slicer, axis_fifo, axis_ram_reader

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7z010clg400-1
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name system

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:clk_wiz:6.0\
xilinx.com:ip:processing_system7:5.5\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:dds_compiler:6.0\
xilinx.com:ip:cmpy:6.0\
xilinx.com:ip:axis_broadcaster:1.1\
xilinx.com:ip:cic_compiler:4.0\
xilinx.com:ip:axis_combiner:1.1\
xilinx.com:ip:axis_dwidth_converter:1.1\
xilinx.com:ip:fir_compiler:7.2\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

##################################################################
# CHECK Modules
##################################################################
set bCheckModules 1
if { $bCheckModules == 1 } {
   set list_check_mods "\ 
constant\
axis_red_pitaya_adc\
axis_red_pitaya_dac\
axi_hub\
port_slicer\
port_slicer\
axis_constant\
axis_lfsr\
axis_fifo\
axi_hub\
port_slicer\
port_slicer\
port_slicer\
axis_fifo\
axis_ram_reader\
"

   set list_mods_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2020 -severity "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } {
         lappend list_mods_missing $mod_vlnv
      }
   }

   if { $list_mods_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2021 -severity "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      common::send_gid_msg -ssname BD::TCL -id 2022 -severity "INFO" "Please add source files for the missing module(s) above."
      set bCheckIPsPassed 0
   }
}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: test_0
proc create_hier_cell_test_0 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_test_0() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_0

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 m_axi_ram

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m_axis_fifo


  # Create pins
  create_bd_pin -dir I -type clk aclk
  create_bd_pin -dir I -type rst aresetn

  # Create instance: axi_hub_0, and set properties
  set block_name axi_hub
  set block_cell_name axi_hub_0
  if { [catch {set axi_hub_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $axi_hub_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [list \
    CONFIG.CFG_DATA_WIDTH {96} \
    CONFIG.STS_DATA_WIDTH {32} \
  ] $axi_hub_0


  # Create instance: rst_slice, and set properties
  set block_name port_slicer
  set block_cell_name rst_slice
  if { [catch {set rst_slice [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $rst_slice eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [list \
    CONFIG.DIN_FROM {0} \
    CONFIG.DIN_WIDTH {96} \
  ] $rst_slice


  # Create instance: addr_slice, and set properties
  set block_name port_slicer
  set block_cell_name addr_slice
  if { [catch {set addr_slice [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $addr_slice eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [list \
    CONFIG.DIN_FROM {63} \
    CONFIG.DIN_TO {32} \
    CONFIG.DIN_WIDTH {96} \
  ] $addr_slice


  # Create instance: size_slice, and set properties
  set block_name port_slicer
  set block_cell_name size_slice
  if { [catch {set size_slice [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $size_slice eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [list \
    CONFIG.DIN_FROM {81} \
    CONFIG.DIN_TO {64} \
    CONFIG.DIN_WIDTH {96} \
  ] $size_slice


  # Create instance: axis_fifo_0, and set properties
  set block_name axis_fifo
  set block_cell_name axis_fifo_0
  if { [catch {set axis_fifo_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $axis_fifo_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [list \
    CONFIG.ALWAYS_READY {TRUE} \
    CONFIG.WRITE_DEPTH {8192} \
  ] $axis_fifo_0


  # Create instance: axis_ram_reader_0, and set properties
  set block_name axis_ram_reader
  set block_cell_name axis_ram_reader_0
  if { [catch {set axis_ram_reader_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $axis_ram_reader_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [list \
    CONFIG.ADDR_WIDTH {18} \
    CONFIG.AXIS_TDATA_WIDTH {32} \
    CONFIG.AXI_ID_WIDTH {3} \
    CONFIG.FIFO_WRITE_DEPTH {1024} \
    CONFIG.MAX_OUTSTANDING {8} \
  ] $axis_ram_reader_0


  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins axi_hub_0/s_axi] [get_bd_intf_pins s_axi_0]
  connect_bd_intf_net -intf_net Conn3 [get_bd_intf_pins axis_fifo_0/m_axis] [get_bd_intf_pins m_axis_fifo]
  connect_bd_intf_net -intf_net axis_ram_reader_1_m_axi [get_bd_intf_pins m_axi_ram] [get_bd_intf_pins axis_ram_reader_0/m_axi]
  connect_bd_intf_net -intf_net axis_ram_reader_1_m_axis [get_bd_intf_pins axis_ram_reader_0/m_axis] [get_bd_intf_pins axis_fifo_0/s_axis]

  # Create port connections
  connect_bd_net -net addr_slice_dout  [get_bd_pins addr_slice/dout] \
  [get_bd_pins axis_ram_reader_0/min_addr]
  connect_bd_net -net aresetn_1  [get_bd_pins aresetn] \
  [get_bd_pins axi_hub_0/aresetn] \
  [get_bd_pins axis_fifo_0/aresetn]
  connect_bd_net -net axi_hub_0_cfg_data  [get_bd_pins axi_hub_0/cfg_data] \
  [get_bd_pins rst_slice/din] \
  [get_bd_pins addr_slice/din] \
  [get_bd_pins size_slice/din]
  connect_bd_net -net axis_ram_reader_1_sts_data  [get_bd_pins axis_ram_reader_0/sts_data] \
  [get_bd_pins axi_hub_0/sts_data]
  connect_bd_net -net pll_0_clk_out1  [get_bd_pins aclk] \
  [get_bd_pins axi_hub_0/aclk] \
  [get_bd_pins axis_fifo_0/aclk] \
  [get_bd_pins axis_ram_reader_0/aclk]
  connect_bd_net -net size_slice_dout  [get_bd_pins size_slice/dout] \
  [get_bd_pins axis_ram_reader_0/cfg_data]
  connect_bd_net -net slicer_reset_dout  [get_bd_pins rst_slice/dout] \
  [get_bd_pins axis_ram_reader_0/aresetn]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: rx_0
proc create_hier_cell_rx_0 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_rx_0() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis_adc


  # Create pins
  create_bd_pin -dir I -type clk aclk
  create_bd_pin -dir I -type rst aresetn

  # Create instance: hub_0, and set properties
  set block_name axi_hub
  set block_cell_name hub_0
  if { [catch {set hub_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $hub_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [list \
    CONFIG.CFG_DATA_WIDTH {64} \
    CONFIG.STS_DATA_WIDTH {32} \
  ] $hub_0


  # Create instance: slice_0, and set properties
  set block_name port_slicer
  set block_cell_name slice_0
  if { [catch {set slice_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $slice_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [list \
    CONFIG.DIN_FROM {0} \
    CONFIG.DIN_TO {0} \
    CONFIG.DIN_WIDTH {64} \
  ] $slice_0


  # Create instance: slice_1, and set properties
  set block_name port_slicer
  set block_cell_name slice_1
  if { [catch {set slice_1 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $slice_1 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [list \
    CONFIG.DIN_FROM {40} \
    CONFIG.DIN_TO {1} \
    CONFIG.DIN_WIDTH {64} \
  ] $slice_1


  # Create instance: phase_0, and set properties
  set block_name axis_constant
  set block_cell_name phase_0
  if { [catch {set phase_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $phase_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property CONFIG.AXIS_TDATA_WIDTH {40} $phase_0


  # Create instance: osc_0, and set properties
  set osc_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:dds_compiler:6.0 osc_0 ]
  set_property -dict [list \
    CONFIG.DDS_Clock_Rate {125} \
    CONFIG.DSP48_Use {Minimal} \
    CONFIG.Frequency_Resolution {0.2} \
    CONFIG.Has_Phase_Out {false} \
    CONFIG.Negative_Sine {true} \
    CONFIG.Output_Width {24} \
    CONFIG.Phase_Increment {Streaming} \
    CONFIG.Phase_Width {30} \
    CONFIG.Resync {true} \
    CONFIG.Spurious_Free_Dynamic_Range {138} \
  ] $osc_0


  # Create instance: lfsr_0, and set properties
  set block_name axis_lfsr
  set block_cell_name lfsr_0
  if { [catch {set lfsr_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $lfsr_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: mult_0, and set properties
  set mult_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:cmpy:6.0 mult_0 ]
  set_property -dict [list \
    CONFIG.APortWidth {14} \
    CONFIG.BPortWidth {24} \
    CONFIG.OutputWidth {26} \
    CONFIG.RoundMode {Random_Rounding} \
  ] $mult_0


  # Create instance: bcast_0, and set properties
  set bcast_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_broadcaster:1.1 bcast_0 ]
  set_property -dict [list \
    CONFIG.HAS_TKEEP {0} \
    CONFIG.HAS_TLAST {0} \
    CONFIG.HAS_TREADY {0} \
    CONFIG.HAS_TSTRB {0} \
    CONFIG.M00_TDATA_REMAP {tdata[23:0]} \
    CONFIG.M01_TDATA_REMAP {tdata[55:32]} \
    CONFIG.M_TDATA_NUM_BYTES {3} \
    CONFIG.M_TUSER_WIDTH {0} \
    CONFIG.S_TDATA_NUM_BYTES {8} \
    CONFIG.S_TUSER_WIDTH {0} \
    CONFIG.TDEST_WIDTH {0} \
    CONFIG.TID_WIDTH {0} \
  ] $bcast_0

  set_property -dict [list \
    CONFIG.HAS_TKEEP.VALUE_MODE {auto} \
    CONFIG.HAS_TLAST.VALUE_MODE {auto} \
    CONFIG.HAS_TREADY.VALUE_MODE {auto} \
    CONFIG.HAS_TSTRB.VALUE_MODE {auto} \
    CONFIG.M_TUSER_WIDTH.VALUE_MODE {auto} \
    CONFIG.S_TUSER_WIDTH.VALUE_MODE {auto} \
    CONFIG.TDEST_WIDTH.VALUE_MODE {auto} \
    CONFIG.TID_WIDTH.VALUE_MODE {auto} \
  ] $bcast_0


  # Create instance: cic_0, and set properties
  set cic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:cic_compiler:4.0 cic_0 ]
  set_property -dict [list \
    CONFIG.Clock_Frequency {125} \
    CONFIG.Filter_Type {Decimation} \
    CONFIG.Fixed_Or_Initial_Rate {651} \
    CONFIG.HAS_ARESETN {true} \
    CONFIG.Input_Data_Width {24} \
    CONFIG.Input_Sample_Frequency {125} \
    CONFIG.Maximum_Rate {651} \
    CONFIG.Minimum_Rate {651} \
    CONFIG.Number_Of_Stages {6} \
    CONFIG.Output_Data_Width {32} \
    CONFIG.Quantization {Truncation} \
    CONFIG.SamplePeriod {1} \
    CONFIG.Sample_Rate_Changes {Fixed} \
    CONFIG.Use_Xtreme_DSP_Slice {false} \
  ] $cic_0


  # Create instance: comb_0, and set properties
  set comb_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_combiner:1.1 comb_0 ]
  set_property CONFIG.TDATA_NUM_BYTES {4} $comb_0


  # Create instance: conv_0, and set properties
  set conv_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_dwidth_converter:1.1 conv_0 ]
  set_property -dict [list \
    CONFIG.M_TDATA_NUM_BYTES {4} \
    CONFIG.S_TDATA_NUM_BYTES {8} \
  ] $conv_0


  # Create instance: fir_0, and set properties
  set fir_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fir_compiler:7.2 fir_0 ]
  set_property -dict [list \
    CONFIG.BestPrecision {true} \
    CONFIG.Clock_Frequency {125} \
    CONFIG.CoefficientVector {-1.5293836682e-08, -2.7075718937e-07, -1.1064975909e-07, -8.9600098752e-07, -2.0759708241e-07, -5.5893071791e-07, 1.3233127291e-07, 3.7290781823e-06, 1.4756722767e-06, 1.2998285438e-05,\
3.4215411990e-06, 1.9246156347e-05, 3.3338274849e-06, 3.0548162974e-06, -2.9750294640e-06, -5.1958500098e-05, -1.6751023607e-05, -1.2670051368e-04, -2.9662571452e-05, -1.4123122029e-04, -2.1830125125e-05,\
1.8170219843e-05, 2.7199557537e-05, 3.9175889562e-04, 1.1339725239e-04, 7.9779344997e-04, 1.8210772492e-04, 7.6096962500e-04, 1.2454404335e-04, -3.4137560855e-04, -1.8476969980e-04, -2.8469281448e-03,\
-8.1598347616e-04, -6.0986572383e-03, -1.7140186298e-03, -7.0552975130e-03, -2.6796455493e-03, 7.3081925570e-03, -3.4289490444e-03, 2.5734798089e-01, 5.1687857438e-01, 2.5734798089e-01, -3.4289490444e-03,\
7.3081925570e-03, -2.6796455493e-03, -7.0552975130e-03, -1.7140186298e-03, -6.0986572383e-03, -8.1598347616e-04, -2.8469281448e-03, -1.8476969980e-04, -3.4137560855e-04, 1.2454404335e-04, 7.6096962500e-04,\
1.8210772492e-04, 7.9779344997e-04, 1.1339725239e-04, 3.9175889562e-04, 2.7199557537e-05, 1.8170219843e-05, -2.1830125125e-05, -1.4123122029e-04, -2.9662571452e-05, -1.2670051368e-04, -1.6751023607e-05,\
-5.1958500098e-05, -2.9750294640e-06, 3.0548162974e-06, 3.3338274849e-06, 1.9246156347e-05, 3.4215411990e-06, 1.2998285438e-05, 1.4756722767e-06, 3.7290781823e-06, 1.3233127291e-07, -5.5893071791e-07,\
-2.0759708241e-07, -8.9600098752e-07, -1.1064975909e-07, -2.7075718937e-07, -1.5293836682e-08} \
    CONFIG.Coefficient_Fractional_Bits {23} \
    CONFIG.Coefficient_Sets {1} \
    CONFIG.Coefficient_Sign {Signed} \
    CONFIG.Coefficient_Structure {Inferred} \
    CONFIG.Coefficient_Width {24} \
    CONFIG.ColumnConfig {1} \
    CONFIG.DATA_Has_TLAST {Not_Required} \
    CONFIG.Data_Width {32} \
    CONFIG.Decimation_Rate {1} \
    CONFIG.Filter_Architecture {Systolic_Multiply_Accumulate} \
    CONFIG.Filter_Type {Single_Rate} \
    CONFIG.Has_ARESETn {true} \
    CONFIG.Interpolation_Rate {1} \
    CONFIG.M_DATA_Has_TUSER {Not_Required} \
    CONFIG.Number_Channels {2} \
    CONFIG.Number_Paths {1} \
    CONFIG.Output_Rounding_Mode {Convergent_Rounding_to_Even} \
    CONFIG.Output_Width {32} \
    CONFIG.Quantization {Quantize_Only} \
    CONFIG.RateSpecification {Frequency_Specification} \
    CONFIG.S_DATA_Has_TUSER {Not_Required} \
    CONFIG.Sample_Frequency {0.0960061444} \
    CONFIG.Select_Pattern {All} \
    CONFIG.Zero_Pack_Factor {1} \
  ] $fir_0


  # Create instance: fifo_0, and set properties
  set block_name axis_fifo
  set block_cell_name fifo_0
  if { [catch {set fifo_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $fifo_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property USER_COMMENTS.comment_4 "Enter Comments here" [get_bd_cells /rx_0/fifo_0]
  set_property -dict [list \
    CONFIG.ALWAYS_READY {TRUE} \
    CONFIG.M_AXIS_TDATA_WIDTH {32} \
    CONFIG.S_AXIS_TDATA_WIDTH {32} \
    CONFIG.WRITE_DEPTH {8192} \
  ] $fifo_0


  # Create instance: cic_1, and set properties
  set cic_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:cic_compiler:4.0 cic_1 ]
  set_property -dict [list \
    CONFIG.Clock_Frequency {125} \
    CONFIG.Filter_Type {Decimation} \
    CONFIG.Fixed_Or_Initial_Rate {651} \
    CONFIG.HAS_ARESETN {true} \
    CONFIG.Input_Data_Width {24} \
    CONFIG.Input_Sample_Frequency {125} \
    CONFIG.Maximum_Rate {651} \
    CONFIG.Minimum_Rate {651} \
    CONFIG.Number_Of_Stages {6} \
    CONFIG.Output_Data_Width {32} \
    CONFIG.Quantization {Truncation} \
    CONFIG.SamplePeriod {1} \
    CONFIG.Sample_Rate_Changes {Fixed} \
    CONFIG.Use_Xtreme_DSP_Slice {false} \
  ] $cic_1


  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins hub_0/s_axi] [get_bd_intf_pins s_axi]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins mult_0/S_AXIS_A] [get_bd_intf_pins s_axis_adc]
  connect_bd_intf_net -intf_net bcast_0_M00_AXIS [get_bd_intf_pins cic_0/S_AXIS_DATA] [get_bd_intf_pins bcast_0/M00_AXIS]
  connect_bd_intf_net -intf_net bcast_0_M01_AXIS [get_bd_intf_pins bcast_0/M01_AXIS] [get_bd_intf_pins cic_1/S_AXIS_DATA]
  connect_bd_intf_net -intf_net cic_0_M_AXIS_DATA [get_bd_intf_pins comb_0/S00_AXIS] [get_bd_intf_pins cic_0/M_AXIS_DATA]
  connect_bd_intf_net -intf_net cic_1_M_AXIS_DATA [get_bd_intf_pins cic_1/M_AXIS_DATA] [get_bd_intf_pins comb_0/S01_AXIS]
  connect_bd_intf_net -intf_net comb_0_M_AXIS [get_bd_intf_pins conv_0/S_AXIS] [get_bd_intf_pins comb_0/M_AXIS]
  connect_bd_intf_net -intf_net conv_0_M_AXIS [get_bd_intf_pins fir_0/S_AXIS_DATA] [get_bd_intf_pins conv_0/M_AXIS]
  connect_bd_intf_net -intf_net dds_0_M_AXIS_DATA [get_bd_intf_pins mult_0/S_AXIS_B] [get_bd_intf_pins osc_0/M_AXIS_DATA]
  connect_bd_intf_net -intf_net fir_0_M_AXIS_DATA [get_bd_intf_pins fir_0/M_AXIS_DATA] [get_bd_intf_pins fifo_0/s_axis]
  connect_bd_intf_net -intf_net lfsr_0_m_axis [get_bd_intf_pins mult_0/S_AXIS_CTRL] [get_bd_intf_pins lfsr_0/m_axis]
  connect_bd_intf_net -intf_net mult_0_M_AXIS_DOUT [get_bd_intf_pins bcast_0/S_AXIS] [get_bd_intf_pins mult_0/M_AXIS_DOUT]
  connect_bd_intf_net -intf_net phase_0_m_axis [get_bd_intf_pins osc_0/S_AXIS_PHASE] [get_bd_intf_pins phase_0/m_axis]
  connect_bd_intf_net -intf_net rx_0_m_axis [get_bd_intf_pins hub_0/s00_axis] [get_bd_intf_pins fifo_0/m_axis]

  # Create port connections
  connect_bd_net -net aclk_1  [get_bd_pins aclk] \
  [get_bd_pins hub_0/aclk] \
  [get_bd_pins phase_0/aclk] \
  [get_bd_pins osc_0/aclk] \
  [get_bd_pins lfsr_0/aclk] \
  [get_bd_pins mult_0/aclk] \
  [get_bd_pins bcast_0/aclk] \
  [get_bd_pins cic_0/aclk] \
  [get_bd_pins comb_0/aclk] \
  [get_bd_pins conv_0/aclk] \
  [get_bd_pins fir_0/aclk] \
  [get_bd_pins fifo_0/aclk] \
  [get_bd_pins cic_1/aclk]
  connect_bd_net -net aresetn_1  [get_bd_pins aresetn] \
  [get_bd_pins hub_0/aresetn] \
  [get_bd_pins lfsr_0/aresetn] \
  [get_bd_pins bcast_0/aresetn] \
  [get_bd_pins cic_0/aresetn] \
  [get_bd_pins comb_0/aresetn] \
  [get_bd_pins conv_0/aresetn] \
  [get_bd_pins fir_0/aresetn] \
  [get_bd_pins cic_1/aresetn]
  connect_bd_net -net hub_0_cfg_data  [get_bd_pins hub_0/cfg_data] \
  [get_bd_pins slice_1/din] \
  [get_bd_pins slice_0/din]
  connect_bd_net -net rx_0_read_count  [get_bd_pins fifo_0/read_count] \
  [get_bd_pins hub_0/sts_data]
  connect_bd_net -net slice_0_dout  [get_bd_pins slice_0/dout] \
  [get_bd_pins fifo_0/aresetn]
  connect_bd_net -net slice_1_dout  [get_bd_pins slice_1/dout] \
  [get_bd_pins phase_0/cfg_data]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set Vp_Vn [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vp_Vn ]

  set Vaux0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux0 ]

  set Vaux1 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux1 ]

  set Vaux9 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux9 ]

  set Vaux8 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux8 ]

  set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]

  set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]


  # Create ports
  set adc_dat_a_i [ create_bd_port -dir I -from 15 -to 0 adc_dat_a_i ]
  set adc_dat_b_i [ create_bd_port -dir I -from 15 -to 0 adc_dat_b_i ]
  set adc_clk_p_i [ create_bd_port -dir I adc_clk_p_i ]
  set adc_clk_n_i [ create_bd_port -dir I adc_clk_n_i ]
  set adc_enc_p_o [ create_bd_port -dir O adc_enc_p_o ]
  set adc_enc_n_o [ create_bd_port -dir O adc_enc_n_o ]
  set adc_csn_o [ create_bd_port -dir O adc_csn_o ]
  set dac_dat_o [ create_bd_port -dir O -from 13 -to 0 dac_dat_o ]
  set dac_clk_o [ create_bd_port -dir O dac_clk_o ]
  set dac_rst_o [ create_bd_port -dir O dac_rst_o ]
  set dac_sel_o [ create_bd_port -dir O dac_sel_o ]
  set dac_wrt_o [ create_bd_port -dir O dac_wrt_o ]
  set dac_pwm_o [ create_bd_port -dir O -from 3 -to 0 dac_pwm_o ]
  set exp_n_tri_io [ create_bd_port -dir IO -from 7 -to 0 exp_n_tri_io ]
  set led_o [ create_bd_port -dir O -from 7 -to 0 led_o ]
  set exp_p_tri_io [ create_bd_port -dir O -from 1 -to 0 exp_p_tri_io ]

  # Create instance: pll_0, and set properties
  set pll_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 pll_0 ]
  set_property -dict [list \
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {125.0} \
    CONFIG.CLKOUT1_USED {true} \
    CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {250.0} \
    CONFIG.CLKOUT2_REQUESTED_PHASE {157.5} \
    CONFIG.CLKOUT2_USED {true} \
    CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {250.0} \
    CONFIG.CLKOUT3_REQUESTED_PHASE {202.5} \
    CONFIG.CLKOUT3_USED {true} \
    CONFIG.PRIMITIVE {PLL} \
    CONFIG.PRIM_IN_FREQ {125.0} \
    CONFIG.PRIM_SOURCE {Differential_clock_capable_pin} \
    CONFIG.USE_RESET {false} \
  ] $pll_0


  # Create instance: ps_0, and set properties
  set ps_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 ps_0 ]
  set_property -dict [list \
    CONFIG.PCW_ACT_APU_PERIPHERAL_FREQMHZ {666.666687} \
    CONFIG.PCW_ACT_CAN_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_DCI_PERIPHERAL_FREQMHZ {10.158730} \
    CONFIG.PCW_ACT_ENET0_PERIPHERAL_FREQMHZ {125.000000} \
    CONFIG.PCW_ACT_ENET1_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_FPGA0_PERIPHERAL_FREQMHZ {50.000000} \
    CONFIG.PCW_ACT_FPGA1_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_FPGA2_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_FPGA3_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_PCAP_PERIPHERAL_FREQMHZ {200.000000} \
    CONFIG.PCW_ACT_QSPI_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_SDIO_PERIPHERAL_FREQMHZ {100.000000} \
    CONFIG.PCW_ACT_SMC_PERIPHERAL_FREQMHZ {10.000000} \
    CONFIG.PCW_ACT_SPI_PERIPHERAL_FREQMHZ {166.666672} \
    CONFIG.PCW_ACT_TPIU_PERIPHERAL_FREQMHZ {200.000000} \
    CONFIG.PCW_ACT_TTC0_CLK0_PERIPHERAL_FREQMHZ {111.111115} \
    CONFIG.PCW_ACT_TTC0_CLK1_PERIPHERAL_FREQMHZ {111.111115} \
    CONFIG.PCW_ACT_TTC0_CLK2_PERIPHERAL_FREQMHZ {111.111115} \
    CONFIG.PCW_ACT_TTC1_CLK0_PERIPHERAL_FREQMHZ {111.111115} \
    CONFIG.PCW_ACT_TTC1_CLK1_PERIPHERAL_FREQMHZ {111.111115} \
    CONFIG.PCW_ACT_TTC1_CLK2_PERIPHERAL_FREQMHZ {111.111115} \
    CONFIG.PCW_ACT_TTC_PERIPHERAL_FREQMHZ {50} \
    CONFIG.PCW_ACT_UART_PERIPHERAL_FREQMHZ {100.000000} \
    CONFIG.PCW_ACT_USB0_PERIPHERAL_FREQMHZ {60} \
    CONFIG.PCW_ACT_USB1_PERIPHERAL_FREQMHZ {60} \
    CONFIG.PCW_ACT_WDT_PERIPHERAL_FREQMHZ {111.111115} \
    CONFIG.PCW_APU_CLK_RATIO_ENABLE {6:2:1} \
    CONFIG.PCW_APU_PERIPHERAL_FREQMHZ {666.666666} \
    CONFIG.PCW_CAN0_PERIPHERAL_CLKSRC {External} \
    CONFIG.PCW_CAN0_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_CAN1_PERIPHERAL_CLKSRC {External} \
    CONFIG.PCW_CAN1_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_CAN_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_CAN_PERIPHERAL_VALID {0} \
    CONFIG.PCW_CLK0_FREQ {50000000} \
    CONFIG.PCW_CLK1_FREQ {10000000} \
    CONFIG.PCW_CLK2_FREQ {10000000} \
    CONFIG.PCW_CLK3_FREQ {10000000} \
    CONFIG.PCW_CPU_CPU_6X4X_MAX_RANGE {667} \
    CONFIG.PCW_CPU_PERIPHERAL_CLKSRC {ARM PLL} \
    CONFIG.PCW_CRYSTAL_PERIPHERAL_FREQMHZ {33.333333} \
    CONFIG.PCW_DCI_PERIPHERAL_CLKSRC {DDR PLL} \
    CONFIG.PCW_DCI_PERIPHERAL_FREQMHZ {10.159} \
    CONFIG.PCW_DDR_PERIPHERAL_CLKSRC {DDR PLL} \
    CONFIG.PCW_DDR_RAM_HIGHADDR {0x1FFFFFFF} \
    CONFIG.PCW_ENET0_ENET0_IO {MIO 16 .. 27} \
    CONFIG.PCW_ENET0_GRP_MDIO_ENABLE {1} \
    CONFIG.PCW_ENET0_GRP_MDIO_IO {MIO 52 .. 53} \
    CONFIG.PCW_ENET0_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_ENET0_PERIPHERAL_FREQMHZ {1000 Mbps} \
    CONFIG.PCW_ENET0_RESET_ENABLE {0} \
    CONFIG.PCW_ENET1_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_ENET1_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_ENET_RESET_ENABLE {1} \
    CONFIG.PCW_ENET_RESET_POLARITY {Active Low} \
    CONFIG.PCW_ENET_RESET_SELECT {Share reset pin} \
    CONFIG.PCW_EN_4K_TIMER {0} \
    CONFIG.PCW_EN_CAN0 {0} \
    CONFIG.PCW_EN_CAN1 {0} \
    CONFIG.PCW_EN_CLK0_PORT {1} \
    CONFIG.PCW_EN_CLK1_PORT {0} \
    CONFIG.PCW_EN_CLK2_PORT {0} \
    CONFIG.PCW_EN_CLK3_PORT {0} \
    CONFIG.PCW_EN_DDR {1} \
    CONFIG.PCW_EN_EMIO_CAN0 {0} \
    CONFIG.PCW_EN_EMIO_CAN1 {0} \
    CONFIG.PCW_EN_EMIO_CD_SDIO0 {0} \
    CONFIG.PCW_EN_EMIO_CD_SDIO1 {0} \
    CONFIG.PCW_EN_EMIO_ENET0 {0} \
    CONFIG.PCW_EN_EMIO_ENET1 {0} \
    CONFIG.PCW_EN_EMIO_GPIO {1} \
    CONFIG.PCW_EN_EMIO_I2C0 {0} \
    CONFIG.PCW_EN_EMIO_I2C1 {0} \
    CONFIG.PCW_EN_EMIO_MODEM_UART0 {0} \
    CONFIG.PCW_EN_EMIO_MODEM_UART1 {0} \
    CONFIG.PCW_EN_EMIO_PJTAG {0} \
    CONFIG.PCW_EN_EMIO_SDIO0 {0} \
    CONFIG.PCW_EN_EMIO_SDIO1 {0} \
    CONFIG.PCW_EN_EMIO_SPI0 {1} \
    CONFIG.PCW_EN_EMIO_SPI1 {0} \
    CONFIG.PCW_EN_EMIO_SRAM_INT {0} \
    CONFIG.PCW_EN_EMIO_TRACE {0} \
    CONFIG.PCW_EN_EMIO_TTC0 {0} \
    CONFIG.PCW_EN_EMIO_TTC1 {0} \
    CONFIG.PCW_EN_EMIO_UART0 {0} \
    CONFIG.PCW_EN_EMIO_UART1 {0} \
    CONFIG.PCW_EN_EMIO_WDT {0} \
    CONFIG.PCW_EN_EMIO_WP_SDIO0 {0} \
    CONFIG.PCW_EN_EMIO_WP_SDIO1 {0} \
    CONFIG.PCW_EN_ENET0 {1} \
    CONFIG.PCW_EN_ENET1 {0} \
    CONFIG.PCW_EN_GPIO {1} \
    CONFIG.PCW_EN_I2C0 {1} \
    CONFIG.PCW_EN_I2C1 {0} \
    CONFIG.PCW_EN_MODEM_UART0 {0} \
    CONFIG.PCW_EN_MODEM_UART1 {0} \
    CONFIG.PCW_EN_PJTAG {0} \
    CONFIG.PCW_EN_QSPI {0} \
    CONFIG.PCW_EN_SDIO0 {1} \
    CONFIG.PCW_EN_SDIO1 {0} \
    CONFIG.PCW_EN_SMC {0} \
    CONFIG.PCW_EN_SPI0 {1} \
    CONFIG.PCW_EN_SPI1 {1} \
    CONFIG.PCW_EN_TRACE {0} \
    CONFIG.PCW_EN_TTC0 {0} \
    CONFIG.PCW_EN_TTC1 {0} \
    CONFIG.PCW_EN_UART0 {1} \
    CONFIG.PCW_EN_UART1 {1} \
    CONFIG.PCW_EN_USB0 {1} \
    CONFIG.PCW_EN_USB1 {0} \
    CONFIG.PCW_EN_WDT {0} \
    CONFIG.PCW_FCLK0_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_FCLK1_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_FCLK2_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_FCLK3_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_FCLK_CLK0_BUF {TRUE} \
    CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {50} \
    CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ {50} \
    CONFIG.PCW_FPGA2_PERIPHERAL_FREQMHZ {50} \
    CONFIG.PCW_FPGA3_PERIPHERAL_FREQMHZ {50} \
    CONFIG.PCW_FPGA_FCLK0_ENABLE {1} \
    CONFIG.PCW_GPIO_EMIO_GPIO_ENABLE {1} \
    CONFIG.PCW_GPIO_EMIO_GPIO_IO {64} \
    CONFIG.PCW_GPIO_EMIO_GPIO_WIDTH {64} \
    CONFIG.PCW_GPIO_MIO_GPIO_ENABLE {1} \
    CONFIG.PCW_GPIO_MIO_GPIO_IO {MIO} \
    CONFIG.PCW_GPIO_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_I2C0_GRP_INT_ENABLE {0} \
    CONFIG.PCW_I2C0_I2C0_IO {MIO 50 .. 51} \
    CONFIG.PCW_I2C0_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_I2C0_RESET_ENABLE {0} \
    CONFIG.PCW_I2C1_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_I2C_PERIPHERAL_FREQMHZ {111.111115} \
    CONFIG.PCW_I2C_RESET_ENABLE {1} \
    CONFIG.PCW_I2C_RESET_POLARITY {Active Low} \
    CONFIG.PCW_I2C_RESET_SELECT {Share reset pin} \
    CONFIG.PCW_IMPORT_BOARD_PRESET {cfg/red_pitaya.xml} \
    CONFIG.PCW_IRQ_F2P_MODE {DIRECT} \
    CONFIG.PCW_MIO_0_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_0_PULLUP {disabled} \
    CONFIG.PCW_MIO_0_SLEW {slow} \
    CONFIG.PCW_MIO_10_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_10_PULLUP {enabled} \
    CONFIG.PCW_MIO_10_SLEW {slow} \
    CONFIG.PCW_MIO_11_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_11_PULLUP {enabled} \
    CONFIG.PCW_MIO_11_SLEW {slow} \
    CONFIG.PCW_MIO_12_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_12_PULLUP {enabled} \
    CONFIG.PCW_MIO_12_SLEW {slow} \
    CONFIG.PCW_MIO_13_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_13_PULLUP {enabled} \
    CONFIG.PCW_MIO_13_SLEW {slow} \
    CONFIG.PCW_MIO_14_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_14_PULLUP {enabled} \
    CONFIG.PCW_MIO_14_SLEW {slow} \
    CONFIG.PCW_MIO_15_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_15_PULLUP {enabled} \
    CONFIG.PCW_MIO_15_SLEW {slow} \
    CONFIG.PCW_MIO_16_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_16_PULLUP {disabled} \
    CONFIG.PCW_MIO_16_SLEW {fast} \
    CONFIG.PCW_MIO_17_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_17_PULLUP {disabled} \
    CONFIG.PCW_MIO_17_SLEW {fast} \
    CONFIG.PCW_MIO_18_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_18_PULLUP {disabled} \
    CONFIG.PCW_MIO_18_SLEW {fast} \
    CONFIG.PCW_MIO_19_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_19_PULLUP {disabled} \
    CONFIG.PCW_MIO_19_SLEW {fast} \
    CONFIG.PCW_MIO_1_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_1_PULLUP {enabled} \
    CONFIG.PCW_MIO_1_SLEW {slow} \
    CONFIG.PCW_MIO_20_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_20_PULLUP {disabled} \
    CONFIG.PCW_MIO_20_SLEW {fast} \
    CONFIG.PCW_MIO_21_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_21_PULLUP {disabled} \
    CONFIG.PCW_MIO_21_SLEW {fast} \
    CONFIG.PCW_MIO_22_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_22_PULLUP {disabled} \
    CONFIG.PCW_MIO_22_SLEW {fast} \
    CONFIG.PCW_MIO_23_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_23_PULLUP {disabled} \
    CONFIG.PCW_MIO_23_SLEW {fast} \
    CONFIG.PCW_MIO_24_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_24_PULLUP {disabled} \
    CONFIG.PCW_MIO_24_SLEW {fast} \
    CONFIG.PCW_MIO_25_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_25_PULLUP {disabled} \
    CONFIG.PCW_MIO_25_SLEW {fast} \
    CONFIG.PCW_MIO_26_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_26_PULLUP {disabled} \
    CONFIG.PCW_MIO_26_SLEW {fast} \
    CONFIG.PCW_MIO_27_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_27_PULLUP {disabled} \
    CONFIG.PCW_MIO_27_SLEW {fast} \
    CONFIG.PCW_MIO_28_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_28_PULLUP {enabled} \
    CONFIG.PCW_MIO_28_SLEW {fast} \
    CONFIG.PCW_MIO_29_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_29_PULLUP {enabled} \
    CONFIG.PCW_MIO_29_SLEW {fast} \
    CONFIG.PCW_MIO_2_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_2_SLEW {slow} \
    CONFIG.PCW_MIO_30_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_30_PULLUP {enabled} \
    CONFIG.PCW_MIO_30_SLEW {fast} \
    CONFIG.PCW_MIO_31_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_31_PULLUP {enabled} \
    CONFIG.PCW_MIO_31_SLEW {fast} \
    CONFIG.PCW_MIO_32_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_32_PULLUP {enabled} \
    CONFIG.PCW_MIO_32_SLEW {fast} \
    CONFIG.PCW_MIO_33_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_33_PULLUP {enabled} \
    CONFIG.PCW_MIO_33_SLEW {fast} \
    CONFIG.PCW_MIO_34_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_34_PULLUP {enabled} \
    CONFIG.PCW_MIO_34_SLEW {fast} \
    CONFIG.PCW_MIO_35_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_35_PULLUP {enabled} \
    CONFIG.PCW_MIO_35_SLEW {fast} \
    CONFIG.PCW_MIO_36_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_36_PULLUP {enabled} \
    CONFIG.PCW_MIO_36_SLEW {fast} \
    CONFIG.PCW_MIO_37_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_37_PULLUP {enabled} \
    CONFIG.PCW_MIO_37_SLEW {fast} \
    CONFIG.PCW_MIO_38_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_38_PULLUP {enabled} \
    CONFIG.PCW_MIO_38_SLEW {fast} \
    CONFIG.PCW_MIO_39_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_39_PULLUP {enabled} \
    CONFIG.PCW_MIO_39_SLEW {fast} \
    CONFIG.PCW_MIO_3_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_3_SLEW {slow} \
    CONFIG.PCW_MIO_40_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_40_PULLUP {enabled} \
    CONFIG.PCW_MIO_40_SLEW {slow} \
    CONFIG.PCW_MIO_41_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_41_PULLUP {enabled} \
    CONFIG.PCW_MIO_41_SLEW {slow} \
    CONFIG.PCW_MIO_42_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_42_PULLUP {enabled} \
    CONFIG.PCW_MIO_42_SLEW {slow} \
    CONFIG.PCW_MIO_43_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_43_PULLUP {enabled} \
    CONFIG.PCW_MIO_43_SLEW {slow} \
    CONFIG.PCW_MIO_44_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_44_PULLUP {enabled} \
    CONFIG.PCW_MIO_44_SLEW {slow} \
    CONFIG.PCW_MIO_45_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_45_PULLUP {enabled} \
    CONFIG.PCW_MIO_45_SLEW {slow} \
    CONFIG.PCW_MIO_46_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_46_PULLUP {enabled} \
    CONFIG.PCW_MIO_46_SLEW {slow} \
    CONFIG.PCW_MIO_47_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_47_PULLUP {enabled} \
    CONFIG.PCW_MIO_47_SLEW {slow} \
    CONFIG.PCW_MIO_48_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_48_PULLUP {enabled} \
    CONFIG.PCW_MIO_48_SLEW {slow} \
    CONFIG.PCW_MIO_49_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_49_PULLUP {enabled} \
    CONFIG.PCW_MIO_49_SLEW {slow} \
    CONFIG.PCW_MIO_4_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_4_SLEW {slow} \
    CONFIG.PCW_MIO_50_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_50_PULLUP {enabled} \
    CONFIG.PCW_MIO_50_SLEW {slow} \
    CONFIG.PCW_MIO_51_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_51_PULLUP {enabled} \
    CONFIG.PCW_MIO_51_SLEW {slow} \
    CONFIG.PCW_MIO_52_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_52_PULLUP {enabled} \
    CONFIG.PCW_MIO_52_SLEW {slow} \
    CONFIG.PCW_MIO_53_IOTYPE {LVCMOS 2.5V} \
    CONFIG.PCW_MIO_53_PULLUP {enabled} \
    CONFIG.PCW_MIO_53_SLEW {slow} \
    CONFIG.PCW_MIO_5_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_5_SLEW {slow} \
    CONFIG.PCW_MIO_6_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_6_SLEW {slow} \
    CONFIG.PCW_MIO_7_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_7_SLEW {slow} \
    CONFIG.PCW_MIO_8_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_8_SLEW {slow} \
    CONFIG.PCW_MIO_9_IOTYPE {LVCMOS 3.3V} \
    CONFIG.PCW_MIO_9_PULLUP {enabled} \
    CONFIG.PCW_MIO_9_SLEW {slow} \
    CONFIG.PCW_MIO_TREE_PERIPHERALS {GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#UART 1#UART 1#SPI 1#SPI 1#SPI 1#SPI 1#UART 0#UART 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet\
0#Enet 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#SD 0#SD 0#SD 0#SD 0#SD 0#SD 0#SD 0#SD 0#USB Reset#GPIO#I2C 0#I2C 0#Enet 0#Enet 0} \
    CONFIG.PCW_MIO_TREE_SIGNALS {gpio[0]#gpio[1]#gpio[2]#gpio[3]#gpio[4]#gpio[5]#gpio[6]#gpio[7]#tx#rx#mosi#miso#sclk#ss[0]#rx#tx#tx_clk#txd[0]#txd[1]#txd[2]#txd[3]#tx_ctl#rx_clk#rxd[0]#rxd[1]#rxd[2]#rxd[3]#rx_ctl#data[4]#dir#stp#nxt#data[0]#data[1]#data[2]#data[3]#clk#data[5]#data[6]#data[7]#clk#cmd#data[0]#data[1]#data[2]#data[3]#cd#wp#reset#gpio[49]#scl#sda#mdc#mdio}\
\
    CONFIG.PCW_NAND_CYCLES_T_AR {1} \
    CONFIG.PCW_NAND_CYCLES_T_CLR {1} \
    CONFIG.PCW_NAND_CYCLES_T_RC {11} \
    CONFIG.PCW_NAND_CYCLES_T_REA {1} \
    CONFIG.PCW_NAND_CYCLES_T_RR {1} \
    CONFIG.PCW_NAND_CYCLES_T_WC {11} \
    CONFIG.PCW_NAND_CYCLES_T_WP {1} \
    CONFIG.PCW_NAND_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_NOR_CS0_T_CEOE {1} \
    CONFIG.PCW_NOR_CS0_T_PC {1} \
    CONFIG.PCW_NOR_CS0_T_RC {11} \
    CONFIG.PCW_NOR_CS0_T_TR {1} \
    CONFIG.PCW_NOR_CS0_T_WC {11} \
    CONFIG.PCW_NOR_CS0_T_WP {1} \
    CONFIG.PCW_NOR_CS0_WE_TIME {0} \
    CONFIG.PCW_NOR_CS1_T_CEOE {1} \
    CONFIG.PCW_NOR_CS1_T_PC {1} \
    CONFIG.PCW_NOR_CS1_T_RC {11} \
    CONFIG.PCW_NOR_CS1_T_TR {1} \
    CONFIG.PCW_NOR_CS1_T_WC {11} \
    CONFIG.PCW_NOR_CS1_T_WP {1} \
    CONFIG.PCW_NOR_CS1_WE_TIME {0} \
    CONFIG.PCW_NOR_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_NOR_SRAM_CS0_T_CEOE {1} \
    CONFIG.PCW_NOR_SRAM_CS0_T_PC {1} \
    CONFIG.PCW_NOR_SRAM_CS0_T_RC {11} \
    CONFIG.PCW_NOR_SRAM_CS0_T_TR {1} \
    CONFIG.PCW_NOR_SRAM_CS0_T_WC {11} \
    CONFIG.PCW_NOR_SRAM_CS0_T_WP {1} \
    CONFIG.PCW_NOR_SRAM_CS0_WE_TIME {0} \
    CONFIG.PCW_NOR_SRAM_CS1_T_CEOE {1} \
    CONFIG.PCW_NOR_SRAM_CS1_T_PC {1} \
    CONFIG.PCW_NOR_SRAM_CS1_T_RC {11} \
    CONFIG.PCW_NOR_SRAM_CS1_T_TR {1} \
    CONFIG.PCW_NOR_SRAM_CS1_T_WC {11} \
    CONFIG.PCW_NOR_SRAM_CS1_T_WP {1} \
    CONFIG.PCW_NOR_SRAM_CS1_WE_TIME {0} \
    CONFIG.PCW_OVERRIDE_BASIC_CLOCK {0} \
    CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY0 {0.080} \
    CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY1 {0.063} \
    CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY2 {0.057} \
    CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY3 {0.068} \
    CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_0 {-0.047} \
    CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_1 {-0.025} \
    CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_2 {-0.006} \
    CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_3 {-0.017} \
    CONFIG.PCW_PCAP_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_PCAP_PERIPHERAL_FREQMHZ {200} \
    CONFIG.PCW_PJTAG_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_PLL_BYPASSMODE_ENABLE {0} \
    CONFIG.PCW_PRESET_BANK0_VOLTAGE {LVCMOS 3.3V} \
    CONFIG.PCW_PRESET_BANK1_VOLTAGE {LVCMOS 2.5V} \
    CONFIG.PCW_QSPI_INTERNAL_HIGHADDRESS {0xFCFFFFFF} \
    CONFIG.PCW_QSPI_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_SD0_GRP_CD_ENABLE {1} \
    CONFIG.PCW_SD0_GRP_CD_IO {MIO 46} \
    CONFIG.PCW_SD0_GRP_POW_ENABLE {0} \
    CONFIG.PCW_SD0_GRP_WP_ENABLE {1} \
    CONFIG.PCW_SD0_GRP_WP_IO {MIO 47} \
    CONFIG.PCW_SD0_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_SD0_SD0_IO {MIO 40 .. 45} \
    CONFIG.PCW_SD1_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_SDIO_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_SDIO_PERIPHERAL_FREQMHZ {100} \
    CONFIG.PCW_SDIO_PERIPHERAL_VALID {1} \
    CONFIG.PCW_SMC_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_SMC_PERIPHERAL_VALID {0} \
    CONFIG.PCW_SPI0_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_SPI0_SPI0_IO {EMIO} \
    CONFIG.PCW_SPI1_GRP_SS1_ENABLE {0} \
    CONFIG.PCW_SPI1_GRP_SS2_ENABLE {0} \
    CONFIG.PCW_SPI1_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_SPI1_SPI1_IO {MIO 10 .. 15} \
    CONFIG.PCW_SPI_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_SPI_PERIPHERAL_FREQMHZ {166.666666} \
    CONFIG.PCW_SPI_PERIPHERAL_VALID {1} \
    CONFIG.PCW_S_AXI_HP1_DATA_WIDTH {64} \
    CONFIG.PCW_S_AXI_HP2_DATA_WIDTH {64} \
    CONFIG.PCW_S_AXI_HP3_DATA_WIDTH {64} \
    CONFIG.PCW_TPIU_PERIPHERAL_CLKSRC {External} \
    CONFIG.PCW_TRACE_INTERNAL_WIDTH {2} \
    CONFIG.PCW_TRACE_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_TTC0_CLK0_PERIPHERAL_CLKSRC {CPU_1X} \
    CONFIG.PCW_TTC0_CLK0_PERIPHERAL_DIVISOR0 {1} \
    CONFIG.PCW_TTC0_CLK1_PERIPHERAL_CLKSRC {CPU_1X} \
    CONFIG.PCW_TTC0_CLK1_PERIPHERAL_DIVISOR0 {1} \
    CONFIG.PCW_TTC0_CLK2_PERIPHERAL_CLKSRC {CPU_1X} \
    CONFIG.PCW_TTC0_CLK2_PERIPHERAL_DIVISOR0 {1} \
    CONFIG.PCW_TTC0_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_TTC1_CLK0_PERIPHERAL_CLKSRC {CPU_1X} \
    CONFIG.PCW_TTC1_CLK0_PERIPHERAL_DIVISOR0 {1} \
    CONFIG.PCW_TTC1_CLK1_PERIPHERAL_CLKSRC {CPU_1X} \
    CONFIG.PCW_TTC1_CLK1_PERIPHERAL_DIVISOR0 {1} \
    CONFIG.PCW_TTC1_CLK2_PERIPHERAL_CLKSRC {CPU_1X} \
    CONFIG.PCW_TTC1_CLK2_PERIPHERAL_DIVISOR0 {1} \
    CONFIG.PCW_TTC1_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_UART0_BAUD_RATE {115200} \
    CONFIG.PCW_UART0_GRP_FULL_ENABLE {0} \
    CONFIG.PCW_UART0_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_UART0_UART0_IO {MIO 14 .. 15} \
    CONFIG.PCW_UART1_BAUD_RATE {115200} \
    CONFIG.PCW_UART1_GRP_FULL_ENABLE {0} \
    CONFIG.PCW_UART1_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_UART1_UART1_IO {MIO 8 .. 9} \
    CONFIG.PCW_UART_PERIPHERAL_CLKSRC {IO PLL} \
    CONFIG.PCW_UART_PERIPHERAL_FREQMHZ {100} \
    CONFIG.PCW_UART_PERIPHERAL_VALID {1} \
    CONFIG.PCW_UIPARAM_ACT_DDR_FREQ_MHZ {533.333374} \
    CONFIG.PCW_UIPARAM_DDR_ADV_ENABLE {0} \
    CONFIG.PCW_UIPARAM_DDR_AL {0} \
    CONFIG.PCW_UIPARAM_DDR_BL {8} \
    CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY0 {0.25} \
    CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY1 {0.25} \
    CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY2 {0.25} \
    CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY3 {0.25} \
    CONFIG.PCW_UIPARAM_DDR_BUS_WIDTH {16 Bit} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_0_LENGTH_MM {0} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_0_PACKAGE_LENGTH {54.563} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_0_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_1_LENGTH_MM {0} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_1_PACKAGE_LENGTH {54.563} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_1_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_2_LENGTH_MM {0} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_2_PACKAGE_LENGTH {54.563} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_2_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_3_LENGTH_MM {0} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_3_PACKAGE_LENGTH {54.563} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_3_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_STOP_EN {0} \
    CONFIG.PCW_UIPARAM_DDR_DQS_0_LENGTH_MM {0} \
    CONFIG.PCW_UIPARAM_DDR_DQS_0_PACKAGE_LENGTH {101.239} \
    CONFIG.PCW_UIPARAM_DDR_DQS_0_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_DQS_1_LENGTH_MM {0} \
    CONFIG.PCW_UIPARAM_DDR_DQS_1_PACKAGE_LENGTH {79.5025} \
    CONFIG.PCW_UIPARAM_DDR_DQS_1_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_DQS_2_LENGTH_MM {0} \
    CONFIG.PCW_UIPARAM_DDR_DQS_2_PACKAGE_LENGTH {60.536} \
    CONFIG.PCW_UIPARAM_DDR_DQS_2_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_DQS_3_LENGTH_MM {0} \
    CONFIG.PCW_UIPARAM_DDR_DQS_3_PACKAGE_LENGTH {71.7715} \
    CONFIG.PCW_UIPARAM_DDR_DQS_3_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_0 {0.0} \
    CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_1 {0.0} \
    CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_2 {0.0} \
    CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_3 {0.0} \
    CONFIG.PCW_UIPARAM_DDR_DQ_0_LENGTH_MM {0} \
    CONFIG.PCW_UIPARAM_DDR_DQ_0_PACKAGE_LENGTH {104.5365} \
    CONFIG.PCW_UIPARAM_DDR_DQ_0_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_DQ_1_LENGTH_MM {0} \
    CONFIG.PCW_UIPARAM_DDR_DQ_1_PACKAGE_LENGTH {70.676} \
    CONFIG.PCW_UIPARAM_DDR_DQ_1_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_DQ_2_LENGTH_MM {0} \
    CONFIG.PCW_UIPARAM_DDR_DQ_2_PACKAGE_LENGTH {59.1615} \
    CONFIG.PCW_UIPARAM_DDR_DQ_2_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_DQ_3_LENGTH_MM {0} \
    CONFIG.PCW_UIPARAM_DDR_DQ_3_PACKAGE_LENGTH {81.319} \
    CONFIG.PCW_UIPARAM_DDR_DQ_3_PROPOGATION_DELAY {160} \
    CONFIG.PCW_UIPARAM_DDR_ECC {Disabled} \
    CONFIG.PCW_UIPARAM_DDR_ENABLE {1} \
    CONFIG.PCW_UIPARAM_DDR_FREQ_MHZ {533.333333} \
    CONFIG.PCW_UIPARAM_DDR_HIGH_TEMP {Normal (0-85)} \
    CONFIG.PCW_UIPARAM_DDR_MEMORY_TYPE {DDR 3} \
    CONFIG.PCW_UIPARAM_DDR_PARTNO {MT41J256M16 RE-125} \
    CONFIG.PCW_UIPARAM_DDR_TRAIN_DATA_EYE {1} \
    CONFIG.PCW_UIPARAM_DDR_TRAIN_READ_GATE {1} \
    CONFIG.PCW_UIPARAM_DDR_TRAIN_WRITE_LEVEL {1} \
    CONFIG.PCW_UIPARAM_DDR_USE_INTERNAL_VREF {0} \
    CONFIG.PCW_USB0_PERIPHERAL_ENABLE {1} \
    CONFIG.PCW_USB0_RESET_ENABLE {1} \
    CONFIG.PCW_USB0_RESET_IO {MIO 48} \
    CONFIG.PCW_USB0_USB0_IO {MIO 28 .. 39} \
    CONFIG.PCW_USB1_PERIPHERAL_ENABLE {0} \
    CONFIG.PCW_USB_RESET_ENABLE {1} \
    CONFIG.PCW_USB_RESET_POLARITY {Active Low} \
    CONFIG.PCW_USB_RESET_SELECT {Share reset pin} \
    CONFIG.PCW_USE_AXI_NONSECURE {0} \
    CONFIG.PCW_USE_CROSS_TRIGGER {0} \
    CONFIG.PCW_USE_M_AXI_GP1 {1} \
    CONFIG.PCW_USE_S_AXI_ACP {0} \
    CONFIG.PCW_USE_S_AXI_HP0 {1} \
    CONFIG.PCW_WDT_PERIPHERAL_CLKSRC {CPU_1X} \
    CONFIG.PCW_WDT_PERIPHERAL_DIVISOR0 {1} \
    CONFIG.PCW_WDT_PERIPHERAL_ENABLE {0} \
  ] $ps_0


  # Create instance: const_0, and set properties
  set block_name constant
  set block_cell_name const_0
  if { [catch {set const_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $const_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: rst_0, and set properties
  set rst_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_0 ]

  # Create instance: adc_0, and set properties
  set block_name axis_red_pitaya_adc
  set block_cell_name adc_0
  if { [catch {set adc_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $adc_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property CONFIG.ADC_DATA_WIDTH {14} $adc_0


  # Create instance: dac_0, and set properties
  set block_name axis_red_pitaya_dac
  set block_cell_name dac_0
  if { [catch {set dac_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $dac_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property CONFIG.DAC_DATA_WIDTH {14} $dac_0


  # Create instance: rx_0
  create_hier_cell_rx_0 [current_bd_instance .] rx_0

  # Create instance: test_0
  create_hier_cell_test_0 [current_bd_instance .] test_0

  # Create interface connections
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_pins test_0/s_axi_0] [get_bd_intf_pins ps_0/M_AXI_GP1]
  connect_bd_intf_net -intf_net S_AXIS_A_1 [get_bd_intf_pins rx_0/s_axis_adc] [get_bd_intf_pins adc_0/m_axis]
  connect_bd_intf_net -intf_net ps_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins ps_0/DDR]
  connect_bd_intf_net -intf_net ps_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins ps_0/FIXED_IO]
  connect_bd_intf_net -intf_net ps_0_M_AXI_GP0 [get_bd_intf_pins ps_0/M_AXI_GP0] [get_bd_intf_pins rx_0/s_axi]
  connect_bd_intf_net -intf_net test_0_m_axi_ram [get_bd_intf_pins test_0/m_axi_ram] [get_bd_intf_pins ps_0/S_AXI_HP0]
  connect_bd_intf_net -intf_net test_0_m_axis_0 [get_bd_intf_pins dac_0/s_axis] [get_bd_intf_pins test_0/m_axis_fifo]

  # Create port connections
  connect_bd_net -net adc_0_adc_csn  [get_bd_pins adc_0/adc_csn] \
  [get_bd_ports adc_csn_o]
  connect_bd_net -net adc_clk_n_i_1  [get_bd_ports adc_clk_n_i] \
  [get_bd_pins pll_0/clk_in1_n]
  connect_bd_net -net adc_clk_p_i_1  [get_bd_ports adc_clk_p_i] \
  [get_bd_pins pll_0/clk_in1_p]
  connect_bd_net -net adc_dat_a_i_1  [get_bd_ports adc_dat_a_i] \
  [get_bd_pins adc_0/adc_dat_a]
  connect_bd_net -net adc_dat_b_i_1  [get_bd_ports adc_dat_b_i] \
  [get_bd_pins adc_0/adc_dat_b]
  connect_bd_net -net const_0_dout  [get_bd_pins const_0/dout] \
  [get_bd_pins rst_0/ext_reset_in]
  connect_bd_net -net dac_0_dac_clk  [get_bd_pins dac_0/dac_clk] \
  [get_bd_ports dac_clk_o]
  connect_bd_net -net dac_0_dac_dat  [get_bd_pins dac_0/dac_dat] \
  [get_bd_ports dac_dat_o]
  connect_bd_net -net dac_0_dac_rst  [get_bd_pins dac_0/dac_rst] \
  [get_bd_ports dac_rst_o]
  connect_bd_net -net dac_0_dac_sel  [get_bd_pins dac_0/dac_sel] \
  [get_bd_ports dac_sel_o]
  connect_bd_net -net dac_0_dac_wrt  [get_bd_pins dac_0/dac_wrt] \
  [get_bd_ports dac_wrt_o]
  connect_bd_net -net pll_0_clk_out1  [get_bd_pins pll_0/clk_out1] \
  [get_bd_pins ps_0/M_AXI_GP0_ACLK] \
  [get_bd_pins rst_0/slowest_sync_clk] \
  [get_bd_pins adc_0/aclk] \
  [get_bd_pins dac_0/aclk] \
  [get_bd_pins rx_0/aclk] \
  [get_bd_pins ps_0/M_AXI_GP1_ACLK] \
  [get_bd_pins test_0/aclk] \
  [get_bd_pins ps_0/S_AXI_HP0_ACLK]
  connect_bd_net -net pll_0_clk_out2  [get_bd_pins pll_0/clk_out2] \
  [get_bd_pins dac_0/ddr_clk]
  connect_bd_net -net pll_0_clk_out3  [get_bd_pins pll_0/clk_out3] \
  [get_bd_pins dac_0/wrt_clk]
  connect_bd_net -net pll_0_locked  [get_bd_pins pll_0/locked] \
  [get_bd_pins rst_0/dcm_locked] \
  [get_bd_pins dac_0/locked]
  connect_bd_net -net rst_0_peripheral_aresetn  [get_bd_pins rst_0/peripheral_aresetn] \
  [get_bd_pins rx_0/aresetn] \
  [get_bd_pins test_0/aresetn]

  # Create address segments
  assign_bd_address -offset 0x80000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces ps_0/Data] [get_bd_addr_segs test_0/axi_hub_0/s_axi/reg0] -force
  assign_bd_address -offset 0x40000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces ps_0/Data] [get_bd_addr_segs rx_0/hub_0/s_axi/reg0] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


