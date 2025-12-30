// CRC Sequencer
// =====================================================
// תיאור: Sequencer המנהל את סדר ה-transactions

class crc_sequencer extends uvm_sequencer #(crc_transaction);
    
    `uvm_component_utils(crc_sequencer)
    
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
        `uvm_info("SEQUENCER", "Sequencer built", UVM_MEDIUM)
    endfunction : build_phase
    
endclass : crc_sequencer
