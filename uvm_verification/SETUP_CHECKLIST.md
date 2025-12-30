<!-- CRC Verification Environment - Installation Checklist -->

# CRC Verification Environment - Installation & Setup Checklist

## Pre-Installation Requirements ✓

- [ ] SystemVerilog Simulator installed (ModelSim/QuestaSim/XSIM)
- [ ] UVM 1.2+ library available
- [ ] Perl 5.8+ installed
- [ ] Bash or CSH shell available
- [ ] Python 3.6+ installed (optional, for test runner)
- [ ] Git installed (optional, for version control)

## Environment Setup ✓

```bash
# 1. Navigate to project directory
cd /Users/chedvasebbag/Downloads/crc/uvm_verification

# 2. Run setup script
bash setup.sh

# 3. Source environment
source setup_env.sh

# 4. Verify setup
make help
```

## File Structure Verification ✓

```
✓ src/crc_pkg.sv            - Package declaration
✓ src/crc_defines.sv        - Parameters
✓ src/crc_if.sv             - Interface
✓ src/crc_transaction.sv    - Transaction class
✓ src/crc_driver.sv         - Driver
✓ src/crc_sequencer.sv      - Sequencer
✓ src/crc_monitor.sv        - Monitor
✓ src/crc_agent.sv          - Agent
✓ src/crc_predictor.sv      - Predictor
✓ src/crc_scoreboard.sv     - Scoreboard
✓ src/crc_env.sv            - Environment
✓ src/crc_seq_lib.sv        - Sequences
✓ src/crc_test.sv           - Tests
✓ tb/crc_tb_top.sv          - Testbench
✓ tb/crc_dut.sv             - DUT
✓ Makefile                  - Build system
✓ test_runner.py            - Test runner
✓ README.md                 - Quick start
✓ GUIDE.md                  - Full guide
✓ PROJECT_SUMMARY.txt       - Project info
✓ setup.sh                  - Setup script
✓ config.mk                 - Configuration
```

## Compilation Verification ✓

```bash
# Test compilation
make compile

# Expected output:
# ✓ Library creation
# ✓ Verilog compilation
# ✓ No compilation errors
```

## Smoke Test Verification ✓

```bash
# Run minimal test
make sim_batch TESTNAME=crc_smoke_test

# Expected results:
# ✓ Test starts
# ✓ 20 transactions generated
# ✓ Transactions collected
# ✓ Test completes
# ✓ No errors reported
```

## Full Test Suite ✓

```bash
# Run all tests
make test_all

# Expected results:
# ✓ crc_smoke_test PASSED
# ✓ crc_directed_test PASSED
# ✓ crc_edge_case_test PASSED
```

## Python Test Runner Verification ✓

```bash
# Test Python runner
python3 test_runner.py --help

# Expected output:
# ✓ Help message displayed
# ✓ All options listed
```

## Optional Enhancements ✓

### Waveform Viewing
```bash
# Enable waveform dump
make sim_batch TESTNAME=crc_smoke_test +dump_waves

# View waveforms
gtkwave crc_tb.vcd &
```

### Coverage Analysis
```bash
# Enable coverage (if simulator supports)
# Edit Makefile to add +cover option
```

### Batch Testing
```bash
# Run multiple tests in sequence
python3 test_runner.py --run-all --batch
```

## Configuration Options ✓

Edit `config.mk` to customize:
- [ ] Simulator type (modelsim/xsim)
- [ ] Verbosity level
- [ ] Timeout values
- [ ] Coverage options
- [ ] Debug options

## Quick Commands Reference ✓

```
│ Command                              │ Purpose                           │
├──────────────────────────────────────┼──────────────────────────────────┤
│ make help                            │ Show all available targets        │
│ make compile                         │ Compile sources only             │
│ make simulate                        │ Run interactive GUI              │
│ make sim_batch                       │ Run in batch mode                │
│ make test_all                        │ Run all tests                    │
│ make clean                           │ Remove generated files           │
├──────────────────────────────────────┼──────────────────────────────────┤
│ python3 test_runner.py --compile     │ Compile via Python               │
│ python3 test_runner.py --simulate X  │ Run test X via Python            │
│ python3 test_runner.py --run-all     │ Run all via Python               │
├──────────────────────────────────────┼──────────────────────────────────┤
│ bash quick_test.sh                   │ Quick smoke test                 │
│ bash help.sh                         │ Show quick reference             │
│ bash setup.sh                        │ Run initial setup                │
```

