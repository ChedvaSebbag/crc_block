// =====================================================
// CRC Sequence Library
// =====================================================

class crc_base_seq extends uvm_sequence #(crc_transaction);

  `uvm_object_utils(crc_base_seq)

  function new(string name="crc_base_seq");
    super.new(name);
  endfunction

  task body();
    `uvm_info("BASE_SEQ", "Base sequence started", UVM_LOW)
  endtask

endclass


// =====================================================
// Random Sequence
// =====================================================
class crc_random_seq extends crc_base_seq;

  rand int num_transactions;

  constraint c_num { num_transactions inside {[10:50]}; }

  `uvm_object_utils(crc_random_seq)

  function new(string name="crc_random_seq");
    super.new(name);
    num_transactions = 20; // default
  endfunction

  task body();
    int i;

    `uvm_info("RANDOM_SEQ",
              $sformatf("Starting random sequence: %0d transactions", num_transactions),
              UVM_MEDIUM)

    for (i = 0; i < num_transactions; i++) begin
      `uvm_create(req)
      assert(req.randomize());
      req.data_valid = 1'b1;
      `uvm_send(req)
    end
  endtask

endclass


// =====================================================
// Directed Sequence
// =====================================================
class crc_directed_seq extends crc_base_seq;

  `uvm_object_utils(crc_directed_seq)

  function new(string name="crc_directed_seq");
    super.new(name);
  endfunction

  task body();
    int s;

    `uvm_info("DIRECTED_SEQ", "Starting directed sequence", UVM_MEDIUM)

    // Same data, iterate over all CRC types
    for (s = 0; s < 4; s++) begin
      repeat (5) begin
        `uvm_create(req)
        req.data_in    = 32'hDEADBEEF;
        req.crc_init   = 32'h00000000;
        req.crc_select = s[1:0];
        req.data_valid = 1'b1;
        `uvm_send(req)
      end
    end
  endtask

endclass


// =====================================================
// Edge Case Sequence
// =====================================================
class crc_edge_case_seq extends crc_base_seq;

  `uvm_object_utils(crc_edge_case_seq)

  function new(string name="crc_edge_case_seq");
    super.new(name);
  endfunction

  task body();
    int s, p;
    logic [31:0] patterns [0:3];

    // Edge patterns
    patterns[0] = 32'h00000000;
    patterns[1] = 32'hFFFFFFFF;
    patterns[2] = 32'hAAAAAAAA;
    patterns[3] = 32'h55555555;

    `uvm_info("EDGE_SEQ", "Starting edge case sequence", UVM_MEDIUM)

    for (s = 0; s < 4; s++) begin
      for (p = 0; p < 4; p++) begin
        `uvm_create(req)
        req.data_in    = patterns[p];
        req.crc_init   = 32'h00000000;
        req.crc_select = s[1:0];
        req.data_valid = 1'b1;
        `uvm_send(req)
      end
    end
  endtask

endclass
