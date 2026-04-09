module processor_core(
  input  logic        clk_i,
  input  logic        rst_i,

  input  logic        stall_i,
  input  logic [31:0] instr_i,
  input  logic [31:0] mem_rd_i,
  input  logic        irq_req_i,

  output logic [31:0] instr_addr_o,
  output logic [31:0] mem_addr_o,
  output logic [ 2:0] mem_size_o,
  output logic        mem_req_o,
  output logic        mem_we_o,
  output logic [31:0] mem_wd_o,
  output logic        irq_ret_o
);

logic [1:0]  a_sel_i;
logic [2:0]  b_sel_i;
logic [4:0]  alu_op_i;
logic [2:0]  csr_op_i;
logic        csr_we_i;
logic        mem_req_i;
logic        mem_we_i;
logic [2:0]  mem_size_i;
logic        gpr_we_i;
logic [1:0]  wb_sel_i;
logic        branch_i;
logic        jal_i;
logic        jalr_i;
logic        mret_i;

logic [31:0] alu_result;
logic [4:0]  ALUop;
logic        flag_o;
logic [31:0] PC;
logic [31:0] next_jalr_pc;
logic [31:0] next_trap_pc;
logic [31:0] next_pc;
logic [31:0] wb_data;
logic [31:0] jump_prov1;
logic [31:0] jump_prov2;
logic        b_jal;

  logic        irq;
  logic        ili_instr;
  logic [31:0] irq_cause_o;
  logic [31:0] imm_Z;
  logic [31:0] mie;
  logic        trap;
  logic [31:0] csr_wd;
  logic [31:0] mepc;
  logic [31:0] mtvec;
  logic [31:0] mcause_i;

  logic [4:0]  opcode;
  logic [4:0]  RA1;
  logic [4:0]  RA2;
  logic [31:0] write_data;
  logic        reg_write;
  logic [31:0] read_data1;
  logic [31:0] read_data2;
  logic        WE;
  logic [4:0]  WA;
  logic [31:0] RD1_Immi;
  logic [31:0] imm_B;
  logic [31:0] imm_J;



decoder_lab decoder_i(
  .fetched_instr_i (instr_i),
  .a_sel_o         (a_sel_i),
  .b_sel_o         (b_sel_i),
  .alu_op_o        (alu_op_i),
  .csr_op_o        (csr_op_i),
  .csr_we_o        (csr_we_i),
  .mem_req_o       (mem_req_i),
  .mem_we_o        (mem_we_i),
  .mem_size_o      (mem_size_o),
  .gpr_we_o        (gpr_we_i),
  .wb_sel_o        (wb_sel_i),
  .illegal_instr_o (ili_instr),
  .branch_o        (branch_i),
  .jal_o           (jal_i),
  .jalr_o          (jalr_i),
  .mret_o          (mret_i)
);

interrupt_controller interrupt_controller_i (
  .clk_i          (clk_i),
  .rst_i          (rst_i),
  .exception_i    (ili_instr),
  .irq_req_i      (irq_req_i),
  .mie_i          (mie[16]),
  .mret_i         (mret_i),
  .irq_ret_o      (irq_ret_o),
  .irq_cause_o    (irq_cause_o),
  .irq_o          (irq)
);




