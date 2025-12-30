#!/bin/bash
# CRC Verification Environment - Setup Script
# =====================================================
# תיאור: Script להתקנה ותצורה ראשונית של הסביבה

set -e

echo "================================================"
echo "CRC Verification Environment - Setup Script"
echo "================================================"
echo ""

# Check if running from correct directory
if [ ! -f "src/crc_pkg.sv" ]; then
    echo "ERROR: Please run this script from the project root directory"
    exit 1
fi

echo "[1/5] Checking prerequisites..."
echo "------"

# Check for Perl
if ! command -v perl &> /dev/null; then
    echo "WARNING: Perl not found (optional)"
fi

# Check for Python
if ! command -v python3 &> /dev/null; then
    echo "WARNING: Python 3 not found (optional)"
fi

# Check for simulator
if ! command -v vlog &> /dev/null; then
    echo "WARNING: ModelSim/QuestaSim not found in PATH"
    echo "         Please add simulator to PATH: export PATH=\$PATH:/path/to/simulator/bin"
fi

echo "✓ Prerequisites check completed"
echo ""

echo "[2/5] Creating directories..."
echo "------"

mkdir -p crc_work
mkdir -p reports
mkdir -p logs

echo "✓ Created: crc_work/"
echo "✓ Created: reports/"
echo "✓ Created: logs/"
echo ""

echo "[3/5] Setting up environment variables..."
echo "------"

# Create setup script
cat > setup_env.sh << 'EOF'
#!/bin/bash
# Environment Setup for CRC Verification

# Add current directory to PATH for simulation
export PROJ_ROOT=$(pwd)
export PATH=$PROJ_ROOT/sim:$PATH

# ModelSim variables (adjust path if needed)
# export MODELSIM_PATH=/opt/modelsim/bin
# export PATH=$MODELSIM_PATH:$PATH

# Python path
export PYTHONPATH=$PROJ_ROOT:$PYTHONPATH

# UVM path (if using custom UVM)
# export UVM_HOME=/opt/uvm

echo "Environment setup complete!"
echo "Project root: $PROJ_ROOT"
EOF

chmod +x setup_env.sh
echo "✓ Created: setup_env.sh"
echo ""

echo "[4/5] Verifying file structure..."
echo "------"

required_files=(
    "src/crc_pkg.sv"
    "src/crc_defines.sv"
    "src/crc_if.sv"
    "src/crc_transaction.sv"
    "src/crc_driver.sv"
    "src/crc_sequencer.sv"
    "src/crc_monitor.sv"
    "src/crc_agent.sv"
    "src/crc_predictor.sv"
    "src/crc_scoreboard.sv"
    "src/crc_env.sv"
    "src/crc_seq_lib.sv"
    "src/crc_test.sv"
    "tb/crc_tb_top.sv"
    "tb/crc_dut.sv"
    "Makefile"
    "test_runner.py"
    "README.md"
    "GUIDE.md"
)

missing_files=0
for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✓ $file"
    else
        echo "✗ MISSING: $file"
        ((missing_files++))
    fi
done

if [ $missing_files -eq 0 ]; then
    echo ""
    echo "✓ All required files present!"
else
    echo ""
    echo "ERROR: $missing_files file(s) missing!"
    exit 1
fi
echo ""

echo "[5/5] Creating quick-start scripts..."
echo "------"

# Create quick test script
cat > quick_test.sh << 'EOF'
#!/bin/bash
# Quick test runner

if [ ! -d "crc_work" ]; then
    echo "Compiling..."
    make compile > /dev/null 2>&1
fi

echo "Running smoke test..."
make sim_batch TESTNAME=crc_smoke_test
EOF

chmod +x quick_test.sh
echo "✓ Created: quick_test.sh"

# Create help script
cat > help.sh << 'EOF'
#!/bin/bash
# Help script

echo "================================================"
echo "CRC Verification Environment - Quick Reference"
echo "================================================"
echo ""
echo "Setup:"
echo "  source setup_env.sh        - Setup environment"
echo ""
echo "Build & Run:"
echo "  make compile               - Compile sources"
echo "  make simulate              - Run GUI simulation"
echo "  make sim_batch             - Run batch simulation"
echo "  make test_all              - Run all tests"
echo "  make clean                 - Clean generated files"
echo ""
echo "Python Runner:"
echo "  python3 test_runner.py --help          - Show help"
echo "  python3 test_runner.py --compile       - Compile"
echo "  python3 test_runner.py --run-all       - Run all tests"
echo ""
echo "Quick Commands:"
echo "  bash quick_test.sh         - Run smoke test quickly"
echo "  bash help.sh               - Show this help"
echo ""
echo "Documentation:"
echo "  cat README.md              - Quick start"
echo "  cat GUIDE.md               - Full guide"
echo "  cat PROJECT_SUMMARY.txt    - Project overview"
echo ""
echo "================================================"
EOF

chmod +x help.sh
echo "✓ Created: help.sh"

echo ""
echo "================================================"
echo "Setup Complete!"
echo "================================================"
echo ""
echo "Next steps:"
echo "1. Source the environment: source setup_env.sh"
echo "2. Check quick reference: bash help.sh"
echo "3. Run smoke test: bash quick_test.sh"
echo ""
echo "For detailed information, see:"
echo "  - README.md for quick start"
echo "  - GUIDE.md for comprehensive guide"
echo "  - PROJECT_SUMMARY.txt for project overview"
echo ""
