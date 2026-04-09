module ps2_sb_ctrl(
  input  logic         clk_i,
  input  logic         rst_i,
  input  logic [31:0]  addr_i,
  input  logic         req_i,
  input  logic [31:0]  write_data_i,
  input  logic         write_enable_i,
  output logic [31:0]  read_data_o,

  output logic        interrupt_request_o,
  input  logic        interrupt_return_i,
  
  input  logic kclk_i,
  input  logic kdata_i
);

  logic [7:0] scan_code;
  logic       scan_code_is_unread;
  
  logic [7:0] keycode;
  logic keycode_valid;
  logic write_req;
  logic read_req;
  logic is_val;
  logic is_mode;
  logic is_rst;
  
  PS2Receiver PS2(
    .clk_i           (clk_i),
    .rst_i           (rst_i),  
    .kclk_i          (kclk_i),
    .kdata_i         (kdata_i),
    .keycode_o       (keycode),
    .keycode_valid_o (keycode_valid)
  );
  
  assign write_req = req_i & write_enable_i;
  assign read_req  = req_i & ~write_enable_i;
  
  always_comb begin 
    case(addr_i)
      32'h00: begin
        is_val = 1'b1;
        is_mode = 1'b0;
        is_rst = 1'b0;
      end
      32'h04: begin
        is_val = 1'b0;
        is_mode = 1'b1;
        is_rst = 1'b0;
      end
      32'h24: begin
        is_val = 1'b0;
        is_mode = 1'b0;
        is_rst = 1'b1;
      end
      default: begin
        is_val = 1'b0;
        is_mode = 1'b0;
        is_rst = 1'b0;
      end
    endcase
  end
  
  always_comb begin
    read_data_o = 32'b0;
    if (is_val && read_req) begin
      read_data_o = {24'b0, scan_code};
    end else if (is_mode && read_req) begin
      read_data_o = {31'b0, scan_code_is_unread};
    end
  end
  
  always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
      scan_code <= 8'b0;
      scan_code_is_unread <= 1'b0;
    end else begin
     
      if (is_rst & write_req & (write_data_i == 32'b1)) begin
        scan_code <= 8'b0;
        scan_code_is_unread <= 1'b0;
      end else begin
     
        if (keycode_valid) begin
          scan_code <= keycode;
          scan_code_is_unread <= 1'b1;
        end
        
      
        if (is_val && read_req) begin
       
          if (!keycode_valid) begin
            scan_code_is_unread <= 1'b0;
          end
        end
        
       
        if (interrupt_return_i) begin
    
          if (!keycode_valid) begin
            scan_code_is_unread <= 1'b0;
          end
        end
      end
    end
  end
  
  assign interrupt_request_o = scan_code_is_unread;
  
endmodule