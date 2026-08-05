module b_ptr #(
    parameter ADDR_WIDTH = 4
)(
    input                      b_clk,
    input                      b_rst,
    input                      b_en,
    input  [ADDR_WIDTH:0]      a_gray_sync,

    output reg [ADDR_WIDTH:0]  b_bin,
    output reg [ADDR_WIDTH:0]  b_gray,
    output [ADDR_WIDTH-1:0]    b_addr,
    output reg                 empty
);

localparam PTR_WIDTH = ADDR_WIDTH + 1;

wire [PTR_WIDTH-1:0] b_bin_next;
wire [PTR_WIDTH-1:0] b_gray_next;
wire empty_next;

assign b_addr = b_bin[ADDR_WIDTH-1:0];

assign b_bin_next  = b_bin + ((b_en && !empty) ? 1'b1 : 1'b0);
assign b_gray_next = (b_bin_next >> 1) ^ b_bin_next;

assign empty_next = (b_gray_next == a_gray_sync);

always @(posedge b_clk or posedge b_rst)
begin
    if(b_rst)
    begin
        b_bin  <= 0;
        b_gray <= 0;
        empty  <= 1'b1;
    end
    else
    begin
        b_bin  <= b_bin_next;
        b_gray <= b_gray_next;
        empty  <= empty_next;
    end
end

endmodule