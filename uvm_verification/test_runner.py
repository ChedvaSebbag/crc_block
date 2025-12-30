#!/usr/bin/env python3
# CRC Verification Test Runner
# =====================================================
# תיאור: Python script להרצה וניהול tests

import os
import sys
import subprocess
import argparse
import json
from datetime import datetime
from pathlib import Path

class CRCTestRunner:
    """Main test runner for CRC verification environment"""
    
    def __init__(self, root_dir=None):
        self.root_dir = root_dir or os.getcwd()
        self.work_dir = os.path.join(self.root_dir, "crc_work")
        self.src_dir = os.path.join(self.root_dir, "src")
        self.tb_dir = os.path.join(self.root_dir, "tb")
        self.sim_dir = os.path.join(self.root_dir, "sim")
        self.report_dir = os.path.join(self.root_dir, "reports")
        self.timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        # Create necessary directories
        os.makedirs(self.work_dir, exist_ok=True)
        os.makedirs(self.report_dir, exist_ok=True)
    
    def compile(self, simulator="modelsim"):
        """Compile Verilog sources"""
        print("=" * 60)
        print("Compiling CRC Verification Sources...")
        print("=" * 60)
        
        if simulator == "modelsim":
            return self._compile_modelsim()
        elif simulator == "xsim":
            return self._compile_xsim()
        else:
            print(f"ERROR: Unknown simulator: {simulator}")
            return False
    
    def _compile_modelsim(self):
        """Compile using ModelSim"""
        try:
            # Create library
            cmd = ["vlib", self.work_dir]
            print(f"Running: {' '.join(cmd)}")
            subprocess.run(cmd, check=True)
            
            # Map library
            cmd = ["vmap", "work", self.work_dir]
            print(f"Running: {' '.join(cmd)}")
            subprocess.run(cmd, check=True)
            
            # Compile Verilog
            tb_files = [
                os.path.join(self.tb_dir, "crc_dut.sv"),
                os.path.join(self.tb_dir, "crc_tb_top.sv")
            ]
            
            cmd = [
                "vlog",
                "-work", self.work_dir,
                f"+incdir+{self.src_dir}",
                "+define+SIM"
            ] + tb_files
            
            print(f"Running: vlog with {len(tb_files)} files")
            subprocess.run(cmd, check=True)
            
            print("Compilation successful!")
            return True
            
        except subprocess.CalledProcessError as e:
            print(f"ERROR: Compilation failed with code {e.returncode}")
            return False
    
    def _compile_xsim(self):
        """Compile using Xilinx Vivado Simulator"""
        try:
            tb_files = [
                os.path.join(self.tb_dir, "crc_dut.sv"),
                os.path.join(self.tb_dir, "crc_tb_top.sv")
            ]
            
            cmd = [
                "xvlog",
                f"--work={self.work_dir}",
                f"--include={self.src_dir}",
            ] + tb_files
            
            print(f"Running: xvlog with {len(tb_files)} files")
            subprocess.run(cmd, check=True)
            
            print("Compilation successful!")
            return True
            
        except subprocess.CalledProcessError as e:
            print(f"ERROR: Compilation failed with code {e.returncode}")
            return False
    
    def simulate(self, testname="crc_smoke_test", simulator="modelsim", batch=False):
        """Run simulation"""
        print("=" * 60)
        print(f"Running Simulation: {testname}")
        print("=" * 60)
        
        try:
            if simulator == "modelsim":
                return self._simulate_modelsim(testname, batch)
            elif simulator == "xsim":
                return self._simulate_xsim(testname, batch)
            else:
                print(f"ERROR: Unknown simulator: {simulator}")
                return False
                
        except subprocess.CalledProcessError as e:
            print(f"ERROR: Simulation failed with code {e.returncode}")
            return False
    
    def _simulate_modelsim(self, testname, batch=False):
        """Run simulation using ModelSim"""
        cmd = ["vsim"]
        
        if batch:
            cmd.append("-batch")
        
        cmd.extend([
            "-work", self.work_dir,
            "-voptargs=+acc",
            f"+UVM_TESTNAME={testname}",
            "crc_tb_top"
        ])
        
        if batch:
            cmd.extend(["-do", "run -all; quit"])
        
        print(f"Running: {' '.join(cmd)}")
        result = subprocess.run(cmd, cwd=self.root_dir)
        
        return result.returncode == 0
    
    def _simulate_xsim(self, testname, batch=False):
        """Run simulation using Xilinx Vivado Simulator"""
        # Note: This is a placeholder - actual implementation depends on project setup
        print("WARNING: XSIM simulation not fully implemented")
        return False
    
    def run_all_tests(self, simulator="modelsim"):
        """Run all test cases"""
        test_names = [
            "crc_smoke_test",
            "crc_directed_test",
            "crc_edge_case_test",
            "crc_selection_test"
        ]
        
        results = {}
        
        for testname in test_names:
            print(f"\n{'=' * 60}")
            print(f"Running: {testname}")
            print(f"{'=' * 60}")
            
            success = self.simulate(testname, simulator, batch=True)
            results[testname] = "PASSED" if success else "FAILED"
        
        self._print_summary(results)
        return all(v == "PASSED" for v in results.values())
    
    def _print_summary(self, results):
        """Print test summary"""
        print("\n" + "=" * 60)
        print("Test Summary")
        print("=" * 60)
        
        for testname, status in results.items():
            status_symbol = "✓" if status == "PASSED" else "✗"
            print(f"{status_symbol} {testname}: {status}")
        
        total = len(results)
        passed = sum(1 for v in results.values() if v == "PASSED")
        print(f"\nTotal: {passed}/{total} tests passed")
        print("=" * 60)
    
    def clean(self):
        """Clean generated files"""
        print("Cleaning up...")
        
        files_to_remove = [
            self.work_dir,
            "crc_tb.vcd",
            "*.log",
            "*.db"
        ]
        
        for pattern in files_to_remove:
            if "*" in pattern:
                # Handle wildcards
                import glob
                for file in glob.glob(os.path.join(self.root_dir, pattern)):
                    try:
                        os.remove(file)
                        print(f"Removed: {file}")
                    except Exception as e:
                        print(f"Error removing {file}: {e}")
            else:
                path = os.path.join(self.root_dir, pattern)
                if os.path.exists(path):
                    try:
                        if os.path.isdir(path):
                            import shutil
                            shutil.rmtree(path)
                        else:
                            os.remove(path)
                        print(f"Removed: {path}")
                    except Exception as e:
                        print(f"Error removing {path}: {e}")
        
        print("Cleanup completed")

