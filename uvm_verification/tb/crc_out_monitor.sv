`ifndef CRC_MONITOR_OUT_SV
`define CRC_MONITOR_OUT_SV

class crc_monitor_out extends uvm_monitor;
  `uvm_component_utils(crc_monitor_out)

  virtual crc_if vif;
  uvm_analysis_port #(crc_transaction) ap;

  // שמירת מצב קודם כדי לזהות edges
  bit prev_busy;
  bit prev_crc_valid;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
    prev_busy      = 0;
    prev_crc_valid = 0;
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual crc_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "crc_monitor_out: No vif")
  endfunction

 task run_phase(uvm_phase phase);
  crc_transaction tr;

  forever begin
    @(posedge vif.clk);

    if (vif.crc_valid && !vif.busy) begin
      tr = crc_transaction::type_id::create("tr", this);

      tr.tr_type   = CRC_OUTPUT;
      tr.crc_out   = vif.crc_out;
      tr.crc_valid = vif.crc_valid;
      tr.busy      = vif.busy;

      // snapshot inputs
      tr.data_in    = vif.data_in;
      tr.crc_init   = vif.crc_init;
      tr.crc_select = vif.crc_select;
      tr.data_valid = vif.data_valid;

      ap.write(tr);
    end
  end
endtask


endclass

`endif
