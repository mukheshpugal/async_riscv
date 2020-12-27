`timescale 1ns/1ps

module imem (
    input [31:0] iaddr,
    output [31:0] idata
);
    // Ignores LSB 2 bits, so will not generate alignment exception
    reg [31:0] mem[0:4095]; // Define a 4-K location memory (16KB)
    initial begin $readmemh({`TESTDIR,"/idata.mem"},mem); end

    assign #10 idata = mem[iaddr[31:2]];
endmodule