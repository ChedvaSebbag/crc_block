class crc_scoreboard extends uvm_scoreboard;

  // Use analysis_imp_decl to allow two separate write methods
  `uvm_analysis_imp_decl(_actual)
  `uvm_analysis_imp_decl(_predicted)

  uvm_analysis_imp_actual    #(crc_transaction, crc_scoreboard) actual_imp;
  uvm_analysis_imp_predicted #(crc_transaction, crc_scoreboard) predicted_imp;

  crc_transaction exp_q[$];

  int match_count = 0;
  int mismatch_count = 0;

  `uvm_component_utils(crc_scoreboard)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    actual_imp    = new("actual_imp", this);
    predicted_imp = new("predicted_imp", this);
  endfunction

  // called by predictor
  function void write_predicted(crc_transaction txn);
    exp_q.push_back(txn);
    `uvm_info("SB_EXP",
              $sformatf("Enqueue EXP: out=0x%08h sel=%0d din=0x%08h init=0x%08h",
                        txn.crc_out, txn.crc_select, txn.data_in, txn.crc_init),
              UVM_MEDIUM)
  endfunction

  // called by monitor
  function void write_actual(crc_transaction txn);
    crc_transaction exp_txn;

    if (exp_q.size() == 0) begin
      mismatch_count++;
      `uvm_error("SB", "Got ACTUAL but no expected in queue")
      return;
    end

    exp_txn = exp_q.pop_front();

    if (txn.crc_out === exp_txn.crc_out) begin
      match_count++;
      `uvm_info("SB", $sformatf("MATCH: out=0x%08h", txn.crc_out), UVM_LOW)
    end else begin
      mismatch_count++;
      `uvm_error("SB",
        $sformatf("MISMATCH: ACT=0x%08h EXP=0x%08h sel=%0d din=0x%08h init=0x%08h",
          txn.crc_out, exp_txn.crc_out, txn.crc_select, txn.data_in, txn.crc_init))
    end
  endfunction

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);

    if (mismatch_count == 0)
      `uvm_info("SB", $sformatf("PASS. matches=%0d", match_count), UVM_LOW)
    else
      `uvm_error("SB", $sformatf("FAIL. matches=%0d mismatches=%0d", match_count, mismatch_count))
  endfunction

endclass
