module led_sb_ctrl(

  input  logic        clk_i,
  input  logic        rst_i,
  input  logic        req_i,
  input  logic        write_enable_i,
  input  logic [31:0] addr_i,
  input  logic [31:0] write_data_i,
  output logic [31:0] read_data_o,

  output logic [15:0] led_o
);

logic [15:0]  led_val;
logic         led_mode;
logic write_req;
logic read_req;
logic rst;
logic is_val_addr;
logic is_mode_addr;
logic is_rst_addr;
logic val_en;
logic mode_en;

always_comb begin 
    case(addr_i)
      32'h00: begin
        is_val_addr = 1'b1;
        is_mode_addr = 1'b0;
        is_rst_addr = 1'b0;
      end
      32'h04: begin
        is_val_addr = 1'b0;
        is_mode_addr = 1'b1;
        is_rst_addr = 1'b0;
      end
      32'h24: begin
        is_val_addr = 1'b0;
        is_mode_addr = 1'b0;
        is_rst_addr = 1'b1;
      end
      default: begin
        is_val_addr = 1'b0;
        is_mode_addr = 1'b0;
        is_rst_addr = 1'b0;
      end
    endcase
  end


  assign write_req = req_i & write_enable_i;
  assign read_req  = req_i & ~write_enable_i;
  assign rst       = (is_rst_addr & write_req & (write_data_i == 32'b1)) | rst_i;
  assign val_en    = write_req & is_val_addr;
  assign mode_en   = write_req & is_mode_addr;
  
  always_ff @(posedge clk_i or posedge rst) begin
    if ( rst ) begin
      led_val <= 16'b0;
    end else if (val_en) begin
      led_val <= write_data_i[15:0];
    end
  end
  
  always_ff @(posedge clk_i or posedge rst) begin
    if ( rst ) begin
      led_mode <= 1'b0;
    end else if ( mode_en ) begin
      led_mode <= write_data_i[0];
    end 
  end
  
  logic [31:0] cnt_my_ff;
  
  always_ff @( posedge clk_i or posedge rst ) begin
    if ( rst | (cnt_my_ff >= 32'd20_000_000) | (!led_mode) )
      cnt_my_ff <= 32'd0;
    else if (led_mode)
      cnt_my_ff <= cnt_my_ff + 32'd1;
  end
  
  always_comb begin
    if ( cnt_my_ff < 32'd10_000_000) begin
      led_o = led_val;
    end else begin
      led_o = 16'd0;
    end
  end
  
  logic [31:0] rd_o;
  logic        en;
  
  assign rd_o = is_val_addr ? {16'd0, led_val} : {31'd0, led_mode};
  assign en   = (is_val_addr | is_mode_addr) & read_req; 
  
  always_ff @(posedge clk_i or posedge rst) begin
    if ( rst ) begin
      read_data_o <= 32'b0;
    end else if (en) begin
      read_data_o <= rd_o;
    end 
  end
  
  

endmodule