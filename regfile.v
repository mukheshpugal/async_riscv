module regfile(
    input [4:0] rs1,     // address of first operand to read - 5 bits
    input [4:0] rs2,     // address of second operand
    input [4:0] rd,      // address of value to write
    input we,            // should write update occur
    input [31:0] wdata,  // value to be written
    output [31:0] rv1,   // First read value
    output [31:0] rv2,   // Second read value
    input clk            // Clock signal - all changes at clock posedge
);
    // Initializing memory block
    reg [31:0] mem [31:0];
    integer i;

    initial begin
        for (i = 0; i < 32; i++) begin
            mem[i] = 0;
        end
    end

    // rv1, rv2 are combinational outputs - they will update whenever rs1, rs2 change
    assign rv1 = mem[rs1];
    assign rv2 = mem[rs2];

    // on clock edge, if we=1, regfile entry for rd will be updated
    always @(posedge clk) begin
        if (we)
            mem[rd] <= wdata;
        /////////////////////////////// MIGHT FAIL WHILE SYNTHRSIZING ///////////////////////////
        mem[0] <= 0;
    end

endmodule