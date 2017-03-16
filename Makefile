# Copyright (c) Gyorgy Wyatt Muntean 2017
# This makefile builds the Matrix Multiply Xilinx project.

ROOTDIR=.
DONTCLEAN = -maxdepth 1 -not -name "Makefile" -not -name "README.md" -not -name "srcs" -not -name "sim" -not -name ".git" -not -name ".gitignore" -not -name "project_tcl.tcl" -not -name "."

# Common Vivado options
VIVADOCOMOPS = -mode batch

# Main target
all : setup

# This setups up the top level project
setup :
	vivado $(VIVADOCOMOPS) -source $(ROOTDIR)/project_tcl.tcl -log project_tcl.log -jou project_tcl.jou

# delete everything except this Makefile and any .tcl scripts
clean :
	find . $(DONTCLEAN) | xargs rm -rf
