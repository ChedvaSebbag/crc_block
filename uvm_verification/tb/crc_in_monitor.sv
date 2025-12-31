`ifndef CRC_MONITOR_IN_SV
`define CRC_MONITOR_IN_SV

class crc_monitor_in extends uvm_monitor;
  `uvm_component_utils(crc_monitor_in)

  virtual crc_if vif;
  uvm_analysis_port #(crc_transaction) ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual crc_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "crc_monitor_in: No vif")
  endfunction

  task run_phase(uvm_phase phase);
    crc_transaction tr;

    forever begin
      @(posedge vif.clk);

      if (vif.data_valid) begin
        tr = crc_transaction::type_id::create("tr", this);

        tr.tr_type    = CRC_INPUT;
        tr.data_in    = vif.data_in;
        tr.crc_init   = vif.crc_init;
        tr.crc_select = vif.crc_select;
        tr.data_valid = vif.data_valid;

        // snapshot signals
        tr.busy      = vif.busy;
        tr.crc_valid = vif.crc_valid;
        tr.crc_out   = vif.crc_out;

        ap.write(tr);
      end
    end
  endtask

endclass

`endif
