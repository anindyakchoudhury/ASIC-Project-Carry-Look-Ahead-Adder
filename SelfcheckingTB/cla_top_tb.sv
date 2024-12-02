module cla_top_tb;

    // Test inputs
    logic [15:0] a, b;   // 8-bit input operands
    logic       cin;          // Carry-in input
    logic       clk;          // Clock signal
    logic [15:0] sum;   // Output sum
    logic       carry_out16;

    // Instantiate the cla_top module
    cla_top dut (
        .a(a),
        .b(b),
        .cin(cin),
        .clk(clk),
        .sum(sum),
        .carry_out16(carry_out16)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Toggle clock every 5 time units
    end

    // Test sequence
    initial begin
        // Display header
        $display("--------------- CLA Testbench Results ---------------");
        $display("Time\t a (Binary)\t             b (Binary)\t       cin\t sum (Binary)\t sum (Decimal)\t carry_out\t");

        // Test Case 1: a = 10, b = 12, cin = 0
        @(negedge clk);  //$display("Time is %t", $time);
        a = 8'b00001010; // 10
        b = 8'b00001100; // 12
        cin = 0;
        #10; // Wait for one clock cycle
        check_output(a+b+cin); // Expected sum = 10 + 12 = 22

        // Test Case 2: a = 15, b = 1, cin = 0
        @(negedge clk);  //$display("Time is %t", $time);
        a = 8'b00001111; // 15
        b = 8'b00000001; // 1
        cin = 0;
        #10;
        check_output(a+b+cin); // Expected sum = 15 + 1 = 16

        // Test Case 3: a = 255, b = 1, cin = 0
        @(negedge clk);
        a = 8'b11111111; // 255
        b = 8'b00000001; // 1
        cin = 0;
        #10;
        check_output(a+b+cin); // Expected sum = 255 + 1 = 256 (wraps to 0)

        // Test Case 4: a = 100, b = 55, cin = 1
        @(negedge clk);
        a = 8'b01100100; // 100
        b = 8'b00110111; // 55
        cin = 1;
        #10;
        check_output(a+b+cin); // Expected sum = 100 + 55 + 1 = 156

        // Test Case 5: a = 200, b = 100, cin = 1
        @(negedge clk);
        a = 60300; // 200
        b = 8'b01100100; // 100
        cin = 1;
        #10;
        check_output(a+b+cin); // Expected sum = 200 + 100 + 1 = 301 (wraps to 45)
        // Finish the simulation after all test cases
        #10;
        $finish;
    end

    // Task to check output
    task check_output(input [16:0] expected_sum);
        // Display current results
        $display("%0t\t %b\t %b\t %b\t %b\t %0d\t          %b\t       ", $time, a, b, cin, sum, sum, carry_out16);

        // Compare actual and expected output
        if ((sum !== expected_sum[15:0]) | (carry_out16 !== expected_sum[16])) begin
            $display("\033[1;31mFAIL: Expected sum = %b, got sum = %b\033[0m", expected_sum[15:0], sum);
            $display("\033[1;31m---------------------------------------------------------\033[0m");
        end else begin
            $display("\033[1;32mPASS: sum = %b\033[0m", sum);
            $display("\033[1;32m---------------------------------------------------------\033[0m");
        end
    endtask

endmodule




