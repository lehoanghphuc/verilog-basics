module tb;
    reg clk = 0, rst = 1, wr_en = 0, rd_en = 0;
    reg [7:0] din = 0;
    wire [7:0] dout;
    wire full, empty;

    fifo #(.DEPTH(8), .WIDTH(8)) dut (
        .clk(clk), .rst(rst), .wr_en(wr_en), .rd_en(rd_en),
        .din(din), .dout(dout), .full(full), .empty(empty)
    );

    always #5 clk = ~clk;

    // ---------- scoreboard: a reference list of what was written ----------
    reg [7:0] exp_mem [0:1023];
    integer wr_idx = 0, rd_idx = 0, checks = 0, errors = 0;
    integer seed;
    reg [7:0] exp_dout;
    reg pending = 0;

    always @(posedge clk) begin
        if (rst) begin
            wr_idx <= 0; rd_idx <= 0; pending <= 0;
        end else begin
            pending <= 0;
            if (rd_en && (wr_idx - rd_idx) > 0) begin
                exp_dout <= exp_mem[rd_idx];
                rd_idx   <= rd_idx + 1;
                pending  <= 1;
            end
            if (wr_en && (wr_idx - rd_idx) < 8) begin
                exp_mem[wr_idx] <= din;
                wr_idx <= wr_idx + 1;
            end
        end
    end

    // ---------- checker: compare design with the scoreboard ----------
    always @(negedge clk) begin
        if (!rst) begin
            checks = checks + 1;
            if (full !== ((wr_idx - rd_idx) == 8) || empty !== ((wr_idx - rd_idx) == 0)) begin
                errors = errors + 1;
                $display("FAIL t=%0t: full=%b empty=%b, model count=%0d", $time, full, empty, wr_idx - rd_idx);
            end
            if (pending) begin
                checks = checks + 1;
                if (dout !== exp_dout) begin
                    errors = errors + 1;
                    $display("FAIL t=%0t: dout=%h expected=%h", $time, dout, exp_dout);
                end
            end
        end
    end

    // ---------- stimulus helpers ----------
    task push(input [7:0] d);
        begin
            @(negedge clk); wr_en = 1; din = d;
            @(negedge clk); wr_en = 0;
        end
    endtask

    task pop;
        begin
            @(negedge clk); rd_en = 1;
            @(negedge clk); rd_en = 0;
        end
    endtask

    task push_pop(input [7:0] d);
        begin
            @(negedge clk); wr_en = 1; rd_en = 1; din = d;
            @(negedge clk); wr_en = 0; rd_en = 0;
        end
    endtask

    task random_cycle;
        reg [31:0] random_value;
        begin
            @(negedge clk); #1;
            random_value = $urandom(seed);
            wr_en = random_value[0];
            rd_en = random_value[1];
            din = random_value[15:8];
            @(posedge clk); #1;
            wr_en = 0;
            rd_en = 0;
        end
    endtask

    integer i;
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb);
        seed = 32'h1badf00d;
        repeat (2) @(negedge clk);
        rst = 0;

        pop;                                            // test 1: read from empty (ignored)
        for (i = 0; i < 9; i = i + 1) push(8'h10 + i);  // test 2: fill to full, 9th write ignored
        for (i = 0; i < 9; i = i + 1) pop;              // test 3: drain in order, 9th read ignored
        for (i = 0; i < 5; i = i + 1) push(8'hA0 + i);  // test 4: pointer wrap-around
        for (i = 0; i < 5; i = i + 1) pop;
        for (i = 0; i < 8; i = i + 1) push(8'hB0 + i);
        for (i = 0; i < 8; i = i + 1) pop;
        push(8'hC1); push(8'hC2);                       // test 5: simultaneous read and write
        push_pop(8'hC3);
        pop; pop;

        for (i = 0; i < 500; i = i + 1) random_cycle;

        repeat (2) @(negedge clk);
        if (errors == 0) $display("PASS: %0d checks, 0 errors", checks);
        else             $display("FAIL: %0d errors in %0d checks", errors, checks);
        $finish;
    end
endmodule