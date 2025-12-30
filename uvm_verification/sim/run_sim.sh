#!/bin/bash
# CRC Verification Simulation Script (Bash)
# =====================================================
# תיאור: Script להרצת Simulation בBash

WORK_DIR="crc_work"
TB_DIR="tb"
SRC_DIR="src"
SIM_DIR="sim"

# Create work directory
mkdir -p $WORK_DIR

# Compile Verilog
echo "================================================"
echo "Compiling Verilog Sources..."
echo "================================================"

vlog -work $WORK_DIR \
    +incdir+$SRC_DIR \
    +define+SIM \
    $TB_DIR/crc_dut.sv \
    $TB_DIR/crc_tb_top.sv

if [ $? -ne 0 ]; then
    echo "ERROR: Compilation failed"
    exit 1
fi

echo ""
echo "================================================"
echo "Running Simulation..."
echo "================================================"

vsim -work $WORK_DIR \
    -voptargs="+acc" \
    +UVM_TESTNAME=${TESTNAME:-crc_smoke_test} \
    crc_tb_top

echo ""
echo "================================================"
echo "Simulation Complete"
echo "================================================"
