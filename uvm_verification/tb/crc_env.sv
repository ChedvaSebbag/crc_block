
class crc_env extends uvm_env;
    
  crc_in_agent   agent;
  crc_ref_model  ref_model;
  crc_scoreboard scoreboard;
  crc_coverage   cov;
    
  `uvm_component_utils(crc_env)
    
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
    
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
        
    agent      = crc_in_agent ::type_id::create("agent", this);
    ref_model  = crc_ref_model::type_id::create("ref_model", this);
    scoreboard = crc_scoreboard::type_id::create("scoreboard", this);
    cov        = crc_coverage  ::type_id::create("cov", this);

    `uvm_info("ENV", "Environment built successfully", UVM_LOW)
  endfunction
    
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
        
    // INPUT -> Predictor + Coverage
    agent.in_ap.connect(ref_model.analysis_imp);
    agent.in_ap.connect(cov.analysis_export);

    // OUTPUT -> Scoreboard (actual)
    agent.out_ap.connect(scoreboard.actual_imp);

    // Predictor -> Scoreboard (expected)
    ref_model.predicted_port.connect(scoreboard.predicted_imp);

    `uvm_info("ENV", "Connections completed", UVM_MEDIUM)
  endfunction
    
endclass
