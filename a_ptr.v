module a_ptr #(
    parameter ADDR_WIDTH = 4
)(
    input                      a_clk,
    input                      a_rst,
    input                      a_en,
    input  [ADDR_WIDTH:0]      b_gray_sync,

    output reg [ADDR_WIDTH:0]  a_bin,
    output reg [ADDR_WIDTH:0]  a_gray,
    output [ADDR_WIDTH-1:0]    a_addr,
    output reg                 full
);

localparam PTR_WIDTH = ADDR_WIDTH + 1;

wire [PTR_WIDTH-1:0] a_bin_next;
wire [PTR_WIDTH-1:0] a_gray_next;
wire [PTR_WIDTH-1:0] b_gray_full;
wire full_next;

assign a_addr = a_bin[ADDR_WIDTH-1:0];

assign a_bin_next  = a_bin + ((a_en && !full) ? 1'b1 : 1'b0);
assign a_gray_next = (a_bin_next >> 1) ^ a_bin_next;

assign b_gray_full = {
    ~b_gray_sync[PTR_WIDTH-1],
    ~b_gray_sync[PTR_WIDTH-2],
     b_gray_sync[PTR_WIDTH-3:0]
};

assign full_next = (a_gray_next == b_gray_full);

always @(posedge a_clk or posedge a_rst)
begin
    if(a_rst)
    begin
        a_bin  <= 0;
        a_gray <= 0;
        full   <= 1'b0;
    end
    else
    begin
        a_bin  <= a_bin_next;
        a_gray <= a_gray_next;
        full   <= full_next;
    end
end

endmodule