## Troubleshooting ✓

### Issue: "vlog: command not found"
**Solution:**
```bash
# Add simulator to PATH
export PATH=$PATH:/opt/modelsim/bin
# Or create alias
alias vlog="/opt/modelsim/bin/vlog"
```

### Issue: "UVM not found"
**Solution:**
```bash
# Set UVM path
source /opt/modelsim/uvm/uvm-1.2/install/install.sh
```

### Issue: Compilation errors
**Solution:**
```bash
make clean
make compile -j 4  # Try parallel compilation
```

### Issue: Timeout during simulation
**Solution:**
1. Increase timeout in `crc_tb_top.sv` line 77
2. Reduce number of transactions in test

## Performance Expectations ✓

| Metric | Value | Notes |
|--------|-------|-------|
| Compile Time | ~5-10s | First time only |
| Smoke Test | ~1-2s | 20 transactions |
| Full Suite | ~5-10s | All three tests |
| Setup Time | ~30s | One-time only |

## Verification Metrics ✓

After successful setup, you should have:
- ✓ 976 lines of SystemVerilog code
- ✓ 15 UVM components
- ✓ 3 complete test cases
- ✓ 1 comprehensive testbench
- ✓ 1 CRC reference model (DUT)
- ✓ Full documentation

## Post-Installation Steps ✓

1. **Learn the structure:**
   - Read README.md
   - Review GUIDE.md
   - Study PROJECT_SUMMARY.txt

2. **Run basic tests:**
   - `bash quick_test.sh`
   - `make test_all`

3. **Explore components:**
   - Open `src/crc_agent.sv`
   - Study the UVM hierarchy
   - Review the testbench

4. **Create custom tests:**
   - Add new sequences in `crc_seq_lib.sv`
   - Add new tests in `crc_test.sv`
   - Run custom tests

5. **Extend functionality:**
   - Modify DUT in `tb/crc_dut.sv`
   - Update interface in `src/crc_if.sv`
   - Add new properties to transaction

## Success Criteria ✓

You have successfully set up the environment when:

- ✓ All 22 files are present
- ✓ `make compile` completes without errors
- ✓ `make test_all` shows 3 tests PASSED
- ✓ `python3 test_runner.py --help` works
- ✓ Documentation is readable and clear

## Support Resources ✓

1. **Internal Documentation:**
   - README.md - Quick reference
   - GUIDE.md - Detailed instructions
   - PROJECT_SUMMARY.txt - Project overview

2. **External Resources:**
   - UVM 1.2 Reference Manual
   - SystemVerilog IEEE 1800-2017
   - CRC Algorithm documentation

3. **Common Issues:**
   - See Troubleshooting section above
   - Check Makefile comments
   - Review code comments in .sv files

## Customization Guide ✓

### Add New Test
```bash
# 1. Add sequence to crc_seq_lib.sv
class my_seq extends crc_base_seq;
    task body();
        // your code
    endtask
endclass

# 2. Add test to crc_test.sv
class my_test extends crc_test;
    task run_phase(uvm_run_phase phase);
        my_seq seq = my_seq::type_id::create("seq");
        seq.start(env.agent.sequencer);
    endtask
endclass

# 3. Run test
make sim_batch TESTNAME=my_test
```

### Modify DUT
```bash
# Edit tb/crc_dut.sv
# Recompile
make clean
make compile
```

### Change Interface
```bash
# Edit src/crc_if.sv
# Recompile all
make clean
make compile
```

## Sign-Off Checklist ✓

- [ ] All files present and accessible
- [ ] Compilation successful
- [ ] Smoke test passes
- [ ] Full test suite passes
- [ ] Documentation read and understood
- [ ] Environment variables configured
- [ ] Quick start commands working
- [ ] Python test runner operational
- [ ] Makefiles functional

---

## Final Notes

This checklist ensures a complete and functional CRC Verification Environment.

**Status:** ✓ COMPLETE AND READY FOR USE
**Version:** 1.0
**Date:** 28 December 2024

---

For detailed information, refer to:
- GUIDE.md for comprehensive instructions
- PROJECT_SUMMARY.txt for project structure
- Code comments in .sv files for implementation details
