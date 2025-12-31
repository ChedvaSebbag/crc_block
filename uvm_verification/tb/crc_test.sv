// CRC Test Base Class
// =====================================================
// תיאור: Base test class עם כל ה-tests

class crc_test extends uvm_test;
    
    crc_env env;
    
    `uvm_component_utils(crc_test)
    
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
        
        env = crc_env::type_id::create("env", this);
        
        `uvm_info("TEST", "Test built", UVM_MEDIUM)
    endfunction : build_phase
    
    // =====================================================
    // Connect Phase
    // =====================================================
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("TEST", "Test connected", UVM_MEDIUM)
    endfunction : connect_phase
    
    // =====================================================
    // Run Phase
    // =====================================================
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        
        `uvm_info("TEST", "Running test...", UVM_LOW)
        
        #1000;
        
        phase.drop_objection(this);
    endtask : run_phase
    
endclass : crc_test

// =====================================================
// Basic Functionality Tset
// =====================================================
class crc_basic_functionality_test extends crc_test;
   
    `uvm_component_utils(crc_basic_functionality_test)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
    
    task run_phase(uvm_phase phase);
        crc_random_seq seq = crc_random_seq::type_id::create("seq");
        
        phase.raise_objection(this);
        
      `uvm_info("BASIC_TEST", "Starting basic functionality test", UVM_LOW)
        
        seq.num_transactions = 100;
      seq.start(env.agent.sequencer);
        
        #500;
        
        phase.drop_objection(this);
    endtask : run_phase
    
endclass : crc_basic_functionality_test

// =====================================================
// Directed Test
// =====================================================
class crc_directed_test extends crc_test;
    
    `uvm_component_utils(crc_directed_test)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
    
    task run_phase(uvm_phase phase);
        crc_directed_seq seq = crc_directed_seq::type_id::create("seq");
        
        phase.raise_objection(this);
        
        `uvm_info("DIRECTED_TEST", "Starting directed test", UVM_LOW)
        
        seq.start(env.agent.sequencer);
        
        #500;
        
        phase.drop_objection(this);
    endtask : run_phase
    
endclass : crc_directed_test

// =====================================================
// Edge Case Test
// =====================================================
class crc_edge_case_test extends crc_test;
    
    `uvm_component_utils(crc_edge_case_test)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
    
    task run_phase(uvm_phase phase);
        crc_edge_case_seq seq = crc_edge_case_seq::type_id::create("seq");
        
        phase.raise_objection(this);
        
        `uvm_info("EDGE_CASE_TEST", "Starting edge case test", UVM_LOW)
        
        seq.start(env.agent.sequencer);
        
        #500;
        
        phase.drop_objection(this);
    endtask : run_phase
    
endclass : crc_edge_case_test
