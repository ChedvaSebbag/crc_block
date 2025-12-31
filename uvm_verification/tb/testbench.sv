`timescale 1ns/1ps

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "crc_defines.sv"
`include "crc_if.sv"

`include "crc_pkg.sv"  
import crc_pkg::*;


module crc_uvm_top;

  logic clk;
  logic rst_n;

  initial begin clk = 0; forever #5 clk = ~clk; end
  initial begin rst_n = 0; #25 rst_n = 1; end
  
  initial begin
  $dumpfile("dump.vcd");
  $dumpvars(0, crc_uvm_top);
  $dumpvars(0, dut);
  $dumpvars(0, cif);
  end


  crc_if cif(.clk(clk), .rst_n(rst_n));

  // DUT
  crc_block dut (
    .clk        (clk),
    .rst_n      (rst_n),
    .data_in    (cif.data_in),
    .data_valid (cif.data_valid),
    .crc_select (cif.crc_select),
    .crc_init   (cif.crc_init),
    .crc_out    (cif.crc_out),
    .crc_valid  (cif.crc_valid),
    .busy       (cif.busy)
  );


  initial begin
    uvm_config_db#(virtual crc_if)::set(null, "*", "vif", cif);
    run_test("crc_basic_functionality_test");
  end

endmodule
