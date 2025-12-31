// =====================================================
// Predictor שמחשב תוצאה צפויה לפי אותו אלגוריתם של ה-DUT

class crc_ref_model extends uvm_component;

  uvm_analysis_imp #(crc_transaction, crc_ref_model) analysis_imp;
  uvm_analysis_port #(crc_transaction) predicted_port;

  `uvm_component_utils(crc_ref_model)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    analysis_imp    = new("analysis_imp", this);
    predicted_port  = new("predicted_port", this);
  endfunction

  // Called when monitor sends an actual transaction
  function void write(crc_transaction txn);
    crc_transaction predicted_txn;
    logic [31:0] poly32;
    logic [31:0] next32;

    predicted_txn = crc_transaction::type_id::create("predicted_txn");
    predicted_txn.copy(txn);

    poly32 = poly_from_select(txn.crc_select);
    next32 = crc_next32(txn.crc_init, txn.data_in, poly32);

    predicted_txn.crc_out   = mask_crc32(next32, txn.crc_select);
    predicted_txn.crc_valid = 1'b1;

    predicted_port.write(predicted_txn);
  endfunction

  function automatic logic [31:0] poly_from_select(input logic [1:0] s);
    case (s)
      2'b00: return 32'h00000003;
      2'b01: return 32'h00000107;
      2'b10: return 32'h00018005;
      default: return 32'h04C11DB7;
    endcase
  endfunction

  function automatic logic [31:0] crc_next32(
    input logic [31:0] current,
    input logic [31:0] din,
    input logic [31:0] p
  );
    int i;
    logic [31:0] tmp;

    tmp = current;
    for (i = 31; i >= 0; i--) begin
      if ((tmp[31] ^ din[i]) == 1'b1)
        tmp = (tmp << 1) ^ p;
      else
        tmp = (tmp << 1);
    end
    return tmp;
  endfunction

  function automatic logic [31:0] mask_crc32(
    input logic [31:0] v,
    input logic [1:0]  s
  );
    case (s)
      2'b00: return {29'b0, v[2:0]};
      2'b01: return {24'b0, v[7:0]};
      2'b10: return {16'b0, v[15:0]};
      default: return v;
    endcase
  endfunction

endclass
