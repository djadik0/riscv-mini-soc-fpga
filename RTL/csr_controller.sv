module csr_controller(

  input  logic        clk_i,
  input  logic        rst_i,
  input  logic        trap_i,

  input  logic [2:0] opcode_i,

  input  logic [11:0] addr_i,
  input  logic [31:0] pc_i,
  input  logic [31:0] mcause_i,
  input  logic [31:0] rs1_data_i,
  input  logic [31:0] imm_data_i,
  input  logic        write_enable_i,

  output logic [31:0] read_data_o,
  output logic [31:0] mie_o,
  output logic [31:0] mepc_o,
  output logic [31:0] mtvec_o
);

  import csr_pkg::*;
  
  logic [31:0] read_data_oi;
  logic [31:0] opr;
  logic        en_1;
  logic        en_2;
  logic        en_3;
  logic        en_4;
  logic        en_5;

  always_comb begin
    case(opcode_i)
      3'b001:  opr =    rs1_data_i;
      3'b010:  opr =    rs1_data_i    |  read_data_oi;
      3'b011:  opr = ~( rs1_data_i )  &  read_data_oi;
      3'b101:  opr =    imm_data_i;
      3'b110:  opr =    imm_data_i    |  read_data_oi;
      3'b111:  opr = ~( imm_data_i )  &  read_data_oi;
      default: opr = 32'b0;
    endcase
  end

  always_comb begin
  
    en_1 = 1'b0;
    en_2 = 1'b0;
    en_3 = 1'b0;
    en_4 = 1'b0;
    en_5 = 1'b0;
    
    case( addr_i )
      12'h304: en_1 = write_enable_i;
      12'h305: en_2 = write_enable_i;
      12'h340: en_3 = write_enable_i;
      12'h341: en_4 = write_enable_i | trap_i;
      12'h342: en_5 = write_enable_i | trap_i;
    endcase
  end

  logic [31:0] reg_mie_o;
  logic [31:0] reg_mtvec_o;
  logic [31:0] reg_mscratch_o;
  logic [31:0] reg_mepc_o;
  logic [31:0] reg_mcause_o;


  always_ff @( posedge clk_i or posedge rst_i ) begin
    if ( rst_i ) begin
      reg_mie_o <= 32'b0;
    end else if ( en_1 ) begin
      reg_mie_o <= opr;
      end
  end
  
  assign mie_o = reg_mie_o;

  always_ff @( posedge clk_i or posedge rst_i ) begin
    if ( rst_i ) begin
      reg_mtvec_o <= 32'b0;
    end else if ( en_2 ) begin
      reg_mtvec_o <= opr;
    end
  end
    
  assign mtvec_o = reg_mtvec_o;

  always_ff @( posedge clk_i or posedge rst_i ) begin
    if ( rst_i ) begin
      reg_mscratch_o <= 32'b0;
    end else if ( en_3 ) begin
      reg_mscratch_o <= opr;
    end
  end

  always_ff @( posedge clk_i or posedge rst_i ) begin
    if ( rst_i ) begin
      reg_mepc_o <= 32'b0;
    end else if ( trap_i ) begin
      reg_mepc_o <=  pc_i;
    end else if ( en_4 ) begin
      reg_mepc_o <=  opr;
    end
  end

  assign mepc_o = reg_mepc_o;

  always_ff @( posedge clk_i or posedge rst_i ) begin
    if ( rst_i ) begin
      reg_mcause_o <= 32'b0;
    end else if ( trap_i ) begin
      reg_mcause_o <= mcause_i;
    end else if ( en_5) begin
      reg_mcause_o <= opr;
    end
  end

  always_comb begin
    case ( addr_i )
      12'h304: read_data_oi = reg_mie_o;
      12'h305: read_data_oi = reg_mtvec_o;
      12'h340: read_data_oi = reg_mscratch_o;
      12'h341: read_data_oi = reg_mepc_o;
      12'h342: read_data_oi = reg_mcause_o;
      default: read_data_oi = 32'b0;
    endcase
  end

  assign read_data_o = read_data_oi;

endmodule