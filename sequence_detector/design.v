module seq101 (
  input  clk, rst, din,
  output detected
);
  localparam [1:0] S0 = 2'd0, S1 = 2'd1, S2 = 2'd2, S3 = 2'd3;
  reg [1:0] state, next_state;

  // Khối 1: thanh ghi trạng thái
  always @(posedge clk) begin
    if (rst) state <= S0;
    else     state <= next_state;
  end

  // Khối 2: logic trạng thái kế tiếp
  always @(*) begin
    case (state)
      S0:      next_state = din ? S1 : S0;
      S1:      next_state = din ? S1 : S2;
      S2:      next_state = din ? S3 : S0;
      S3:      next_state = din ? S1 : S2;
      default: next_state = S0;
    endcase
  end

  // Khối 3: ngõ ra
  assign detected = (state == S3);
endmodule