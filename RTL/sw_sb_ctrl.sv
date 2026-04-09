module sw_sb_ctrl(

  input  logic        clk_i,
  input  logic        rst_i,
  input  logic        req_i,
  input  logic        write_enable_i,
  input  logic [31:0] addr_i,
  input  logic [31:0] write_data_i,  
                                     
  output logic [31:0] read_data_o,

  output logic        interrupt_request_o,
  input  logic        interrupt_return_i,


  input logic [15:0]  sw_i
);
 
  logic is_read_meaning;
  logic write_req;
  logic read_req;
  logic [15:0] sw_i_reg;
  logic [15:0] sw_i_pred;

  assign write_req = req_i & write_enable_i;
  assign read_req  = req_i & ~write_enable_i;
  
  
  always_comb begin
    if ( addr_i == 32'b0 ) begin
      is_read_meaning = 1'b1;
    end else begin 
      is_read_meaning = 1'b0;
    end
  end
  
  always_comb begin
    if ( read_req & is_read_meaning )begin
      read_data_o = {16'd0, sw_i};
    end else begin 
      read_data_o = 32'b0;
    end
  end 
  
  
  
  always_ff @( posedge clk_i or posedge rst_i ) begin
    if (rst_i) begin 
        sw_i_reg <= 16'b0;
        interrupt_request_o <= 1'b0;
        sw_i_pred <=16'b0;
    end else begin
      sw_i_pred <= sw_i_reg;
      sw_i_reg  <= sw_i;
        if ( interrupt_return_i ) begin
            interrupt_request_o <= 1'b0;
        end else if (sw_i_pred != sw_i ) begin
            interrupt_request_o <= 1'b1;
        end
    end
  end
  
  
  
endmodule