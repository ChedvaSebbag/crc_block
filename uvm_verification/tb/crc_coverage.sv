// =====================================================
// crc_coverage.sv  (Functional Coverage for crc_tb_top)
// =====================================================

`ifndef CRC_COVERAGE_SV
`define CRC_COVERAGE_SV

// This module is meant to be instantiated inside crc_tb_top
module crc_coverage (
  input  logic        clk,
  input  logic        rst_n,

  input  logic        data_valid,
  input  logic [31:0] data_in,
  input  logic [1:0]  crc_select,
  input  logic [31:0] crc_init,

  input  logic [31:0] crc_out,
  input  logic        crc_valid,
  input  logic        busy
);

  int unsigned txn_count = 0;
  logic [31:0] prev_crc_out;
  bit has_prev_crc = 0;

  function automatic bit is_continuous_now();
    return (has_prev_crc && (crc_init === prev_crc_out));
  endfunction

  // 1) CRC type coverage - sample on data_valid
  covergroup cg_crc_type @(posedge clk);
    option.per_instance = 1;
    cp_type : coverpoint crc_select iff (data_valid) {
      bins crc3  = {2'b00};
      bins crc8  = {2'b01};
      bins crc16 = {2'b10};
      bins crc32 = {2'b11};
    }
  endgroup

  // 2) Reset coverage
  covergroup cg_reset @(posedge rst_n or negedge rst_n);
    option.per_instance = 1;
    cp_rst : coverpoint rst_n {
      bins asserted   = {1'b0};
      bins deasserted = {1'b1};
    }
  endgroup

  // 3) Flow + continuous mode - sample on crc_valid
  covergroup cg_flow @(posedge clk);
    option.per_instance = 1;

    cp_multi : coverpoint txn_count iff (crc_valid) {
      bins first = {1};
      bins multi = {[2:1000]};
    }

    cp_cont : coverpoint is_continuous_now() iff (crc_valid) {
      bins single_mode = {0};
      bins continuous  = {1};
    }

    cx_type_cont : cross crc_select, cp_cont iff (crc_valid);
  endgroup

  // 4) Control signals coverage
  covergroup cg_ctrl @(posedge clk);
    option.per_instance = 1;

    cp_busy : coverpoint busy {
      bins idle = {0};
      bins work = {1};
    }

    cp_crc_valid : coverpoint crc_valid {
      bins low  = {0};
      bins high = {1};
    }

    cx_busy_valid : cross cp_busy, cp_crc_valid;
  endgroup

  cg_crc_type cov_type = new();
  cg_reset    cov_rst  = new();
  cg_flow     cov_flow = new();
  cg_ctrl     cov_ctrl = new();

  // bookkeeping
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      txn_count    <= 0;
      prev_crc_out <= '0;
      has_prev_crc <= 0;
    end else begin
      if (crc_valid) begin
        txn_count    <= txn_count + 1;
        prev_crc_out <= crc_out;
        has_prev_crc <= 1;
      end
    end
  end

  // summary at end
  final begin
    $display("\n==== FUNCTIONAL COVERAGE SUMMARY ====");
    $display("cg_crc_type = %0.2f%%", cov_type.get_coverage());
    $display("cg_reset    = %0.2f%%", cov_rst.get_coverage());
    $display("cg_flow     = %0.2f%%", cov_flow.get_coverage());
    $display("cg_ctrl     = %0.2f%%", cov_ctrl.get_coverage());
    $display("TOTAL (design-wide) = %0.2f%%", $get_coverage());
  end

endmodule

`endif
