// CRC Driver
// =====================================================
// תיאור: Driver שמשדר transactions ל-DUT

class crc_driver extends uvm_driver #(crc_transaction);

  virtual crc_if vif;
  `uvm_component_utils(crc_driver)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual crc_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Virtual interface not found")
  endfunction

  task run_phase(uvm_phase phase);
    // drive defaults
    @(vif.dr_cb);
    vif.dr_cb.data_valid <= 1'b0;
    vif.dr_cb.data_in    <= '0;
    vif.dr_cb.crc_init   <= '0;
    vif.dr_cb.crc_select <= '0;

    forever begin
      seq_item_port.get_next_item(req);
      drive_transaction(req);
      seq_item_port.item_done();
    end
  endtask

  task drive_transaction(crc_transaction txn);

    // wait until idle, because DUT accepts only when !busy
    do @(vif.dr_cb); while (vif.dr_cb.busy);

    // if this txn is "inactive" (data_valid=0), just keep dv low one cycle
    if (!txn.data_valid) begin
      @(vif.dr_cb);
      vif.dr_cb.data_valid <= 1'b0;
      return;
    end

    // drive inputs and pulse data_valid for 1 cycle
    vif.dr_cb.data_in    <= txn.data_in;
    vif.dr_cb.crc_init   <= txn.crc_init;
    vif.dr_cb.crc_select <= txn.crc_select;
    vif.dr_cb.data_valid <= 1'b1;

    `uvm_info("DRIVER", $sformatf("Driving: %s", txn.convert2string()), UVM_MEDIUM)

    @(vif.dr_cb);
    vif.dr_cb.data_valid <= 1'b0;

  endtask
endclass
