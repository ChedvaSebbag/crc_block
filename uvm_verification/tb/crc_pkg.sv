// CRC Verification Package
// =====================================================
// תיאור: חבילה עיקרית המכילה את כל רכיבי ה-UVM

`ifndef CRC_PKG_SV
`define CRC_PKG_SV

package crc_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

    
    // =====================================================
    // Include Files
    // =====================================================
    `include "crc_defines.sv"
    `include "crc_transaction.sv"
    `include "crc_driver.sv"
    `include "crc_sequencer.sv"
    `include "crc_monitor.sv"
    `include "crc_in_agent.sv"
    `include "crc_predictor.sv"
    `include "crc_scoreboard.sv"
    `include "crc_env.sv"
    `include "crc_seq_lib.sv"
    `include "crc_test.sv"
    
endpackage : crc_pkg

`endif // CRC_PKG_SV
