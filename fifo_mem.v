`timescale 1ns/1ps
module fifo_mem #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)(
    input                       a_clk,
    input                       a_en,
    input  [ADDR_WIDTH-1:0]     a_addr,
    input  [DATA_WIDTH-1:0]     a_in,
    input                       b_clk,
    input                       b_en,
    input  [ADDR_WIDTH-1:0]     b_addr,
    output reg [DATA_WIDTH-1:0] b_out
);
localparam DEPTH = (1 << ADDR_WIDTH);
reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
always @(posedge a_clk)
begin
    if(a_en)
        mem[a_addr] <= a_in;
end
always @(posedge b_clk)
begin
    if(b_en)
        b_out <= mem[b_addr];
end
endmodule
