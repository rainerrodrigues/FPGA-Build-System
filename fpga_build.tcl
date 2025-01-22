# FPGA Build System Tcl Script
# Automates synthesis, simulation, and bitstream generation for an FPGA project
# Compatible with Xilinx Vivado, Intel Quartus, or Verilator

# Set defaults
set tool "Vivado" ;# Default tool
set project_dir "./" ; # Default project directory
set top_module "top" ; # Default top module name


