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

# Prompt the user for settings
set tool [prompt_user "Select tool (Vivado/Quartus/Verilator)" $tool]
set project_dir [ prompt_user "Enter the project directory" $project_dir ]
set top_module [prompt_user "Enter top module name" $top_module ]

# Validate tool selection
if {![regexp -nocase "^(Vivado|Quartus|Verilator)$" $tool] {
	puts "Error: Unsupported tool '$tool'. Exiting."
	exit 1
}

# Set Vivado-specific commands
proc vivado_flow {project_dir top_module} {
	puts "Starting Vivado flow..."
	catch {
		exec vivado -mode batch -source <<EOD
		   open_project $project_dir
		   read_verilog $project_dir/*.v
		   synth_design -top $top_module
		   opt_design
		   place_design
		   route_design
		   write_bitstream -force $project_dir/$top_module.bit
EOD
    } err
    if {[ info exists err]} {
	    puts "Vivado flow encountered an error: $err"
	    return
	  }
	  puts "Vivado flow completed successfully"
  }