csr_controller csr_controller_i(

  .clk_i          (clk_i),
  .rst_i          (rst_i),
  .trap_i         (trap),
  .opcode_i       (csr_op_i),
  .addr_i         (instr_i[31:20]),
  .pc_i           (PC),
  .mcause_i       (mcause_i),
  .rs1_data_i     ((RA1 != 0) ? register_file[RA1] : 32'b0),
  .imm_data_i     (imm_Z),
  .write_enable_i (csr_we_i),
  .read_data_o    (csr_wd),
  .mie_o          (mie),
  .mepc_o         (mepc),
  .mtvec_o        (mtvec)
);



  assign mcause_i  = ili_instr ?  32'h0000_0002 : irq_cause_o;
  assign trap      = irq   | ili_instr;
  assign mem_we_o  = ~trap & mem_we_i;
  assign mem_req_o = ~trap & mem_req_i;


  assign opcode = instr_i[6:2];
  assign RA1    = instr_i[19:15];
  assign RA2    = instr_i[24:20];  
  assign WE     = gpr_we_i & ~(trap | stall_i);
  assign WA     = instr_i[11:7];
  assign imm_Z  = {27'b0, instr_i[19:15]};


  logic [31:0] register_file [0:31];
  initial begin
    $readmemh("rom_data.mem", register_file);
    register_file[0] = 32'b0;
  end

  always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
      for (int i = 0; i < 32; i++) begin
        register_file[i] <= 32'b0;
        end
    end else if (WE && WA != 5'b0) begin 
      register_file[WA] <= write_data;
    end
  end


  always_comb begin
    case(a_sel_i)
      2'b00: read_data1 = (RA1 != 0) ? register_file[RA1] : 32'b0;
      2'b01: read_data1 = PC;
      2'b10: read_data1 = 32'd0;
    default: read_data1 = 32'd0;
    endcase
  end

  always_comb begin
    case (b_sel_i)
      3'b000: read_data2 = (RA2 != 0) ? register_file[RA2] : 32'b0;
      3'b001: read_data2 = {{20{instr_i[31]}}, instr_i[31:20]};
      3'b010: read_data2 =  {instr_i[31:12],12'b000000000000};
      3'b011: read_data2 =  {{20{instr_i[31]}},instr_i[31:25],instr_i[11:7]};
      3'b100: read_data2 =  32'd4;
    default: read_data2 = 32'd0;
    endcase
  end

  assign mem_wd_o  = (RA2 != 0) ? register_file[RA2] : 32'b0;

  alu alu_o (
    .a_i       (read_data1),
    .b_i       (read_data2),
    .alu_op_i  (alu_op_i),
    .flag_o    (flag_o),
    .result_o  (alu_result)
  );

  assign mem_addr_o = alu_result;

   always_comb begin
     case(wb_sel_i)
     2'b00: wb_data = alu_result;
     2'b01: wb_data = mem_rd_i;
     2'b10: wb_data = csr_wd;
     default: wb_data = 32'd0;
     endcase
   end

  assign write_data =  wb_data;


  assign imm_B = {{19{instr_i[31]}}, instr_i[31], instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0};
  assign imm_J = {{11{instr_i[31]}}, instr_i[31], instr_i[19:12], instr_i[20], instr_i[30:21], 1'b0};


   always_comb begin
    case(branch_i)
    1'b0: jump_prov1 = imm_J;
    1'b1: jump_prov1 = imm_B;
    default: jump_prov1 =32'b0;
    endcase
  end

  assign b_jal      = (branch_i & flag_o) | (jal_i);

  always_comb begin
    case(b_jal)
    1'b0: jump_prov2 = 32'd4;
    1'b1: jump_prov2 = jump_prov1;
    default: jump_prov2 =32'b0;
    endcase
  end

  logic [31:0] RD1_s_Immi;

  assign RD1_s_Immi = (register_file[RA1] + {{20{instr_i[31]}}, instr_i[31:20]});
  assign RD1_Immi = {RD1_s_Immi[31:1],1'b0};


   always_comb begin
        if (jalr_i) begin
            next_jalr_pc = RD1_Immi;
        end else begin
            next_jalr_pc = PC + jump_prov2;
        end
    end

  assign next_trap_pc =  trap   ? mtvec : next_jalr_pc;
  assign next_pc      =  mret_i ? mepc  : next_trap_pc;


  always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
      PC <= 32'b0;
    end else if (~stall_i | trap) begin
      PC <= next_pc;
    end
  end


  assign instr_addr_o = PC;



endmodule