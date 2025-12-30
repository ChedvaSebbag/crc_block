# CRC Verification Environment Configuration
# =====================================================

# Simulator Configuration
SIMULATOR = modelsim
SIMULATOR_PATH = /opt/modelsim/bin

# Directories
WORK_DIR = crc_work
SRC_DIR = src
TB_DIR = tb
SIM_DIR = sim
REPORT_DIR = reports

# Verilog Configuration
INCLUDE_DIRS = +incdir+$(SRC_DIR)
DEFINES = +define+SIM +define+UVM_NO_DPI

# Compile Flags
VLOG_FLAGS = -work $(WORK_DIR) $(INCLUDE_DIRS) $(DEFINES)
VSIM_FLAGS = -voptargs="+acc" -suppress 1346

# Simulation Configuration
TIMEOUT = 100000
LOG_LEVEL = UVM_MEDIUM

# Test Configuration
TEST_NAMES = crc_smoke_test crc_directed_test crc_edge_case_test crc_selection_test

# Coverage Configuration
COVERAGE_ENABLED = 0
COVERAGE_OPTS = -cover bcest

# Waveform Configuration
DUMP_WAVES = 0
WAVEFORM_FILE = crc_tb.vcd

# Debug Configuration
DEBUG_ENABLED = 0
DEBUG_OPTS = -gui

# Batch Mode Configuration
BATCH_MODE = 1

# Number of Parallel Simulations
PARALLEL_JOBS = 1

# =====================================================
# Advanced Options
# =====================================================

# UVM Configuration
UVM_VERBOSITY = UVM_MEDIUM
UVM_TIMEOUT = 100000

# Random Seed
SEED = random

# Report Generation
GENERATE_REPORTS = 1
REPORT_FORMAT = html

# Analysis Configuration
RUN_ANALYSIS = 0
ANALYSIS_TYPES = coverage lint

# Regression Configuration
REGRESSION_MODE = 0
REGRESSION_SEED = fixed

# =====================================================
# End of Configuration
# =====================================================
