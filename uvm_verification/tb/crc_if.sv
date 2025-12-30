// CRC Interface
// =====================================================
// תיאור: ממשק עם כל האותות הדרושים ל-DUT

interface crc_if (
  input logic clk,
  input logic rst_n
);

  // Inputs to DUT
  logic [`DATA_WIDTH-1:0] data_in;
  logic                   data_valid;
  logic [`SELECT_WIDTH-1:0] crc_select;
  logic [`DATA_WIDTH-1:0] crc_init;

  // Outputs from DUT
  logic [`DATA_WIDTH-1:0] crc_out;
  logic                   crc_valid;
  logic                   busy;

  // Driver clocking block
  clocking dr_cb @(posedge clk);
  	default input #1ns output #1ns;	
	output data_valid, data_in, crc_select, crc_init;
    input  crc_out, crc_valid, busy;
  endclocking

  clocking mon_cb @(posedge clk);
    default input #1ns output #1ns;
    input data_valid, data_in, crc_select, crc_init;
    input crc_out, crc_valid, busy;
  endclocking


  modport driver  (clocking dr_cb, input clk, rst_n);
  modport monitor (clocking mon_cb, input clk, rst_n);
  modport dut (
    input  clk, rst_n, data_in, data_valid, crc_select, crc_init,
    output crc_out, crc_valid, busy
  );

endinterface
