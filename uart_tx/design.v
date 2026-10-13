module uart_tx #(
    parameter CLKS_PER_BIT = 16
) (
    input       clk,
    input       rst,
    input       start,
    input [7:0] data_in,
    output reg  tx,
    output      busy
);
    localparam IDLE  = 2'd0;
    localparam START = 2'd1;
    localparam DATA  = 2'd2;
    localparam STOP  = 2'd3;
    localparam BAUD_COUNT_WIDTH = (CLKS_PER_BIT > 1) ? $clog2(CLKS_PER_BIT) : 1;

    reg [1:0] state;
    reg [BAUD_COUNT_WIDTH-1:0] baud_count;
    reg [2:0] bit_index;
    reg [7:0] shift_reg;

    assign busy = (state != IDLE);

    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            baud_count <= 0;
            bit_index <= 0;
            shift_reg <= 0;
            tx <= 1'b1;
        end else begin
            case (state)
                IDLE: begin
                    tx <= 1'b1;
                    baud_count <= 0;
                    if (start) begin
                        shift_reg <= data_in;
                        bit_index <= 0;
                        tx <= 1'b0;
                        state <= START;
                    end
                end
                START: begin
                    if (baud_count == CLKS_PER_BIT - 1) begin
                        baud_count <= 0;
                        tx <= shift_reg[0];
                        state <= DATA;
                    end else begin
                        baud_count <= baud_count + 1'b1;
                    end
                end
                DATA: begin
                    if (baud_count == CLKS_PER_BIT - 1) begin
                        baud_count <= 0;
                        if (bit_index == 3'd7) begin
                            tx <= 1'b1;
                            state <= STOP;
                        end else begin
                            shift_reg <= {1'b0, shift_reg[7:1]};
                            bit_index <= bit_index + 1'b1;
                            tx <= shift_reg[1];
                        end
                    end else begin
                        baud_count <= baud_count + 1'b1;
                    end
                end
                STOP: begin
                    if (baud_count == CLKS_PER_BIT - 1) begin
                        baud_count <= 0;
                        state <= IDLE;
                    end else begin
                        baud_count <= baud_count + 1'b1;
                    end
                end
                default: begin
                    state <= IDLE;
                    baud_count <= 0;
                    tx <= 1'b1;
                end
            endcase
        end
    end
endmodule
