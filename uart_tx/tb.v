`timescale 1ns/1ps

module tb;
    localparam CLKS_PER_BIT = 4;

    reg clk = 0;
    reg rst = 1;
    reg start = 0;
    reg [7:0] data_in = 0;
    wire tx;
    wire busy;
    integer checks = 0;
    integer errors = 0;

    uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .data_in(data_in),
        .tx(tx),
        .busy(busy)
    );

    always #5 clk = ~clk;

    task send_and_check(input [7:0] value);
        integer frame_bit;
        reg expected_bit;
        begin
            @(negedge clk);
            data_in = value;
            start = 1;
            @(posedge clk);
            #1 start = 0;

            for (frame_bit = 0; frame_bit < 10; frame_bit = frame_bit + 1) begin
                repeat (CLKS_PER_BIT / 2) @(posedge clk);
                #1;
                if (frame_bit == 0)
                    expected_bit = 1'b0;
                else if (frame_bit < 9)
                    expected_bit = value[frame_bit - 1];
                else
                    expected_bit = 1'b1;

                checks = checks + 1;
                if (tx !== expected_bit) begin
                    errors = errors + 1;
                    $display("FAIL data=%h frame_bit=%0d tx=%b expected=%b",
                             value, frame_bit, tx, expected_bit);
                end
                checks = checks + 1;
                if (busy !== 1'b1) begin
                    errors = errors + 1;
                    $display("FAIL data=%h frame_bit=%0d busy=%b expected=1",
                             value, frame_bit, busy);
                end

                repeat (CLKS_PER_BIT - CLKS_PER_BIT / 2) @(posedge clk);
                #1;
            end

            checks = checks + 1;
            if (tx !== 1'b1) begin
                errors = errors + 1;
                $display("FAIL data=%h idle tx=%b expected=1", value, tx);
            end
            checks = checks + 1;
            if (busy !== 1'b0) begin
                errors = errors + 1;
                $display("FAIL data=%h idle busy=%b expected=0", value, busy);
            end
        end
    endtask

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb);

        repeat (2) @(posedge clk);
        #1;
        checks = checks + 1;
        if (tx !== 1'b1 || busy !== 1'b0) begin
            errors = errors + 1;
            $display("FAIL reset state: tx=%b busy=%b expected tx=1 busy=0", tx, busy);
        end
        rst = 0;

        send_and_check(8'h00);
        send_and_check(8'hA5);
        send_and_check(8'hFF);

        if (errors == 0)
            $display("PASS: %0d checks, 0 errors", checks);
        else
            $display("FAIL: %0d errors in %0d checks", errors, checks);
        $finish;
    end
endmodule
