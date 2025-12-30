# CRC Verification Makefile
# =====================================================
# תיאור: Makefile להריצת Simulation וManagement של Files

.PHONY: all compile simulate clean help

SIMULATOR ?= modelsim
TESTNAME ?= crc_smoke_test
WORK_DIR = crc_work
TB_DIR = tb
SRC_DIR = src
SIM_DIR = sim

all: compile

# =====================================================
# Compile Target
# =====================================================
compile:
	@echo "================================================"
	@echo "Compiling CRC Verification Environment..."
	@echo "================================================"
	@mkdir -p $(WORK_DIR)
ifeq ($(SIMULATOR),modelsim)
	vlib $(WORK_DIR)
	vmap work $(WORK_DIR)
	vlog -work $(WORK_DIR) \
		+incdir+$(SRC_DIR) \
		+define+SIM \
		$(TB_DIR)/crc_dut.sv \
		$(TB_DIR)/crc_tb_top.sv
else ifeq ($(SIMULATOR),questasim)
	qvlog -work $(WORK_DIR) \
		+incdir+$(SRC_DIR) \
		+define+SIM \
		$(TB_DIR)/crc_dut.sv \
		$(TB_DIR)/crc_tb_top.sv
else ifeq ($(SIMULATOR),xsim)
	xvlog -work $(WORK_DIR) \
		--include $(SRC_DIR) \
		$(TB_DIR)/crc_dut.sv \
		$(TB_DIR)/crc_tb_top.sv
endif
	@echo "Compilation completed successfully"

# =====================================================
# Simulate Target
# =====================================================
simulate: compile
	@echo "================================================"
	@echo "Running Simulation: $(TESTNAME)"
	@echo "================================================"
ifeq ($(SIMULATOR),modelsim)
	vsim -work $(WORK_DIR) \
		-voptargs="+acc" \
		+UVM_TESTNAME=$(TESTNAME) \
		crc_tb_top
else ifeq ($(SIMULATOR),questasim)
	qsim -work $(WORK_DIR) \
		-voptargs="+acc" \
		+UVM_TESTNAME=$(TESTNAME) \
		crc_tb_top
endif

# =====================================================
# Batch Simulation Target
# =====================================================
sim_batch: compile
	@echo "================================================"
	@echo "Running Batch Simulation: $(TESTNAME)"
	@echo "================================================"
ifeq ($(SIMULATOR),modelsim)
	vsim -batch -work $(WORK_DIR) \
		-do "run -all; quit" \
		+UVM_TESTNAME=$(TESTNAME) \
		crc_tb_top
else ifeq ($(SIMULATOR),questasim)
	qsim -batch -work $(WORK_DIR) \
		-do "run -all; quit" \
		+UVM_TESTNAME=$(TESTNAME) \
		crc_tb_top
endif

# =====================================================
# Run All Tests
# =====================================================
test_all:
	@echo "Running Smoke Test..."
	@$(MAKE) sim_batch TESTNAME=crc_smoke_test
	@echo "Running Directed Test..."
	@$(MAKE) sim_batch TESTNAME=crc_directed_test
	@echo "Running Edge Case Test..."
	@$(MAKE) sim_batch TESTNAME=crc_edge_case_test
	@echo "Running Selection Test..."
	@$(MAKE) sim_batch TESTNAME=crc_selection_test
	@echo "All tests completed"

# =====================================================
# Clean Target
# =====================================================
clean:
	@echo "Cleaning up..."
	rm -rf $(WORK_DIR)
	rm -f crc_tb.vcd
	rm -f *~
	rm -f *.log
	@echo "Cleanup completed"

# =====================================================
# Help Target
# =====================================================
help:
	@echo "================================================"
	@echo "CRC Verification Environment - Makefile Help"
	@echo "================================================"
	@echo ""
	@echo "Available targets:"
	@echo "  all          - Compile sources (default)"
	@echo "  compile      - Compile Verilog files"
	@echo "  simulate     - Run GUI simulation"
	@echo "  sim_batch    - Run batch simulation"
	@echo "  test_all     - Run all test cases"
	@echo "  clean        - Remove generated files"
	@echo "  help         - Show this help message"
	@echo ""
	@echo "Variables:"
	@echo "  SIMULATOR    - Simulator to use (default: modelsim)"
	@echo "               Options: modelsim, questasim, xsim"
	@echo "  TESTNAME     - Test to run (default: crc_smoke_test)"
	@echo "               Options: crc_smoke_test, crc_directed_test, crc_edge_case_test, crc_selection_test"
	@echo ""
	@echo "Examples:"
	@echo "  make                          # Compile only"
	@echo "  make simulate                 # Run GUI simulation (smoke test)"
	@echo "  make sim_batch TESTNAME=crc_directed_test  # Run batch directed test"
	@echo "  make test_all                 # Run all tests in batch mode"
	@echo "  make clean                    # Clean all generated files"
	@echo ""
	@echo "================================================"

.DEFAULT_GOAL := help
