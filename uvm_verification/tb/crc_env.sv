// CRC Environment
// =====================================================
// תיאור: Environment המכיל את כל רכיבי ה-UVM

class crc_env extends uvm_env;
    
    crc_in_agent agent;
    crc_predictor predictor;
    crc_scoreboard scoreboard;
    
    `uvm_component_utils(crc_env)
    
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
        
        agent = crc_in_agent::type_id::create("agent", this);
        predictor = crc_predictor::type_id::create("predictor", this);
        scoreboard = crc_scoreboard::type_id::create("scoreboard", this);
        
        `uvm_info("ENV", "Environment built successfully", UVM_LOW)
    endfunction : build_phase
    
    // =====================================================
    // Connect Phase
    // =====================================================
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        // Connect agent output to predictor and scoreboard
        agent.analysis_port.connect(predictor.analysis_imp);
        agent.analysis_port.connect(scoreboard.actual_imp);
        
        // Connect predictor output to scoreboard
        predictor.predicted_port.connect(scoreboard.predicted_imp);
        
        `uvm_info("ENV", "Connections completed", UVM_MEDIUM)
    endfunction : connect_phase
    
    // =====================================================
    // End of Elaboration Phase
    // =====================================================
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        `uvm_info("ENV", "Elaboration phase complete", UVM_MEDIUM)
    endfunction : end_of_elaboration_phase
    
endclass : crc_env
