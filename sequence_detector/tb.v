module tb;
  reg clk = 0, rst = 1, din = 0;
  wire detected;
  reg [2:0] hist;          // 3 bit gần nhất (đáp án mong đợi)
  integer errors = 0;
  integer checks = 0;

  seq101 dut (.clk(clk), .rst(rst), .din(din), .detected(detected));

  always #5 clk = ~clk;

  // Gửi 1 bit vào DUT rồi tự kiểm tra
  task send_bit(input b);
    reg expected;
    begin
      @(negedge clk) din = b;      // đổi din ở cạnh xuống
      @(posedge clk);              // DUT đọc din ở cạnh lên
      #1;                          // chờ DUT cập nhật xong
      hist = {hist[1:0], b};       // cập nhật 3 bit gần nhất
      expected = (hist == 3'b101);
      checks = checks + 1;
      if (detected !== expected) begin
        errors = errors + 1;
        $display("FAIL t=%0t din=%b expected=%b got=%b", $time, b, expected, detected);
      end
    end
  endtask

  initial begin
    hist = 3'b000;
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
    @(negedge clk) rst = 0;        // thả reset

    // dãy test: 1 0 1 1 0 1 0 1 0 0
    send_bit(1); send_bit(0); send_bit(1); send_bit(1); send_bit(0);
    send_bit(1); send_bit(0); send_bit(1); send_bit(0); send_bit(0);

    if (errors == 0) $display("PASS: %0d checks, 0 errors", checks);
    else             $display("FAIL: %0d errors in %0d checks", errors, checks);
    $finish;
  end
endmodule