`timescale 1ps/1ps

module FIFO_CDC_tb;

parameter DATA_WIDTH = 8;
parameter ADDR_WIDTH = 4;
localparam FIFO_DEPTH = (1<<ADDR_WIDTH);

reg a_clk;
reg b_clk;

reg a_rst;
reg b_rst;

reg a_en;
reg b_en;

reg [DATA_WIDTH-1:0] a_in;

wire [DATA_WIDTH-1:0] b_out;
wire full;
wire empty;

integer i;

FIFO_CDC #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH)
) DUT (
    .a_clk(a_clk),
    .a_rst(a_rst),
    .a_en(a_en),
    .a_in(a_in),
    .full(full),
    .b_clk(b_clk),
    .b_rst(b_rst),
    .b_en(b_en),
    .b_out(b_out),
    .empty(empty)
);

initial
begin
    a_clk = 0;
    forever #50 a_clk = ~a_clk;
end

initial
begin
    b_clk = 0;
    forever #70 b_clk = ~b_clk;
end

task reset_fifo;
begin
    a_rst = 1;
    b_rst = 1;

    a_en = 0;
    b_en = 0;
    a_in = 0;

    repeat(4) @(posedge a_clk);

    a_rst = 0;
    b_rst = 0;

    repeat(4) @(posedge a_clk);
    repeat(4) @(posedge b_clk);
end
endtask

task write_data(input [DATA_WIDTH-1:0] data);
begin
    @(posedge a_clk);

    if(!full)
    begin
        a_en = 1;
        a_in = data;
    end

    @(posedge a_clk);
    a_en = 0;

    $display("[%0t] WRITE  Data = %h  Full = %b",
              $time,data,full);
end
endtask

task read_data;
begin
    @(posedge b_clk);

    if(!empty)
        b_en = 1;

    @(posedge b_clk);

    b_en = 0;

    $display("[%0t] READ   Data = %h  Empty = %b",
              $time,b_out,empty);
end
endtask
initial
begin

    $display("\n========== RESET TEST ==========");
    reset_fifo();

    $display("\n========== SINGLE WRITE ==========");
    write_data(8'h11);

    repeat(3) @(posedge b_clk);

    $display("\n========== SINGLE READ ==========");
    read_data();

    repeat(3) @(posedge b_clk);

    $display("\n========== MULTIPLE WRITE ==========");

    for(i=0;i<8;i=i+1)
        write_data(i+1);

    repeat(4) @(posedge b_clk);

    $display("\n========== MULTIPLE READ ==========");

    for(i=0;i<8;i=i+1)
        read_data();

    repeat(4) @(posedge b_clk);

    $display("\n========== FULL CONDITION ==========");

    reset_fifo();

    for(i=0;i<FIFO_DEPTH;i=i+1)
        write_data(i);

    repeat(4) @(posedge a_clk);

    $display("FULL = %b",full);

    $display("\n========== OVERFLOW ATTEMPT ==========");

    write_data(8'hFF);

    repeat(4) @(posedge a_clk);

    $display("FULL = %b",full);

    $display("\n========== EMPTY CONDITION ==========");

    reset_fifo();

    for(i=0;i<8;i=i+1)
        write_data(i+8'h20);

    repeat(4) @(posedge b_clk);

    for(i=0;i<8;i=i+1)
        read_data();

    repeat(4) @(posedge b_clk);

    $display("EMPTY = %b",empty);

    $display("\n========== UNDERFLOW ATTEMPT ==========");

    read_data();

    repeat(4) @(posedge b_clk);

    $display("EMPTY = %b",empty);

    $display("\n========== SIMULTANEOUS READ/WRITE ==========");

    reset_fifo();

    fork

    begin
        for(i=0;i<20;i=i+1)
        begin
            write_data(i+8'hA0);
            @(posedge a_clk);
        end
    end

    begin
        repeat(5) @(posedge b_clk);

        for(i=0;i<20;i=i+1)
        begin
            read_data();
            @(posedge b_clk);
        end
    end

    join

    repeat(10) @(posedge b_clk);

    $display("\n========== SIMULATION COMPLETE ==========");

    $finish;

end

endmodule
