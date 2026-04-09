module alu (

  input  logic [31:0]  a_i,
  input  logic [31:0]  b_i,
  input  logic [4:0]   alu_op_i,
  output logic         flag_o,
  output logic [31:0]  result_o
);
    
  import alu_opcodes_pkg::*;    
  
  logic [31:0] adder_sum;

  
  fulladder32bit adder_inst (
      .A       (a_i),
      .B       (( alu_op_i == ALU_ADD ) ? b_i : ~b_i),
      .CARRY_I (( alu_op_i == ALU_ADD ) ? 1'b0 : 1'b1),
      .SUM_O   (adder_sum),
      .CARRY_O ()
  );
  
  always_comb begin
      
    result_o = 32'd0;
    
    case(alu_op_i)
      
      ALU_ADD: result_o=adder_sum;
      ALU_SUB: result_o=adder_sum;
      ALU_SLL: result_o=a_i<<b_i[4:0];
      ALU_SLTS: result_o=($signed(a_i)< $signed(b_i));
      ALU_SLTU: result_o=a_i<b_i;
      ALU_XOR: result_o=a_i^b_i;
      ALU_SRL: result_o=a_i>>b_i[4:0];
      ALU_SRA: result_o=$signed(a_i)>>>b_i[4:0];
      ALU_OR: result_o=a_i|b_i;
      ALU_AND: result_o=a_i&b_i;
      
      default: begin
        result_o = 32'd0;
     end
    endcase
  end
  
  
    always_comb begin
      
    flag_o   = 1'b0;
      
    case(alu_op_i)
      
    ALU_EQ: flag_o= (a_i == b_i);
    ALU_NE: flag_o= (a_i != b_i);
    ALU_LTS: flag_o= ($signed(a_i) < $signed(b_i));
    ALU_GES: flag_o= ($signed(a_i) >= $signed(b_i));
    ALU_LTU: flag_o= a_i < b_i;
    ALU_GEU: flag_o=a_i >= b_i;
      
     default: begin
        flag_o   = 1'b0;
     end
   
    endcase
  end
  
endmodule