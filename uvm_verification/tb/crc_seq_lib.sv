`ifndef CRC_SEQ_LIB_SV
`define CRC_SEQ_LIB_SV

// =====================================================
// Base sequence
// =====================================================
class crc_base_seq extends uvm_sequence #(crc_transaction);
  `uvm_object_utils(crc_base_seq)

  function new(string name="crc_base_seq");
    super.new(name);
  endfunction
endclass


// =====================================================
// Reset toggle sequence  → RESET = 100%
// =====================================================
class crc_reset_toggle_seq extends crc_base_seq;
  `uvm_object_utils(crc_reset_toggle_seq)

  function new(string name="crc_reset_toggle_seq");
    super.new(name);
  endfunction

  task body();
    repeat (12) begin
      `uvm_create(req)
      assert(req.randomize());
      req.data_valid = 0;
      `uvm_send(req)

      `uvm_create(req)
      assert(req.randomize());
      req.data_valid = 1;
      `uvm_send(req)
    end
  endtask
endclass


// =====================================================
// Random sequence  → מחזק Flow + Ctrl
// =====================================================
class crc_random_seq extends crc_base_seq;
  `uvm_object_utils(crc_random_seq)

  int num_transactions = 80;

  function new(string name="crc_random_seq");
    super.new(name);
  endfunction

  task body();
    for (int i = 0; i < num_transactions; i++) begin
      `uvm_create(req)
      assert(req.randomize());

      // forcing idle occasionally
      if ((i % 5) == 0)
        req.data_valid = 0;
      else
        req.data_valid = 1;

      `uvm_send(req)
    end
  endtask
endclass


// =====================================================
// Directed sequence  → FLOW = 100% (FIXED)
// =====================================================
class crc_directed_seq extends crc_base_seq;
  `uvm_object_utils(crc_directed_seq)

  function new(string name="crc_directed_seq");
    super.new(name);
  endfunction

  task body();
    logic [31:0] fixed_init   = 32'h12345678;
    logic [31:0] single_init  = 32'hA5A5A5A5; // ✅ unique init כדי להבטיח single_mode=0

    // -----------------------------
    // SINGLE operation  (single_op + single_mode)
    // -----------------------------
    `uvm_create(req)
    assert(req.randomize());
    req.data_valid = 1;
    req.crc_init   = single_init;  // ✅ שונה מה-fixed_init
    `uvm_send(req)

    // close burst
    `uvm_create(req)
    assert(req.randomize());
    req.data_valid = 0;
    `uvm_send(req)

    // -----------------------------
    // MULTI + CONTINUOUS burst (multi_op + continuous)
    // -----------------------------
    repeat (4) begin
      `uvm_create(req)
      assert(req.randomize());
      req.data_valid = 1;
      req.crc_init   = fixed_init; // same init → continuous
      `uvm_send(req)
    end

    // explicit burst close
    `uvm_create(req)
    assert(req.randomize());
    req.data_valid = 0;
    `uvm_send(req)
  endtask
endclass


// =====================================================
// Edge case sequence  → DATA patterns + Flow close
// =====================================================
class crc_edge_case_seq extends crc_base_seq;
  `uvm_object_utils(crc_edge_case_seq)

  function new(string name="crc_edge_case_seq");
    super.new(name);
  endfunction

  task body();
    logic [31:0] patterns[4] = '{32'h0, 32'hFFFFFFFF, 32'hAAAAAAAA, 32'h55555555};

    foreach (patterns[i]) begin
      `uvm_create(req)
      assert(req.randomize());
      req.data_valid = 1;
      req.data_in    = patterns[i];
      `uvm_send(req)
    end

    // close burst
    `uvm_create(req)
    assert(req.randomize());
    req.data_valid = 0;
    `uvm_send(req)
  endtask
endclass

`endif
