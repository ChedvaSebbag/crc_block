module crc_block (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [31:0] data_in,
    input  logic        data_valid,
    input  logic [1:0]  crc_select,
    input  logic [31:0] crc_init,
    output logic [31:0] crc_out,
    output logic        crc_valid,
    output logic        busy
);

  logic [31:0] crc_reg;
  logic [31:0] next_crc_reg;
  logic [1:0]  sel_reg;
  logic [31:0] poly;

  // polynomial selection
  always_comb begin
    unique case (crc_select)
      2'b00: poly = 32'h00000003;   // CRC-3
      2'b01: poly = 32'h00000107;   // CRC-8
      2'b10: poly = 32'h00018005;   // CRC-16
      default: poly = 32'h04C11DB7; // CRC-32
    endcase
  end

  function automatic [31:0] crc_next(
      input [31:0] current,
      input [31:0] din,
      input [31:0] p
  );
    integer i;
    reg [31:0] tmp;
    begin
      tmp = current;
      for (i = 31; i >= 0; i--) begin
        if ((tmp[31] ^ din[i]) == 1'b1)
          tmp = (tmp << 1) ^ p;
        else
          tmp = (tmp << 1);
      end
      crc_next = tmp;
    end
  endfunction

  function automatic [31:0] mask_crc(input [31:0] v, input [1:0] s);
    begin
      case (s)
        2'b00: mask_crc = {29'b0, v[2:0]};
        2'b01: mask_crc = {24'b0, v[7:0]};
        2'b10: mask_crc = {16'b0, v[15:0]};
        default: mask_crc = v;
      endcase
    end
  endfunction

  // sequential control
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      crc_reg      <= 32'b0;
      next_crc_reg <= 32'b0;
      sel_reg      <= 2'b00;
      crc_out      <= 32'b0;
      busy         <= 1'b0;
      crc_valid    <= 1'b0;
    end else begin
      crc_valid <= 1'b0; // default pulse low

      // finish stage
      if (busy) begin
        busy      <= 1'b0;
        crc_reg   <= next_crc_reg;
        crc_out   <= mask_crc(next_crc_reg, sel_reg);
        crc_valid <= 1'b1;
      end

      // accept new transaction only when idle
      if (data_valid && !busy) begin
        busy         <= 1'b1;
        sel_reg      <= crc_select;
        next_crc_reg <= crc_next(crc_init, data_in, poly);
      end
    end
  end

endmodule
