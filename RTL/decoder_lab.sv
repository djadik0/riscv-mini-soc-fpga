module decoder_lab (
  input  logic [31:0]  fetched_instr_i,
  output logic [1:0]   a_sel_o,
  output logic [2:0]   b_sel_o,
  output logic [4:0]   alu_op_o,
  output logic [2:0]   csr_op_o,
  output logic         csr_we_o,
  output logic         mem_req_o,
  output logic         mem_we_o,
  output logic [2:0]   mem_size_o,
  output logic         gpr_we_o,
  output logic [1:0]   wb_sel_o,
  output logic         illegal_instr_o,
  output logic         branch_o,
  output logic         jal_o,
  output logic         jalr_o,
  output logic         mret_o
);
  import decoder_pkg::*;


  logic [4:0] opcode;
  logic [2:0] func3;
  logic [6:0] func7;
  logic [1:0] saife;
  logic [4:0] rd;


  assign saife = fetched_instr_i[1:0];
  assign opcode = fetched_instr_i[6:2];
  assign func3 = fetched_instr_i[14:12];
  assign func7 = fetched_instr_i[31:25];
  assign rd = fetched_instr_i[11:7];

  
   always_comb begin       
  csr_op_o=3'b0;
  csr_we_o=1'b0;
  mem_req_o=1'b0;
  mem_we_o=1'b0;
  mem_size_o=3'b0;
  gpr_we_o=1'b0;
  wb_sel_o=2'b11;
  illegal_instr_o=1'b0;
  branch_o=1'b0;
  jal_o=1'b0;
  jalr_o=1'b0;
  mret_o=1'b0;
  a_sel_o=2'b11;
  b_sel_o=3'b111;
  alu_op_o=5'b11011;

     if (saife != 2'b11) begin
        illegal_instr_o = 1'b1;
        end else

    case(opcode)


      LOAD_OPCODE: begin
        case (func3)
        3'b000: begin
                mem_size_o = LDST_B;
	        mem_req_o = 1'b1;
                gpr_we_o = 1'b1;
                a_sel_o = OP_A_RS1;
                b_sel_o = OP_B_IMM_I;
                wb_sel_o = WB_LSU_DATA;
                alu_op_o= ALU_ADD;
                end
        3'b001: begin
                mem_size_o = LDST_H;
                mem_req_o = 1'b1;
                gpr_we_o = 1'b1;
                a_sel_o = OP_A_RS1;
                b_sel_o = OP_B_IMM_I;
                wb_sel_o = WB_LSU_DATA;
                alu_op_o= ALU_ADD;
                end
        3'b010: begin
                mem_size_o = LDST_W;
                mem_req_o = 1'b1;
                gpr_we_o = 1'b1;
                a_sel_o = OP_A_RS1;
                b_sel_o = OP_B_IMM_I;
                wb_sel_o = WB_LSU_DATA;
                alu_op_o= ALU_ADD;
                end
        3'b100: begin
                mem_size_o = LDST_BU;
                mem_req_o = 1'b1;
                gpr_we_o = 1'b1;
                a_sel_o = OP_A_RS1;
                b_sel_o = OP_B_IMM_I;
                wb_sel_o = WB_LSU_DATA;
                alu_op_o= ALU_ADD;
                end
        3'b101: begin
                mem_size_o = LDST_HU;
                mem_req_o = 1'b1;
                gpr_we_o = 1'b1;
                a_sel_o = OP_A_RS1;
                b_sel_o = OP_B_IMM_I;
                wb_sel_o = WB_LSU_DATA;
                alu_op_o= ALU_ADD;
                end
        default: illegal_instr_o = 1'b1;
        endcase
      end
      
      MISC_MEM_OPCODE: begin 
        case (func3)
        3'b000: begin
        end
        default: illegal_instr_o = 1'b1; 
    endcase
      end
          
      OP_IMM_OPCODE: begin
              case(func3)
        3'b000: begin 
                  alu_op_o = ALU_ADD; 
                  gpr_we_o = 1'b1;
                  a_sel_o = OP_A_RS1;
                  b_sel_o = OP_B_IMM_I;
                  wb_sel_o = WB_EX_RESULT;
                end
        3'b100: begin
                  alu_op_o = ALU_XOR;
                  gpr_we_o = 1'b1;
                  a_sel_o = OP_A_RS1;
                  b_sel_o = OP_B_IMM_I;
                  wb_sel_o = WB_EX_RESULT;
                end
        3'b110: begin
                  alu_op_o = ALU_OR;
                  gpr_we_o = 1'b1;
                  a_sel_o = OP_A_RS1;
                  b_sel_o = OP_B_IMM_I;
                  wb_sel_o = WB_EX_RESULT;
                end
        3'b111: begin
                  alu_op_o = ALU_AND; 
                  gpr_we_o = 1'b1;
                  a_sel_o = OP_A_RS1;
                  b_sel_o = OP_B_IMM_I;
                  wb_sel_o = WB_EX_RESULT;
                end
        3'b001: begin  
                  if (func7 == 7'b0000000) begin
                    alu_op_o = ALU_SLL;
                    gpr_we_o = 1'b1;
                    a_sel_o  = OP_A_RS1;
                    b_sel_o  = OP_B_IMM_I;
                    wb_sel_o = WB_EX_RESULT;       
                  end else 
                    illegal_instr_o = 1'b1;
                end
        3'b101: begin
                  if (func7 == 7'b0000000) begin
                    alu_op_o = ALU_SRL;
                    gpr_we_o=1'b1;
                    a_sel_o = OP_A_RS1;
                    b_sel_o = OP_B_IMM_I;
                    wb_sel_o = WB_EX_RESULT;
                  end if (func7 == 7'b0100000) begin
                    alu_op_o = ALU_SRA;
                    gpr_we_o=1'b1;
                    a_sel_o = OP_A_RS1;
                    b_sel_o = OP_B_IMM_I;
                    wb_sel_o = WB_EX_RESULT;
                  end 
                end
        3'b010: begin
                  alu_op_o = ALU_SLTS;
                  gpr_we_o=1'b1;
                  a_sel_o = OP_A_RS1;
                  b_sel_o = OP_B_IMM_I;
                  wb_sel_o = WB_EX_RESULT;
                end
        3'b011: begin
                  alu_op_o = ALU_SLTU;
                  gpr_we_o=1'b1;
                  a_sel_o = OP_A_RS1;
                  b_sel_o = OP_B_IMM_I;
                  wb_sel_o = WB_EX_RESULT;
                end
        default: illegal_instr_o = 1'b1;
        endcase
       end
       
      AUIPC_OPCODE: begin 
      gpr_we_o=1'b1;
      wb_sel_o = WB_EX_RESULT;
      alu_op_o = ALU_ADD;
      a_sel_o = OP_A_CURR_PC;
      b_sel_o = OP_B_IMM_U;  
      end

      STORE_OPCODE: begin 
        case(func3)
        3'b000: begin
                  mem_size_o = LDST_B;
                  mem_req_o = 1'b1;
                  mem_we_o = 1'b1;
                  a_sel_o = OP_A_RS1;
                  b_sel_o = OP_B_IMM_S;
                  wb_sel_o = WB_LSU_DATA;
                  alu_op_o = ALU_ADD;
                end
        3'b001: begin 
                  mem_size_o = LDST_H;
                  mem_req_o = 1'b1;
                  mem_we_o = 1'b1;
                  a_sel_o = OP_A_RS1;
                  b_sel_o = OP_B_IMM_S;
                  wb_sel_o = WB_LSU_DATA;
                  alu_op_o = ALU_ADD;
                end
        3'b010: begin 
                  mem_size_o = LDST_W;
                  mem_req_o = 1'b1;
                  mem_we_o = 1'b1;
                  a_sel_o = OP_A_RS1;
                  b_sel_o = OP_B_IMM_S;
                  wb_sel_o = WB_LSU_DATA;
                  alu_op_o = ALU_ADD;
                end
        default: illegal_instr_o = 1'b1;

      endcase
      end
      
      OP_OPCODE: begin 
        case(func3)
        3'b000: begin 
        if (func7 == 7'b0000000) begin
          alu_op_o = ALU_ADD;
          gpr_we_o=1'b1;
          a_sel_o = OP_A_RS1;
          b_sel_o = OP_B_RS2;
          wb_sel_o = WB_EX_RESULT;
        end 
        else if (func7 == 7'b0100000) begin
          alu_op_o = ALU_SUB;
          gpr_we_o=1'b1;
          a_sel_o = OP_A_RS1;
          b_sel_o = OP_B_RS2;
          wb_sel_o = WB_EX_RESULT;
        end else begin
        illegal_instr_o = 1'b1;
        end
        end
        3'b100: if (func7 == 7'b0000000) begin
                  alu_op_o = ALU_XOR;
                  gpr_we_o=1'b1;
                  a_sel_o = OP_A_RS1;
                  b_sel_o = OP_B_RS2;
                  wb_sel_o = WB_EX_RESULT;
                end else 
                  illegal_instr_o = 1'b1;
        3'b110: if (func7 == 7'b0000000) begin
                  alu_op_o = ALU_OR;
                  gpr_we_o=1'b1;
                  a_sel_o = OP_A_RS1;
                  b_sel_o = OP_B_RS2;
                  wb_sel_o = WB_EX_RESULT;
                end else 
                  illegal_instr_o = 1'b1;
        3'b111:  if (func7 == 7'b0000000) begin
                  alu_op_o = ALU_AND;
                  gpr_we_o=1'b1;
                  a_sel_o = OP_A_RS1;
                  b_sel_o = OP_B_RS2;
                  wb_sel_o = WB_EX_RESULT;
                end else
                  illegal_instr_o = 1'b1;
        3'b001: if (func7 == 7'b0000000) begin 
                  alu_op_o = ALU_SLL;
                  gpr_we_o=1'b1;
                  a_sel_o = OP_A_RS1;
                  b_sel_o = OP_B_RS2;
                  wb_sel_o = WB_EX_RESULT;
                end else 
                  illegal_instr_o = 1'b1;
        3'b101: begin
        if (func7 == 7'b0000000) begin
          alu_op_o = ALU_SRL;
          gpr_we_o=1'b1;
          a_sel_o = OP_A_RS1;
          b_sel_o = OP_B_RS2;
          wb_sel_o = WB_EX_RESULT;
        end else if (func7 == 7'b0100000) begin
          alu_op_o = ALU_SRA;
          gpr_we_o=1'b1;
          a_sel_o = OP_A_RS1;
          b_sel_o = OP_B_RS2;
          wb_sel_o = WB_EX_RESULT;
        end
        end
        3'b010: if (func7 == 7'b0000000) begin 
                  alu_op_o = ALU_SLTS;
                  gpr_we_o=1'b1;
                  a_sel_o = OP_A_RS1;
                  b_sel_o = OP_B_RS2;
                  wb_sel_o = WB_EX_RESULT;
                end else
                  illegal_instr_o = 1'b1;
        3'b011: if (func7 == 7'b0000000) begin
                  alu_op_o = ALU_SLTU;
                  gpr_we_o=1'b1;
                  a_sel_o = OP_A_RS1;
                  b_sel_o = OP_B_RS2;
                  wb_sel_o = WB_EX_RESULT;
                end else 
                  illegal_instr_o = 1'b1;
        default: illegal_instr_o = 1'b1;
        endcase
      end
      
      LUI_OPCODE: begin 
      gpr_we_o=1'b1;
      a_sel_o = OP_A_ZERO;
      b_sel_o = OP_B_IMM_U;
      wb_sel_o = WB_EX_RESULT;
      alu_op_o = ALU_ADD;
      end
      
      
      BRANCH_OPCODE: begin 
        case (func3)
          3'b000: begin
                    alu_op_o = ALU_EQ;  
                    a_sel_o = OP_A_RS1;
                    b_sel_o = OP_B_RS2;
                    branch_o = 1'b1;   
                  end                    
          3'b001: begin 
                    alu_op_o = ALU_NE; 
                    a_sel_o = OP_A_RS1;
                    b_sel_o = OP_B_RS2;
                    branch_o = 1'b1;   
                  end                                      
          3'b100: begin
                    alu_op_o = ALU_LTS;      
                    a_sel_o = OP_A_RS1;
                    b_sel_o = OP_B_RS2;
                    branch_o = 1'b1;   
                  end               
          3'b101: begin
                    alu_op_o = ALU_GES;
                    a_sel_o = OP_A_RS1;
                    b_sel_o = OP_B_RS2;
                    branch_o = 1'b1;   
                  end                   
          3'b110: begin
                    alu_op_o = ALU_LTU; 
                    a_sel_o = OP_A_RS1;
                    b_sel_o = OP_B_RS2;
                    branch_o = 1'b1;   
                  end                                       
          3'b111: begin
                    alu_op_o = ALU_GEU; 
                    a_sel_o = OP_A_RS1;
                    b_sel_o = OP_B_RS2;
                    branch_o = 1'b1;   
                  end                                      
          default: illegal_instr_o = 1'b1;
        endcase
      end
      
      JALR_OPCODE: begin
      if (func3 == 3'b000) begin 
        a_sel_o = OP_A_CURR_PC;
        b_sel_o = OP_B_INCR;
        wb_sel_o = WB_EX_RESULT;
        alu_op_o = ALU_ADD;
        gpr_we_o=1'b1;
        jalr_o =1'b1;
      end else
        illegal_instr_o = 1'b1;
      end
      
      JAL_OPCODE: begin 
      a_sel_o = OP_A_CURR_PC;
      b_sel_o = OP_B_INCR;
      wb_sel_o = WB_EX_RESULT;
      alu_op_o = ALU_ADD;
      gpr_we_o=1'b1;
      jal_o =1'b1;
      end
      
      SYSTEM_OPCODE: begin 
      case (func3)
          3'b000: begin
          gpr_we_o = 1'b0;        
          csr_we_o = 1'b0;
          a_sel_o = OP_A_RS1;
          wb_sel_o= WB_CSR_DATA;
          case (fetched_instr_i)
          32'b00000000000000000000000001110011:  illegal_instr_o = 1'b1;
          32'b00000000000100000000000001110011:  illegal_instr_o = 1'b1;
          32'b00110000001000000000000001110011:  mret_o = 1'b1;
          default: begin
                     illegal_instr_o = 1'b1;
                     wb_sel_o= 2'b00;
                   end
          endcase
          end                        
          3'b001: begin
                    csr_op_o = CSR_RW;
                    gpr_we_o= 1'b1;
                    wb_sel_o= WB_CSR_DATA;
                    csr_we_o = 1'b1;
                    a_sel_o = OP_A_RS1;
                  end
          3'b010: begin
                    csr_op_o = CSR_RS; 
                    gpr_we_o= 1'b1;
                    wb_sel_o= WB_CSR_DATA;
                    csr_we_o = 1'b1;
                    a_sel_o = OP_A_RS1;
                  end                   
          3'b011: begin
                    csr_op_o = CSR_RC; 
                    gpr_we_o= 1'b1;
                    wb_sel_o= WB_CSR_DATA;
                    csr_we_o = 1'b1;
                    a_sel_o = OP_A_RS1;
                  end    
          3'b101: begin
                    csr_op_o = CSR_RWI;   
                    gpr_we_o= 1'b1;
                    wb_sel_o= WB_CSR_DATA;
                    csr_we_o = 1'b1;
                    a_sel_o = OP_A_RS1;
                  end
          3'b110: begin
                    csr_op_o = CSR_RSI; 
                    gpr_we_o= 1'b1;
                    wb_sel_o= WB_CSR_DATA;
                    csr_we_o = 1'b1;
                    a_sel_o = OP_A_RS1;
                  end                       
          3'b111: begin
                    csr_op_o = CSR_RCI;
                    gpr_we_o= 1'b1;
                    wb_sel_o= WB_CSR_DATA;
                    csr_we_o = 1'b1;
                    a_sel_o = OP_A_RS1;
                  end
      default: illegal_instr_o = 1'b1;
      endcase

      end
      
    default: begin
  csr_op_o=3'b0;
  csr_we_o=1'b0;
  mem_req_o=1'b0;
  mem_we_o=1'b0;
  mem_size_o=3'b0;
  gpr_we_o=1'b0;
  wb_sel_o=2'b11;
  branch_o=1'b0;
  jal_o=1'b0;
  jalr_o=1'b0;
  mret_o=1'b0;
  a_sel_o=2'b11;
  b_sel_o=3'b111;
  alu_op_o=5'b11011;
  illegal_instr_o = 1'b1;
   end
   endcase
   end

endmodule