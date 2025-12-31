class crc_in_agent extends uvm_agent;

  `uvm_component_utils(crc_in_agent)

  // Components
  crc_driver        driver;
  crc_sequencer     sequencer;
  crc_monitor_in    in_monitor;
  crc_monitor_out   out_monitor;

  // Analysis ports
  uvm_analysis_port #(crc_transaction) in_ap;
  uvm_analysis_port #(crc_transaction) out_ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    driver      = crc_driver       ::type_id::create("driver", this);
    sequencer   = crc_sequencer    ::type_id::create("sequencer", this);
    in_monitor  = crc_monitor_in   ::type_id::create("in_monitor", this);
    out_monitor = crc_monitor_out  ::type_id::create("out_monitor", this);

    in_ap  = new("in_ap",  this);
    out_ap = new("out_ap", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    driver.seq_item_port.connect(sequencer.seq_item_export);

    in_monitor.ap.connect(in_ap);
    out_monitor.ap.connect(out_ap);
  endfunction

endclass
