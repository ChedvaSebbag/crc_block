// CRC Transaction
// =====================================================
// תיאור: Transaction שמכיל את כל נתוני העברת הנתונים

class crc_transaction extends uvm_sequence_item;

  rand logic [`DATA_WIDTH-1:0] data_in;
  rand logic [`DATA_WIDTH-1:0] crc_init;
  rand logic [`SELECT_WIDTH-1:0] crc_select;
  rand logic data_valid;

  // observed outputs (from monitor)
  logic [`DATA_WIDTH-1:0] crc_out;
  logic crc_valid;
  logic busy; // optional snapshot

  constraint valid_c { data_valid dist { 1 :/ 90, 0 :/ 10 }; }

  constraint select_c { crc_select inside {2'b00,2'b01,2'b10,2'b11}; }

  `uvm_object_utils_begin(crc_transaction)
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
    return $sformatf("din=0x%08h init=0x%08h sel=%0d dv=%0b | out=0x%08h cv=%0b busy=%0b",
      data_in, crc_init, crc_select, data_valid, crc_out, crc_valid, busy);
  endfunction

endclass