def main():
    parser = argparse.ArgumentParser(
        description="CRC Verification Test Runner",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python3 test_runner.py --compile
  python3 test_runner.py --simulate crc_smoke_test
  python3 test_runner.py --run-all
  python3 test_runner.py --clean
        """
    )
    
    parser.add_argument("--compile", action="store_true",
                        help="Compile sources")
    parser.add_argument("--simulate", metavar="TESTNAME",
                        help="Run specific test")
    parser.add_argument("--run-all", action="store_true",
                        help="Run all tests")
    parser.add_argument("--clean", action="store_true",
                        help="Clean generated files")
    parser.add_argument("--simulator", default="modelsim",
                        choices=["modelsim", "xsim"],
                        help="Simulator to use (default: modelsim)")
    parser.add_argument("--batch", action="store_true",
                        help="Run in batch mode")
    parser.add_argument("--root-dir", default=None,
                        help="Root directory of project")
    
    args = parser.parse_args()
    
    # Create runner instance
    runner = CRCTestRunner(args.root_dir)
    
    # Perform requested action
    if args.compile:
        success = runner.compile(args.simulator)
        sys.exit(0 if success else 1)
    
    elif args.simulate:
        success = runner.compile(args.simulator)
        if not success:
            print("ERROR: Compilation failed")
            sys.exit(1)
        
        success = runner.simulate(args.simulate, args.simulator, args.batch)
        sys.exit(0 if success else 1)
    
    elif args.run_all:
        success = runner.compile(args.simulator)
        if not success:
            print("ERROR: Compilation failed")
            sys.exit(1)
        
        success = runner.run_all_tests(args.simulator)
        sys.exit(0 if success else 1)
    
    elif args.clean:
        runner.clean()
        sys.exit(0)
    
    else:
        parser.print_help()
        sys.exit(0)

if __name__ == "__main__":
    main()
