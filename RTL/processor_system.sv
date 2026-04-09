module processor_system(
  input  logic        clk_i,
  input  logic        resetn_i,

  // Входы и выходы периферии
  input  logic [15:0] sw_i,       // Переключатели

  output logic [15:0] led_o,      // Светодиоды

  input  logic        kclk_i,     // Тактирующий сигнал клавиатуры
  input  logic        kdata_i,    // Сигнал данных клавиатуры

  output logic [ 6:0] hex_led_o,  // Вывод семисегментных индикаторов
  output logic [ 7:0] hex_sel_o,  // Селектор семисегментных индикаторов

  input  logic        rx_i,       // Линия приёма по UART
  output logic        tx_o,       // Линия передачи по UART

  output logic [3:0]  vga_r_o,    // Красный канал vga
  output logic [3:0]  vga_g_o,    // Зелёный канал vga
  output logic [3:0]  vga_b_o,    // Синий канал vga
  output logic        vga_hs_o,   // Линия горизонтальной синхронизации vga
  output logic        vga_vs_o    // Линия вертикальной синхронизации vga

);

  logic sysclk, rst;
  sys_clk_rst_gen divider(.ex_clk_i(clk_i),.ex_areset_n_i(resetn_i),.div_i(5),.sys_clk_o(sysclk), .sys_reset_o(rst));

  logic        stall_i;
  logic [31:0] instr_i;
  logic [31:0] mem_rd_i;
  logic [31:0] instr_addr_o;
  logic [31:0] mem_addr_o;
  logic [ 2:0] mem_size_o;
  logic        mem_req_o;
  logic        mem_we_o;
  logic [31:0] mem_wd_o;
  logic        irq_req;
  logic        irq_ret;

   logic        mem_req_i;
   logic        write_enable_i;
   logic [ 3:0] byte_enable_i;
   logic [31:0] addr_i;
   logic [31:0] write_data_i;
   logic [31:0] read_data_o;
   logic        ready_o;
   logic [31:0] read_data_0;
   logic [31:0] read_data_1;
   logic [31:0] read_data_2;
   logic [31:0] read_data_3;

   
   logic [7:0] data_addr_o;
   assign data_addr_o = mem_addr_o[31:24];


  processor_core core(
  .clk_i         (sysclk),
  .rst_i         (rst),
  .stall_i       (stall_i),
  .instr_i       (instr_i),
  .mem_rd_i      (mem_rd_i),
  .instr_addr_o  (instr_addr_o),
  .mem_addr_o    (mem_addr_o),
  .mem_size_o    (mem_size_o),
  .mem_req_o     (mem_req_o),
  .mem_we_o      (mem_we_o),
  .mem_wd_o      (mem_wd_o),
  .irq_req_i     (irq_req),
  .irq_ret_o     (irq_ret)
  );


   lsu load_store(
    .clk_i         (sysclk),
    .rst_i         (rst),
    .core_stall_o  (stall_i),
    .core_req_i    (mem_req_o),
    .core_we_i     (mem_we_o),
    .core_size_i   (mem_size_o),
    .core_wd_i     (mem_wd_o),
    .core_addr_i   (mem_addr_o),
    .core_rd_o     (mem_rd_i),
    .mem_rd_i      (read_data_o),
    .mem_ready_i   (ready_o),
    .mem_req_o     (mem_req_i),
    .mem_we_o      (write_enable_i),
    .mem_be_o      (byte_enable_i),
    .mem_addr_o    (addr_i),
    .mem_wd_o      (write_data_i)
  );


  data_mem data_memory (
    .clk_i             (sysclk),
    .write_enable_i    (write_enable_i),
    .mem_req_i         (mem_req_i & (data_addr_o == 8'h0)),
    .byte_enable_i     (byte_enable_i),
    .addr_i            ({8'd0,addr_i[23:0]}),
    .write_data_i      (write_data_i),
    .read_data_o       (read_data_0),
    .ready_o           (ready_o)
  );
  sw_sb_ctrl sw(
  .clk_i          (sysclk),
  .rst_i          (rst),
  .req_i          (mem_req_i & (data_addr_o == 8'h01)),
  .write_enable_i (write_enable_i),
  .addr_i         ({8'd0,addr_i[23:0]}),
  .write_data_i   (write_data_i),
  .read_data_o    (read_data_1),
  .interrupt_request_o (irq_req),
  .interrupt_return_i  (irq_ret),
  .sw_i   (sw_i)
  );

  led_sb_ctrl led(
  .clk_i          (sysclk),
  .rst_i          (rst),
  .req_i          (mem_req_i & (data_addr_o == 8'h02)),
  .write_enable_i (write_enable_i),
  .addr_i         ({8'd0,addr_i[23:0]}),
  .write_data_i   (write_data_i),
  .read_data_o    (read_data_2),
  .led_o          (led_o)
  );

  // ps2_sb_ctrl ps2(
  // .clk_i          (sysclk),
  // .rst_i          (rst),
  // .req_i          (mem_req_i & (data_addr_o == 8'h03)),
  // .write_enable_i (write_enable_i),
  // .addr_i         ({8'd0,addr_i[23:0]}),
  // .write_data_i   (write_data_i),
  // .read_data_o    (read_data_3),
  // .interrupt_request_o (irq_req),
  // .interrupt_return_i  (irq_ret),
  // .kclk_i           (kclk_i),
  // .kdata_i          (kdata_i)
  // );


 instr_mem imem (
    .read_addr_i (instr_addr_o),
    .read_data_o (instr_i)
    );

 always_comb begin
   case(data_addr_o)
     8'h0:  read_data_o = read_data_0;
     8'h01: read_data_o = read_data_1;
     8'h02: read_data_o = read_data_2;
     8'h03: read_data_o = read_data_3;
     default: read_data_o = 32'b0;
   endcase
 end

endmodule