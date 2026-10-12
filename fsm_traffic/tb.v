module tb;
  logic clk, rst, en;
  logic [1:0] stage;
  
  traffic dut (
    .clk(clk),
    .rst(rst),
    .en(en),
    .stage(stage)
  );
  initial clk = 0;
  always #5 clk = ~clk;
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
    rst = 1; en = 0; #12;
    if (stage !== 2'd0) $display ("FAIL t=%0t: stage=%0d, can 0", $time, stage);
    else                $display ("PASS t=%0t: stage=%0d, can 0", $time, stage);
    rst = 0; en = 1; #40;
    if (stage !== 2'd1) $display ("FAIL t=%0t: stage=%0d, can 1", $time, stage);
    else                $display ("PASS t=%0t: stage=%0d, can 1", $time, stage);
    en = 0; #30;
    if (stage !== 2'd1) $display ("FAIL t=%0t: stage=%0d, can 1", $time, stage);
    else                $display ("PASS t=%0t: stage=%0d, can 1", $time, stage);
    en = 1; #40;
    if (stage !== 2'd2) $display ("FAIL t=%0t: stage=%0d, can 2", $time, stage);
    else                $display ("PASS t=%0t: stage=%0d, can 2", $time, stage);
    
    $finish;
  end 
endmodule
