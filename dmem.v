`timescale 1ns/1ps
`define DMEM_N_FILE(x,y) {x,y,".mem"}
`define MEMTOP 4095

module dmem (
    input clk,
    input [31:0] daddr,
    input [31:0] dwdata,
    input [3:0] dwe,
    output [31:0] drdata
);
    // 4K location, 16KB total, split in 4 banks
    reg [7:0] mem0[0:`MEMTOP];
    reg [7:0] mem1[0:`MEMTOP];
    reg [7:0] mem2[0:`MEMTOP];
    reg [7:0] mem3[0:`MEMTOP];

    wire [29:0] a;
    integer i;

    assign a = daddr[31:2];
    
    // Selecting bytes to be done inside CPU
    assign #15 drdata = { mem3[a], mem2[a], mem1[a], mem0[a]};  

    always @(posedge clk) begin
        if (dwe[3]) mem3[a] = dwdata[31:24];
        if (dwe[2]) mem2[a] = dwdata[23:16];
        if (dwe[1]) mem1[a] = dwdata[15: 8];
        if (dwe[0]) mem0[a] = dwdata[ 7: 0];
    end

endmodule
