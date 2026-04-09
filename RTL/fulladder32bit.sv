module fulladder32bit(
    input  logic [31:0] A,        
    input  logic [31:0] B,        
    input  logic        CARRY_I, 
    output logic [31:0] SUM_O,   
    output logic        CARRY_O
);
   
    logic [31:0] carry_in;
    logic [31:0] carry_out;

    assign carry_in[0] = CARRY_I;

    assign carry_in[31:1] = carry_out[30:0];

    assign CARRY_O = carry_out[31];

    sum_lab_wan instance_array[31:0] (
        .a_i     (A),
        .b_i     (B),
        .carry_i (carry_in),
        .sum_o   (SUM_O),
        .carry_o (carry_out)
    );

endmodule
