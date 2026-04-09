module interrupt_controller(
  input  logic        clk_i,
  input  logic        rst_i,
  input  logic        exception_i,
  input  logic        irq_req_i,
  input  logic        mie_i,
  input  logic        mret_i,

  output logic        irq_ret_o,
  output logic [31:0] irq_cause_o,
  output logic        irq_o
);



  logic        set_esc_h;
  logic        exc_h;
  logic        exc_d;
  logic        mret_set_esc_h;
  logic        irq_d;
  logic        irq_h;
  logic        iqr_io;


  always_ff @(posedge clk_i or posedge rst_i) begin
    if ( rst_i ) begin
      exc_h <= 1'b0;
    end else begin
      exc_h <= exc_d;
    end
  end

  always_ff @(posedge clk_i or posedge rst_i) begin
    if ( rst_i ) begin
      irq_h <= 1'b0;
    end else begin
      irq_h <= irq_d;
    end
  end


  assign set_esc_h       =  exception_i | exc_h;
  assign exc_d           =  ~mret_i & set_esc_h;
  assign mret_set_esc_h  =  ~set_esc_h & mret_i;
  assign irq_ret_o       =  mret_set_esc_h;
  assign irq_d           =  (~mret_set_esc_h & (irq_h | iqr_io));
  assign irq_o           =  ( irq_req_i & mie_i ) & ~( set_esc_h | irq_h );
  assign iqr_io          =  irq_o;
  assign irq_cause_o     =  32'h8000_0010;

endmodule