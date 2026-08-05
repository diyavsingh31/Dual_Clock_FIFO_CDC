`timescale 1ns/1ps

module FIFO_CDC #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)(
    input                       a_clk,
    input                       a_rst,
    input                       a_en,
    input  [DATA_WIDTH-1:0]     a_in,
    output                      full,
    input                       b_clk,
    input                       b_rst,
    input                       b_en,
    output [DATA_WIDTH-1:0]     b_out,
    output                      empty
);

localparam PTR_WIDTH = ADDR_WIDTH + 1;

wire [PTR_WIDTH-1:0] a_bin;
wire [PTR_WIDTH-1:0] b_bin;
wire [PTR_WIDTH-1:0] a_gray;
wire [PTR_WIDTH-1:0] b_gray;
wire [PTR_WIDTH-1:0] a_gray_sync;
wire [PTR_WIDTH-1:0] b_gray_sync;
wire [ADDR_WIDTH-1:0] a_addr;
wire [ADDR_WIDTH-1:0] b_addr;

fifo_mem #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH)
) u_mem (
    .a_clk(a_clk),
    .a_en(a_en & ~full),
    .a_addr(a_addr),
    .a_in(a_in),
    .b_clk(b_clk),
    .b_en(b_en && !empty),
    .b_addr(b_addr),
    .b_out(b_out)
);

a_ptr #(
    .ADDR_WIDTH(ADDR_WIDTH)
) u_a_ptr (
    .a_clk(a_clk),
    .a_rst(a_rst),
    .a_en(a_en),
    .b_gray_sync(b_gray_sync),
    .a_bin(a_bin),
    .a_gray(a_gray),
    .a_addr(a_addr),
    .full(full)
);

b_ptr #(
    .ADDR_WIDTH(ADDR_WIDTH)
) u_b_ptr (
    .b_clk(b_clk),
    .b_rst(b_rst),
    .b_en(b_en),
    .a_gray_sync(a_gray_sync),
    .b_bin(b_bin),
    .b_gray(b_gray),
    .b_addr(b_addr),
    .empty(empty)
);

RW #(
    .PTR_WIDTH(PTR_WIDTH)
) u_sync_r2w (
    .clk(a_clk),
    .rst(a_rst),
    .gray_in(b_gray),
    .gray_out(b_gray_sync)
);

WR #(
    .PTR_WIDTH(PTR_WIDTH)
) u_sync_w2r (
    .clk(b_clk),
    .rst(b_rst),
    .gray_in(a_gray),
    .gray_out(a_gray_sync)
);

endmodule
