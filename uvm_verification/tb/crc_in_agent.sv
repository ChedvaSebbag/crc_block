// CRC Agent
// =====================================================
// תיאור: Agent המכיל Driver, Sequencer, ו-Monitor

class crc_in_agent extends uvm_agent;
    
    crc_driver driver;
    crc_sequencer sequencer;
    crc_monitor monitor;
    
    uvm_analysis_port #(crc_transaction) analysis_port;
    
  `uvm_component_utils(crc_in_agent)
    
    // =====================================================
    // Constructor
    // =====================================================
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
    
    // =====================================================
    // Build Phase
    // =====================================================
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        driver = crc_driver::type_id::create("driver", this);
        sequencer = crc_sequencer::type_id::create("sequencer", this);
        monitor = crc_monitor::type_id::create("monitor", this);
        
        analysis_port = new("analysis_port", this);
    endfunction : build_phase
    
    // =====================================================
    // Connect Phase
    // =====================================================
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        driver.seq_item_port.connect(sequencer.seq_item_export);
        monitor.item_collected_port.connect(analysis_port);
    endfunction : connect_phase
    
endclass : crc_in_agent
