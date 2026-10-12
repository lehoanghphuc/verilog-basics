module tb;
    reg clk, rst, en;
    wire [3:0] count;

    counter dut (.clk(clk), .rst(rst), .en(en), .count(count));

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb);

        rst = 1; en = 0; #12;     // t = 0..12   : reset
        // KIỂM TRA 1 (t = 12)
        if (count !== 4'd0) $display("FAIL t=%0t: count=%d, can 0", $time, count);
        else                  $display("PASS t=%0t: count=%d", $time, count);
        rst = 0; en = 1; #50;     // t = 12..62  : đếm
        // KIỂM TRA 2 (t = 62)
        if (count !== 4'd5) $display("FAIL t=%0t: count=%d, can 5", $time, count);
        else                  $display("PASS t=%0t: count=%d", $time, count);
        en = 0;          #30;     // t = 62..92  : dừng
        // KIỂM TRA 3 (t = 92)
        if (count !== 4'd5) $display("FAIL t=%0t: count=%d, can 5", $time, count);
        else                  $display("PASS t=%0t: count=%d", $time, count);
        en = 1;          #108;    // t = 92..200 : đếm tiếp, đủ lâu để quay vòng
        // KIỂM TRA 4 (t = 200)
        if (count !== 4'd0) $display("FAIL t=%0t: count=%d, can 0", $time, count);
        else                  $display("PASS t=%0t: count=%d", $time, count);
        $finish;
    end
endmodule