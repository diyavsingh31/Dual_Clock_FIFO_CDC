`timescale 1ns/1ps

module RW #(
    parameter PTR_WIDTH = 5
)(
    input                       clk,
    input                       rst,
    input  [PTR_WIDTH-1:0]      gray_in,
    output [PTR_WIDTH-1:0]      gray_out
);
reg [PTR_WIDTH-1:0] sync_ff1;
reg [PTR_WIDTH-1:0] sync_ff2;
always @(posedge clk or posedge rst)
    begin
        if(rst)
        begin
            sync_ff1 <= {PTR_WIDTH{1'b0}};
            sync_ff2 <= {PTR_WIDTH{1'b0}};
        end
        else
        begin
            sync_ff1 <= gray_in;
            sync_ff2 <= sync_ff1;
        end
    end
assign gray_out = sync_ff2;
endmodule
