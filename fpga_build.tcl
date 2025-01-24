# FPGA Build System Tcl Script
# Automates synthesis, simulation, and bitstream generation for an FPGA project
# Compatible with Xilinx Vivado, Intel Quartus, or Verilator

# Set defaults
set tool "Vivado" ;# Default tool
set project_dir "./" ; # Default project directory
set top_module "top" ; # Default top module name
set log_file "build.log" ; # Log file for detailed debugging
set custom_args "" ; # Custom arguments for tools


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

# Procedure for logging
proc log_message {message} {
	global log_file
	set timestamp [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]
	set log_entry "$timestamp - $message\n"
	puts $log_entry
	append log_file_handle $log_entry
}

# Open log file
set log_file_handle [open $log_file "w"]
log_message "Build process started"

# Prompt the user for settings
set tool [prompt_user "Select tool (Vivado/Quartus/Verilator)" $tool]
set project_dir [ prompt_user "Enter the project directory" $project_dir ]
set top_module [prompt_user "Enter top module name" $top_module ]
set custom_args [prompt_user "Enter custom arguments for the tool" $custom_args]


# Validate tool selection
if {![regexp -nocase "^(Vivado|Quartus|Verilator)$" $tool]} {
	puts "Error: Unsupported tool '$tool'. Exiting."
	exit 1
}

# Valudate project directory
if {![file isdirectory $project_dir]} {
	log_message "Error: Project directory '$project_dir' does not exist. Exiting..."
	exit 1
}

# Validate top module file exists
set top_file "$project_dir/$top_module.v"
if {![file exists $top_file]} {
	log_message "Error: Top module file '$top_file' does not exist. Exiting ..."
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


# Set Quartus-specific commands
proc quartus_flow {project_dir top_module} {
	puts "Starting Quartus flow..."
	catch {
		exec quartus_map --read_settings_files=on --write_settings_files=off $top_module
		exec quartus_fit --read_settings_files=on --write_settings_files=off $top_module
		exec quartus_asm --read_settings_files=on --write_settings_files=off $top_module
		exec quartus_sta $top_module
	} err 
	if {[info exists err]} {
	    puts "Quartus flow encountered an error: $err"
	    return
	}
	puts "Quartus flow completed successfully."
}

# Set Verilator-specific commands
proc verilator_flow {project_dir top_module} {
	puts "Starting Verilator flow..."
	catch {
		exec verilator --cc $project_dir/$top_module.v -exe sim_main.cpp
		exec make -C obj_dir -f V$top_module.mk
		exec ./obj_dir/V$top_module
	} err
	if {[info exists err]} {
		puts "Verilator flow encountered an error: $err"
		return
	}
	puts "Verilator flow completed successfully"
}

# set Lattice Diamond-specific commands
proc diamond_flow {project_dir top_module custom_args} {
	log_message "Starting Lattice Diamond flow..."
	catch {
		exec diamondc --impl "$project_dir/$top_module.ldf" $custom_args
	} err
	if {[info exists err]} {
		log_message "Lattice Diamond flow encountered an error: $err"
		return
	}
	log_message "Lattice Diamond flow completed successfully."
}

# Dispatch based on the selected tool
if {[string tolower $tool] eq "vivado"} {
	vivado_flow $project_dir $top_module $custom_args
} elseif {[string tolower $tool] eq "quartus"} {
	quartus_flow $project_dir $top_module $custom_args
} elseif {[string tolower $tool] eq "verilator"} {
	verilator_flow $project_dir $top_module $custom_args
} elseif {[string tolower $tool] eq "diamond"} {
        diamond_flow $project_dir $top_module $custom_args
} else {
	puts "Error: Unknown tool $tool."
	exit 1
}
log_message "Build process completed."
close $log_file_handle
