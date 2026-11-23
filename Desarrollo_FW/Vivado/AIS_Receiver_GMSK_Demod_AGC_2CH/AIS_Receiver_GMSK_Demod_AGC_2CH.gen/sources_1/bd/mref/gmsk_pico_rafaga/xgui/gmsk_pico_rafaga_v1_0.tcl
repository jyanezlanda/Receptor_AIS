# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DUR_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "N_IGNORAR" -parent ${Page_0}


}

proc update_PARAM_VALUE.DATA_WIDTH { PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to update DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_WIDTH { PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to validate DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.DUR_WIDTH { PARAM_VALUE.DUR_WIDTH } {
	# Procedure called to update DUR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DUR_WIDTH { PARAM_VALUE.DUR_WIDTH } {
	# Procedure called to validate DUR_WIDTH
	return true
}

proc update_PARAM_VALUE.N_IGNORAR { PARAM_VALUE.N_IGNORAR } {
	# Procedure called to update N_IGNORAR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.N_IGNORAR { PARAM_VALUE.N_IGNORAR } {
	# Procedure called to validate N_IGNORAR
	return true
}


proc update_MODELPARAM_VALUE.DATA_WIDTH { MODELPARAM_VALUE.DATA_WIDTH PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_WIDTH}] ${MODELPARAM_VALUE.DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.N_IGNORAR { MODELPARAM_VALUE.N_IGNORAR PARAM_VALUE.N_IGNORAR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.N_IGNORAR}] ${MODELPARAM_VALUE.N_IGNORAR}
}

proc update_MODELPARAM_VALUE.DUR_WIDTH { MODELPARAM_VALUE.DUR_WIDTH PARAM_VALUE.DUR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DUR_WIDTH}] ${MODELPARAM_VALUE.DUR_WIDTH}
}

