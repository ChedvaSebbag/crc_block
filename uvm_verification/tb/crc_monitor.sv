// CRC Monitor
// =====================================================
// תיאור: Monitor שמצפה בתוצאות ו-transactions

class crc_monitor extends uvm_monitor;

  virtual crc_if vif;
  uvm_analysis_port #(crc_transaction) item_collected_port;

  `uvm_component_utils(crc_monitor)

  function new(string name, uvm_component parent);
    super.new(name, parent);
    item_collected_port = new("item_collected_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual crc_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Virtual interface not found")
  endfunction

  task run_phase(uvm_phase phase);
    forever collect_transaction();
  endtask

  task collect_transaction();
    crc_transaction txn = crc_transaction::type_id::create("txn");

    // wait for a start event
    @(vif.mon_cb);
    wait (vif.mon_cb.data_valid);

    // sample request side
    txn.data_in     = vif.mon_cb.data_in;
    txn.crc_init    = vif.mon_cb.crc_init;
    txn.crc_select  = vif.mon_cb.crc_select;
    txn.data_valid  = vif.mon_cb.data_valid;

    // now wait for response pulse
    do @(vif.mon_cb); while (!vif.mon_cb.crc_valid);

    txn.crc_out   = vif.mon_cb.crc_out;
    txn.crc_valid = vif.mon_cb.crc_valid;
    txn.busy      = vif.mon_cb.busy;

    `uvm_info("MONITOR", $sformatf("Collected: %s", txn.convert2string()), UVM_HIGH)
    item_collected_port.write(txn);
  endtask

endclass
