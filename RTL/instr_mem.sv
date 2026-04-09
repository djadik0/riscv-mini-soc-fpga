module instr_mem
import memory_pkg::INSTR_MEM_SIZE_BYTES;
import memory_pkg::INSTR_MEM_SIZE_WORDS;

(
    input logic [31:0] read_addr_i,
    output logic [31:0] read_data_o
);

    logic [31:0] imem [0:INSTR_MEM_SIZE_BYTES-1];

    initial begin
        $readmemh("init.mem", imem);
    end

    assign read_data_o = imem[read_addr_i[$clog2(INSTR_MEM_SIZE_BYTES)-1:2]];

endmodule
