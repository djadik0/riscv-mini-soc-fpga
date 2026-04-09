module lsu(
  input  logic        clk_i,
  input  logic        rst_i,


  input  logic        core_req_i,
  input  logic        core_we_i,
  input  logic [ 2:0] core_size_i,
  input  logic [31:0] core_addr_i,
  input  logic [31:0] core_wd_i,

  output logic [31:0] core_rd_o,
  output logic        core_stall_o,

  output logic        mem_req_o,
  output logic        mem_we_o,
  output logic [ 3:0] mem_be_o,
  output logic [31:0] mem_addr_o,
  output logic [31:0] mem_wd_o,

  input  logic [31:0] mem_rd_i,
  input  logic        mem_ready_i
);


  logic  [1:0]   byte_offset;
  logic          half_offset;
  logic  [31:0]  for_LDST_B;
  logic  [31:0]  for_LDST_H;
  logic  [31:0]  for_LDST_BU;
  logic  [31:0]  for_LDST_HU;
  logic          stall_reg;


  localparam  LDST_B	 =  3'd0;
  localparam  LDST_H	 =  3'd1;
  localparam  LDST_W	 =  3'd2;
  localparam  LDST_BU	 =  3'd4;
  localparam  LDST_HU	 =  3'd5;

  assign  byte_offset  =  core_addr_i[1:0];
  assign  half_offset  =  core_addr_i[1];
  assign  mem_addr_o   =  core_addr_i;
  assign  mem_we_o     =  core_we_i;
  assign  mem_req_o    =  core_req_i;

  always_comb begin
    case( core_size_i )
      LDST_W:  mem_be_o = 4'b1111;
      LDST_H:
        if ( !half_offset ) begin
          mem_be_o = 4'b0011;
        end else begin
          mem_be_o = 4'b1100;
        end
      LDST_B: mem_be_o = 4'b0001 << byte_offset;
    endcase
  end

  always_comb begin
    case( core_size_i )
      LDST_H: mem_wd_o = {{2{core_wd_i[15:0]}}};
      LDST_W: mem_wd_o = core_wd_i;
      LDST_B: mem_wd_o = {{4{core_wd_i[7:0]}}};
    endcase
  end

  always_comb begin
    case( byte_offset )
      2'b00: for_LDST_B = {{24{mem_rd_i[7]}}, mem_rd_i[7:0]};
      2'b01: for_LDST_B = {{24{mem_rd_i[15]}}, mem_rd_i[15:8]};
      2'b10: for_LDST_B = {{24{mem_rd_i[23]}}, mem_rd_i[23:16]};
      2'b11: for_LDST_B = {{24{mem_rd_i[31]}}, mem_rd_i[31:24]};
    endcase
  end

  always_comb begin
    case( byte_offset )
      2'b00: for_LDST_BU = {24'b0, mem_rd_i[7:0]};
      2'b01: for_LDST_BU = {24'b0, mem_rd_i[15:8]};
      2'b10: for_LDST_BU = {24'b0, mem_rd_i[23:16]};
      2'b11: for_LDST_BU = {24'b0, mem_rd_i[31:24]};
    endcase
  end

  always_comb begin
    case( half_offset )
      1'b0: for_LDST_H = {{16{mem_rd_i[15]}}, mem_rd_i[15:0]};
      1'b1: for_LDST_H = {{16{mem_rd_i[31]}}, mem_rd_i[31:16]};
    endcase
  end

  always_comb begin
    case( half_offset )
      1'b0: for_LDST_HU = {16'b0, mem_rd_i[15:0]};
      1'b1: for_LDST_HU = {16'b0, mem_rd_i[31:16]};
    endcase
  end

  always_comb begin
    case( core_size_i )
      LDST_W:  core_rd_o = mem_rd_i;
      LDST_B:  core_rd_o = for_LDST_B;
      LDST_BU: core_rd_o = for_LDST_BU;
      LDST_H:  core_rd_o = for_LDST_H;
      LDST_HU: core_rd_o = for_LDST_HU;
    endcase
  end

  always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i)
      stall_reg <= 1'b0;
    else
      stall_reg <= core_stall_o;
  end


  assign core_stall_o = ~( mem_ready_i & stall_reg ) & core_req_i;

endmodule