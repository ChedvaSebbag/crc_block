// =====================================================
// crc_coverage.sv  (UVM Functional Coverage Collector)
// UPDATED: Reset/Flow/Ctrl sampled from VIF clocked
// =====================================================

`ifndef CRC_COVERAGE_SV
`define CRC_COVERAGE_SV

class crc_coverage extends uvm_subscriber #(crc_transaction);
  `uvm_component_utils(crc_coverage)

  crc_transaction tr;
  virtual crc_if vif;

  // -------------------------------
  // Flow tracking (from VIF)
  // -------------------------------
  int unsigned txn_count = 0;
  bit          cont_sample = 0;

  logic [31:0] prev_crc_init;
  bit          has_prev_init = 0;
  bit          prev_data_valid = 0;

  // continuous if same crc_init as previous VALID beat
  function automatic bit is_continuous_now_vif();
    return (has_prev_init && (vif.crc_init === prev_crc_init));
  endfunction

  // =====================================
  // 1) CRC Type Coverage (from transaction)
  // =====================================
  covergroup cg_crc_type;
    option.per_instance = 1;
    cp_type : coverpoint tr.crc_select iff (tr.data_valid) {
      bins crc3  = {2'b00};
      bins crc8  = {2'b01};
      bins crc16 = {2'b10};
      bins crc32 = {2'b11};
    }
  endgroup

  // =====================================
  // 2) Reset Coverage (sampled from VIF)
  // NOTE: we sample both data_valid=0 and data_valid=1
  // =====================================
  covergroup cg_reset;
    option.per_instance = 1;
    cp_dv : coverpoint vif.data_valid {
      bins zero = {0};
      bins one  = {1};
    }
  endgroup

  // =====================================
  // 3) Operation Flow Coverage (sampled at end of burst)
  // =====================================
  covergroup cg_flow;
    option.per_instance = 1;

    cp_multi : coverpoint txn_count {
      bins single_op = {1};
      bins multi_op  = {[2:1000]};
    }

    cp_cont : coverpoint cont_sample {
      bins single_mode = {0};
      bins continuous  = {1};
    }
  endgroup

  // =====================================
  // 4) Control Signal Coverage (from VIF)
  // =====================================
  covergroup cg_ctrl;
    option.per_instance = 1;

    cp_busy : coverpoint vif.busy {
      bins idle = {0};
      bins busy = {1};
    }

    cp_valid : coverpoint vif.crc_valid {
      bins not_valid = {0};
      bins valid     = {1};
    }
  endgroup

  // =====================================
  // 5) Data Patterns Coverage (from transaction)
  // =====================================
  covergroup cg_data_patterns;
    option.per_instance = 1;
    cp_data : coverpoint tr.data_in iff (tr.data_valid) {
      bins all0  = {32'h00000000};
      bins all1  = {32'hFFFFFFFF};
      bins other = default;
    }
  endgroup

  // =====================================
  // Constructor
  // =====================================
  function new(string name, uvm_component parent);
    super.new(name, parent);
    cg_crc_type      = new();
    cg_reset         = new();
    cg_flow          = new();
    cg_ctrl          = new();
    cg_data_patterns = new();
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual crc_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "crc_coverage: No vif in config_db")
  endfunction

  // =====================================
  // Clocked sampling from interface
  // This is what closes Reset/Flow/Ctrl to 100%
  // =====================================
  task run_phase(uvm_phase phase);
    super.run_phase(phase);

    forever begin
      @(posedge vif.clk);

      // sample reset + ctrl every cycle (guarantees 0/1 hits)
      cg_reset.sample();
      cg_ctrl.sample();

      // FLOW tracking: count only valid beats
      if (vif.data_valid === 1'b1) begin
        if (!prev_data_valid)
          txn_count = 0;

        txn_count++;
        cont_sample = is_continuous_now_vif();

        // update "previous init" only on valid beats
        prev_crc_init = vif.crc_init;
        has_prev_init = 1;
      end

      // burst end: when dv drops 1->0, sample flow once
      if (prev_data_valid && (vif.data_valid === 1'b0)) begin
        if (txn_count > 0)
          cg_flow.sample();
        txn_count = 0;
      end

      prev_data_valid = (vif.data_valid === 1'b1);
    end
  endtask

  // =====================================
  // Transaction path (kept)
  // Type + Patterns are still sampled from items
  // =====================================
  virtual function void write(crc_transaction t);
    tr = t;

    // These should be tied to actual item content
    if (t.data_valid === 1'b1) begin
      cg_crc_type.sample();
      cg_data_patterns.sample();
    end
  endfunction

  // =====================================
  // Report
  // =====================================
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("VPLAN_COV",
      $sformatf(
        "Type: %0.2f%%, Reset: %0.2f%%, Flow: %0.2f%%, Ctrl: %0.2f%%",
        cg_crc_type.get_coverage(),
        cg_reset.get_coverage(),
        cg_flow.get_coverage(),
        cg_ctrl.get_coverage()
      ),
      UVM_LOW)
  endfunction

endclass

`endif
