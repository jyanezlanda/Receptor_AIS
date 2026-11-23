# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "N_RAPIDO" -parent ${Page_0}
  ipgui::add_param $IPINST -name "SHIFT" -parent ${Page_0}
  ipgui::add_param $IPINST -name "SHIFT_RAPIDO" -parent ${Page_0}


}

proc update_PARAM_VALUE.DATA_WIDTH { PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to update DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_WIDTH { PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to validate DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.N_RAPIDO { PARAM_VALUE.N_RAPIDO } {
	# Procedure called to update N_RAPIDO when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.N_RAPIDO { PARAM_VALUE.N_RAPIDO } {
	# Procedure called to validate N_RAPIDO
	return true
}

proc update_PARAM_VALUE.SHIFT { PARAM_VALUE.SHIFT } {
	# Procedure called to update SHIFT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SHIFT { PARAM_VALUE.SHIFT } {
	# Procedure called to validate SHIFT
	return true
}

proc update_PARAM_VALUE.SHIFT_RAPIDO { PARAM_VALUE.SHIFT_RAPIDO } {
	# Procedure called to update SHIFT_RAPIDO when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SHIFT_RAPIDO { PARAM_VALUE.SHIFT_RAPIDO } {
	# Procedure called to validate SHIFT_RAPIDO
	return true
}


proc update_MODELPARAM_VALUE.DATA_WIDTH { MODELPARAM_VALUE.DATA_WIDTH PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_WIDTH}] ${MODELPARAM_VALUE.DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.SHIFT { MODELPARAM_VALUE.SHIFT PARAM_VALUE.SHIFT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SHIFT}] ${MODELPARAM_VALUE.SHIFT}
}

proc update_MODELPARAM_VALUE.SHIFT_RAPIDO { MODELPARAM_VALUE.SHIFT_RAPIDO PARAM_VALUE.SHIFT_RAPIDO } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SHIFT_RAPIDO}] ${MODELPARAM_VALUE.SHIFT_RAPIDO}
}

proc update_MODELPARAM_VALUE.N_RAPIDO { MODELPARAM_VALUE.N_RAPIDO PARAM_VALUE.N_RAPIDO } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.N_RAPIDO}] ${MODELPARAM_VALUE.N_RAPIDO}
}

