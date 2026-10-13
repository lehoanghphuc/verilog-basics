module fifo #(parameter DEPTH = 8, parameter WIDTH = 8) (
    input              clk, rst, wr_en, rd_en,
    input  [WIDTH-1:0] din,
    output reg [WIDTH-1:0] dout,
    output             full, empty
);
    reg [WIDTH-1:0]         mem [0:DEPTH-1];
    reg [$clog2(DEPTH)-1:0] wptr, rptr;
    reg [$clog2(DEPTH):0]   count;

    assign full  = (count == DEPTH);
    assign empty = (count == 0);

    wire do_wr = wr_en && !full;
    wire do_rd = rd_en && !empty;

    always @(posedge clk) begin
        if (rst) begin
            wptr <= 0; rptr <= 0; count <= 0; dout <= 0;
        end else begin
            if (do_wr) begin mem[wptr] <= din;  wptr <= wptr + 1; end
            if (do_rd) begin dout <= mem[rptr]; rptr <= rptr + 1; end
            case ({do_wr, do_rd})
                2'b10:   count <= count + 1;
                2'b01:   count <= count - 1;
                default: count <= count;
            endcase
        end
    end
endmodule