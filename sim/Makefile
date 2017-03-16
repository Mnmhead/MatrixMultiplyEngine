# Makefile for various simulation flows

# Testbench name
TOP=matrixMult
TB=$(TOP)_testbench

# Directories
SRC_DIR=../srcs
SCR_DIR=scripts
SRCS=`find $(SRC_DIR) -name "*.v"`

# Log file and executalbes
LOGF=sim.log
EXE=simv

# Simulation arguments
IVERARGS=-DVCD_DUMP

.PHONY: test

test: gen iver

gen:
	python $(SCR_DIR)/gen_inputs.py

iver:
	iverilog -s $(TB) $(IVERARGS) -o $(EXE) tb/$(TB).v $(SRCS) | tee $(LOGF)
	./$(EXE)

clean:
	rm -rf $(EXE) $(LOGF) *.vcd *.mif *.inc
