# FPGA Build System Tcl Script
# Automates synthesis, simulation, and bitstream generation for an FPGA project
# Compatible with Xilinx Vivado, Intel Quartus, or Verilator

# Set defaults
set tool "Vivado" ;# Default tool
set project_dir "./" ; # Default project directory
set top_module "top" ; # Default top module name

# Helper procedure for user prompts
proc prompt_user {message default} {
	puts -nonewline "$message (default: $default): "
	flush stdout
	gets stdin response
	if {[string trim $response] eq ""} {
		return $default
	} else {
		return $response
	}
}


