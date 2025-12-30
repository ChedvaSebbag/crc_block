`timescale 1ns/1ps
`include "crc_coverage.sv"


module crc_tb_top;

  // DUT signals
  logic        clk;
  logic        rst_n;
  logic        data_valid;
  logic [31:0] data_in;
  logic [1:0]  crc_select;
  logic [31:0] crc_init;

  logic [31:0] crc_out;
  logic        crc_valid;
  logic        busy;

  // DUT instantiation
  crc_block dut (
    .clk        (clk),
    .rst_n      (rst_n),
    .data_in    (data_in),
    .data_valid (data_valid),
    .crc_select (crc_select),
    .crc_init   (crc_init),
    .crc_out    (crc_out),
    .crc_valid  (crc_valid),
    .busy       (busy)
  );
  
  //coverage instantiation
  crc_coverage cov (
  .clk(clk),
  .rst_n(rst_n),
  .data_valid(data_valid),
  .data_in(data_in),
  .crc_select(crc_select),
  .crc_init(crc_init),
  .crc_out(crc_out),
  .crc_valid(crc_valid),
  .busy(busy)
);

  // Clock generation (10ns period)
  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end

  // Wave dump (optional)
  initial begin
    $dumpfile("crc_tb.vcd");
    $dumpvars(0, crc_tb_top);
  end

  // -----------------------------
  // Reference model
  // -----------------------------
  function automatic [31:0] sel_poly(input [1:0] s);
    begin
      case (s)
        2'b00: sel_poly = 32'h00000003;
        2'b01: sel_poly = 32'h00000107;
        2'b10: sel_poly = 32'h00018005;
        default: sel_poly = 32'h04C11DB7;
      endcase
    end
  endfunction

  function automatic [31:0] tb_crc_next(
      input [31:0] current,
      input [31:0] din,
      input [31:0] p
  );
    integer i;
    reg [31:0] tmp;
    begin
      tmp = current;
      for (i = 31; i >= 0; i = i - 1) begin
        if ((tmp[31] ^ din[i]) == 1'b1)
          tmp = (tmp << 1) ^ p;
        else
          tmp = (tmp << 1);
      end
      tb_crc_next = tmp;
    end
  endfunction

  function automatic [31:0] mask_crc(input [31:0] v, input [1:0] s);
    begin
      case (s)
        2'b00: mask_crc = {29'b0, v[2:0]};
        2'b01: mask_crc = {24'b0, v[7:0]};
        2'b10: mask_crc = {16'b0, v[15:0]};
        default: mask_crc = v;
      endcase
    end
  endfunction

  // -----------------------------
  // Core transaction + checks
  // IMPORTANT: data_valid asserted BEFORE posedge
  // -----------------------------
  task automatic run_and_check(
      input [1:0]  sel,
      input [31:0] init_val,
      input [31:0] din,
      input string name,
      output logic [31:0] captured_crc
  );
    logic [31:0] expected_full;
    logic [31:0] expected_masked;
    begin
      expected_full   = tb_crc_next(init_val, din, sel_poly(sel));
      expected_masked = mask_crc(expected_full, sel);

      // Drive inputs stable BEFORE sampling edge
      crc_select = sel;
      crc_init   = init_val;
      data_in    = din;

      // Assert valid BEFORE posedge so DUT samples it
      data_valid = 1'b1;
      @(posedge clk);
      #1ps;

      // Processing cycle checks
      if (busy !== 1'b1)
        $error("%s: BUSY should be 1 during processing cycle", name);

      if (crc_valid !== 1'b0)
        $error("%s: crc_valid should be 0 during processing cycle (result next cycle)", name);

      // Deassert valid
      data_valid = 1'b0;

      // Next cycle: result should be ready
      @(posedge clk);
      #1ps;

      if (crc_valid !== 1'b1)
        $error("%s: crc_valid should be 1 when result becomes available", name);

      if (busy !== 1'b0)
        $error("%s: BUSY should be 0 when crc_valid is asserted (done)", name);

      $display("---- %s ----", name);
      $display("sel=%b init=%h data=%h", sel, init_val, din);
      $display("EXPECTED=%h | ACTUAL=%h", expected_masked, crc_out);

      if (crc_out !== expected_masked)
        $error("%s: FAIL mismatch! Expected=%h Actual=%h", name, expected_masked, crc_out);
      else
        $display("PASS\n");

      captured_crc = crc_out;

      // Ensure crc_valid is a 1-cycle pulse
      @(posedge clk);
      #1ps;
      if (crc_valid !== 1'b0)
        $error("%s: crc_valid should be a one-cycle pulse", name);
    end
  endtask

  // -----------------------------
  // Tests
  // -----------------------------
  task automatic reset_test;
    begin
      $display("==== Reset Test ====");
      rst_n      = 1'b0;
      data_valid = 1'b0;
      data_in    = 32'b0;
      crc_select = 2'b00;
      crc_init   = 32'b0;

      #12;
      if (crc_valid !== 1'b0) $error("Reset: crc_valid should be 0");
      if (busy      !== 1'b0) $error("Reset: busy should be 0");

      rst_n = 1'b1;
      @(posedge clk);
      $display("Reset Test DONE\n");
    end
  endtask

  task automatic single_crc_calculation_test;
    logic [31:0] cap;
    begin
      $display("==== Single CRC Calculation Test ====");
      run_and_check(2'b11, 32'hFFFFFFFF, 32'h12345678, "Single CRC-32 calc", cap);
      $display("Single CRC Calculation Test DONE\n");
    end
  endtask

  task automatic crc_selection_test;
    logic [31:0] cap;
    begin
      $display("==== CRC Selection Test ====");
      run_and_check(2'b00, 32'h00000000, 32'hA5A5A5A5, "CRC-3 basic",  cap);
      run_and_check(2'b01, 32'h00000000, 32'h12345678, "CRC-8 basic",  cap);
      run_and_check(2'b10, 32'h00000000, 32'hDEADBEEF, "CRC-16 basic", cap);
      run_and_check(2'b11, 32'hFFFFFFFF, 32'h12345678, "CRC-32 basic", cap);
      $display("CRC Selection Test DONE\n");
    end
  endtask

  task automatic continuous_mode_test;
    logic [31:0] cap1, cap2;
    begin
      $display("==== Continuous Mode Test ====");
      run_and_check(2'b11, 32'hFFFFFFFF, 32'h11111111, "Continuous step 1", cap1);
      run_and_check(2'b11, cap1,         32'h22222222, "Continuous step 2", cap2);
      $display("Continuous Mode Test DONE\n");
    end
  endtask

  task automatic busy_handling_test;
    logic [1:0]  sel;
    logic [31:0] init1, init2;
    logic [31:0] din1, din2;
    logic [31:0] exp1, exp2;
    logic [31:0] cap;

    begin
      $display("==== Busy Handling Test ====");

      sel   = 2'b01;
      init1 = 32'h0;
      din1  = 32'h0000ABCD;

      init2 = 32'h0;
      din2  = 32'h00001234;

      exp1 = mask_crc(tb_crc_next(init1, din1, sel_poly(sel)), sel);
      exp2 = mask_crc(tb_crc_next(init2, din2, sel_poly(sel)), sel);

      // Prepare and accept txn1
      crc_select = sel;
      crc_init   = init1;
      data_in    = din1;

      data_valid = 1'b1;      // valid BEFORE posedge
      @(posedge clk);
      #1ps;

      if (busy !== 1'b1) $error("BusyHandling: busy should be 1 during processing");

      // While busy=1 (processing cycle), attempt to change inputs + keep valid high
      crc_init   = init2;
      data_in    = din2;
      data_valid = 1'b1;      // attempt second accept during busy (should be ignored)

      // Move to result cycle for txn1
      @(posedge clk);
      #1ps;
      data_valid = 1'b0;

      if (crc_valid !== 1'b1) $error("BusyHandling: expected crc_valid for txn1");
      cap = crc_out;

      $display("BusyHandling txn1: EXPECT=%h ACT=%h", exp1, cap);
      if (cap !== exp1) $error("BusyHandling: txn1 mismatch");

      // Ensure pulse ends
      @(posedge clk);
      #1ps;
      if (crc_valid !== 1'b0) $error("BusyHandling: crc_valid should be 1-cycle");

      // Now send txn2 properly when idle
      run_and_check(sel, init2, din2, "BusyHandling txn2 (accepted when idle)", cap);
      if (cap !== exp2) $error("BusyHandling: txn2 mismatch");

      $display("Busy Handling Test DONE\n");
    end
  endtask

  task automatic multi_seq_test;
    integer k;
    logic [31:0] cap;
    logic [31:0] init_v;
    logic [31:0] din_v;
    begin
      $display("==== Multiple Sequential Operations Test ====");
      for (k = 0; k < 5; k = k + 1) begin
        init_v = 32'h00000000 + k;
        din_v  = 32'hABCDEF00 + k;
        run_and_check(2'b01, init_v, din_v, $sformatf("Seq CRC-8 #%0d", k), cap);
      end
      $display("Multiple Sequential Operations Test DONE\n");
    end
  endtask

  // -----------------------------
  // Main
  // -----------------------------
  initial begin
    rst_n      = 1'b0;
    data_valid = 1'b0;
    data_in    = 32'b0;
    crc_select = 2'b00;
    crc_init   = 32'b0;

    reset_test();
    single_crc_calculation_test();
    crc_selection_test();
    continuous_mode_test();
    busy_handling_test();
    multi_seq_test();

    $display("ALL TESTS DONE.");
    #20 $finish;
  end

endmodule
