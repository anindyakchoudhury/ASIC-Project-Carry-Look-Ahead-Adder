// SystemVerilog module for generate and propagate unit
module gen_prop_unit (
    input  logic [15:0] a, b,
    output logic [15:0] g, p  // Changed to logic type
);
    assign g = a & b;  // bitwise generator
    assign p = a ^ b;  // bitwise propagator

endmodule

/*
Module behavior notes remain the same as in Verilog:
if you want to make gen_prop_unit a clocked unit,
uncomment the g and p in the always block, your layered testbench
will receive the sum one posedge clock later from the DUT.
Thus mismatch will happen.

Here, clocking is removed from the gen_prop_unit,
kept only in the summation_unit. It works.
Also made sure linear testbench is working in the negedge.
And Summation Unit is working in the posedge instead of negedge as before.

Note that, for sampling, monitor and drivers are also working in the
negedge actually.
*/

// SystemVerilog module for base4 carry unit
module base4_carry_unit (
    input  logic [3:0] g,     // Generate signals
    input  logic [3:0] p,     // Propagate signals
    input  logic       cin,   // Carry-in
    output logic [4:1] cout   // Carry-out vector
);
    // Simplified carry chain implementation
    assign cout[1] = g[0] | (p[0] & cin);
    assign cout[2] = g[1] | (p[1] & cout[1]);
    assign cout[3] = g[2] | (p[2] & cout[2]);
    assign cout[4] = g[3] | (p[3] & cout[3]);

endmodule

// SystemVerilog module for summation unit
module summation_unit (
    input  logic        clk,         // Clock signal
    input  logic [15:0] p,          // Input vector p
    input  logic        cin,        // Carry-in signal
    input  logic [16:1] cout,       // Carry-out vector
    output logic [15:0] sum,        // Output sum vector
    output logic        carry_out16  // Changed to logic type
);
    always_ff @(posedge clk) begin  // Using always_ff for sequential logic
        sum[0] <= p[0] ^ cin;  // First bit sum using carry-in
        
        for (int i = 1; i < 16; i++) begin  // Using int type for loop counter
            sum[i] <= p[i] ^ cout[i];  // Remaining bits sum using cout[i]
        end
    end
    
    assign carry_out16 = cout[16];

endmodule

// SystemVerilog top module for 16-bit CLA
module cla_top_sv (
    input  logic        clk,        // Clock signal
    input  logic [15:0] a, b,       // 16-bit input operands
    input  logic        cin,        // Carry-in input
    output logic [15:0] sum,        // 16-bit output sum
    output logic        carry_out16  // Carry-out signal
);
    // Internal signals declared as logic
    logic [15:0] g, p;                           // Generate and Propagate signals
    logic [4:1]  cout1, cout2, cout3, cout4;     // Carry-out for 4-bit sections
    logic        cout_mid1, cout_mid2, cout_mid3; // Inter-section carries

    // Instantiate the generate and propagate unit
    gen_prop_unit gen_prop_inst (
        .a   (a),
        .b   (b),
        .g   (g),
        .p   (p)
    );

    // Instantiate carry units for each 4-bit section
    base4_carry_unit carry_unit1 (
        .g    (g[3:0]),
        .p    (p[3:0]),
        .cin  (cin),
        .cout (cout1)
    );

    assign cout_mid1 = cout1[4];

    base4_carry_unit carry_unit2 (
        .g    (g[7:4]),
        .p    (p[7:4]),
        .cin  (cout_mid1),
        .cout (cout2)
    );

    assign cout_mid2 = cout2[4];

    base4_carry_unit carry_unit3 (
        .g    (g[11:8]),
        .p    (p[11:8]),
        .cin  (cout_mid2),
        .cout (cout3)
    );

    assign cout_mid3 = cout3[4];

    base4_carry_unit carry_unit4 (
        .g    (g[15:12]),
        .p    (p[15:12]),
        .cin  (cout_mid3),
        .cout (cout4)
    );

    // Instantiate the summation unit
    summation_unit sum_unit (
        .clk         (clk),
        .p           (p),
        .cin         (cin),
        .cout        ({cout4[4:1], cout3[4:1], cout2[4:1], cout1[4:1]}),
        .sum         (sum),
        .carry_out16 (carry_out16)
    );

endmodule