#!/bin/csh
# CRC Verification Simulation Script
# =====================================================
# תיאור: Script להרצת Simulation

set WORK_DIR = crc_work
set TB_DIR = tb
set SRC_DIR = src
set SIM_DIR = sim

# Create work directory
if (! -d $WORK_DIR) then
    mkdir -p $WORK_DIR
endif

# Compile Verilog
echo "================================================"
echo "Compiling Verilog Sources..."
echo "================================================"

vlog -work $WORK_DIR \
    +incdir+$SRC_DIR \
    +define+SIM \
    $TB_DIR/crc_dut.sv \
    $TB_DIR/crc_tb_top.sv

if ($status != 0) then
    echo "ERROR: Compilation failed"
    exit 1
endif

echo ""
echo "================================================"
echo "Running Simulation..."
echo "================================================"

# Ensure TESTNAME is set (default to crc_smoke_test)
if (! $?TESTNAME) then
    setenv TESTNAME crc_smoke_test
endif

vsim -work $WORK_DIR \
    -voptargs="+acc" \
    +UVM_TESTNAME=$TESTNAME \
    crc_tb_top

echo ""
echo "================================================"
echo "Simulation Complete"
echo "================================================"
