module traffic(
  input logic clk, rst, en,
  output logic [1:0] stage
);
  typedef enum logic [1:0] {RED, GREEN, YELLOW} state_t;
  state_t state;
  
  always_ff @(posedge clk) begin
    if (rst)
      state <= RED;
    else if (en) begin
      if(state == RED)
        state <= GREEN;
      else if (state == GREEN)
        state <= YELLOW;
      else
        state <= RED;
    end
  end
  assign stage = state;
endmodule