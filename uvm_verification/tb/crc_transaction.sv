//CRC Transaction
// =====================================================
// תיאור: Transaction שמכיל את כל נתוני העברת הנתונים

typedef enum { CRC_INPUT, CRC_OUTPUT } crc_tr_type_e;

class crc_transaction extends uvm_sequence_item;

  // =========================
  // Transaction type
  // =========================
  crc_tr_type_e tr_type;

  // =========================
  // Inputs (driven)
  // =========================
  rand logic [`DATA_WIDTH-1:0] data_in;
  rand logic [`DATA_WIDTH-1:0] crc_init;
  rand logic [`SELECT_WIDTH-1:0] crc_select;
  rand logic data_valid;

  // =========================
  // Outputs (observed)
  // =========================
  logic [`DATA_WIDTH-1:0] crc_out;
  logic crc_valid;
  logic busy; // optional snapshot

  // =========================
  // Constraints (unchanged)
  // =========================
  constraint valid_c  { data_valid dist { 1 :/ 90, 0 :/ 10 }; }
  constraint select_c { crc_select inside {2'b00,2'b01,2'b10,2'b11}; }

  // =========================
  // UVM registration
  // =========================
  `uvm_object_utils_begin(crc_transaction)
    `uvm_field_enum(crc_tr_type_e, tr_type, UVM_DEFAULT)
    `uvm_field_int(data_in,     UVM_DEFAULT)
    `uvm_field_int(crc_init,    UVM_DEFAULT)
    `uvm_field_int(crc_select,  UVM_DEFAULT)
    `uvm_field_int(data_valid,  UVM_DEFAULT)
    `uvm_field_int(crc_out,     UVM_DEFAULT | UVM_NOCOMPARE)
    `uvm_field_int(crc_valid,   UVM_DEFAULT | UVM_NOCOMPARE)
    `uvm_field_int(busy,        UVM_DEFAULT | UVM_NOCOMPARE)
  `uvm_object_utils_end

  function new(string name="crc_transaction");
    super.new(name);
  endfunction

  function string convert2string();
    return $sformatf(
      "type=%s | din=0x%08h init=0x%08h sel=%0d dv=%0b | out=0x%08h cv=%0b busy=%0b",
      tr_type.name(), data_in, crc_init, crc_select,
      data_valid, crc_out, crc_valid, busy
    );
  endfunction

endclass