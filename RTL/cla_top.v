module gen_prop_unit(
    input clk,
    input [15:0] a, b,
    //output reg [15:0] g, p
    output  [15:0] g, p
);
    assign g = a & b;  // bitwise generator
    assign p = a ^ b;  // bitwise propagator

endmodule

    // always @(posedge clk) begin
    //     g <= a & b;  // bitwise generator
    //     p <= a ^ b;  // bitwise propagator
    // end
/*
if you want to make gen_prop_unit a clocked unit,
uncomment the g and p in the always block, your layered testbench
will receive the sum one posedge clock later from the DUT.
Thus mismatch will happen.clk

Here, I have removed the clocking from the gen_prop_unit,
kept the clocking in only the summation_unit. It works.
Also made sure lineart testbench is working in the negedge.
And Summation Unit is working in the posedge instead of negedge as before.

Note that, for sampling, monitor and drivers are also working in the
negedge actually.

*/



module base4_carry_unit(
    input      [3:0] g,  // Generate signals
    input      [3:0] p,  // Propagate signals
    input            cin, // Carry-in
    output     [4:1] cout // Carry-out vector
);

    // assign cout [1] = g[0] | (p[0] & cin);
    // assign cout [2] = g[1] | (p[1] & (g[0] | (p[0] & cin)));
    // assign cout [3] = g[2] | (p[2] & (g[1] | (p[1] & (g[0] | (p[0] & cin)))));
    // assign cout[4] = (g[3] | ( p[3] & g[2] ) | ( p[3] & p[2] & g[1] ) |
    // ( p[3] & p[2] & p[1] & g[0] )) | ((p[3] & p[2] & p[1] & p[0]) & cin);

    assign cout [1] = g[0] | (p[0] & cin);
    assign cout [2] = g[1] | (p[1] & cout[1]);
    assign cout [3] = g[2] | (p[2] & cout[2]);
    assign cout [4] = g[3] | (p[3] & cout[3]);

endmodule


module summation_unit (
    input      [15:0] p,          // Input vector p
    input             cin,        // Carry-in signal
    input      [16:1] cout,       // Carry-out vector for each bit (except for the first bit)
    input             clk,        // Clock signal
    output reg [15:0] sum,        // Output sum vector
    output            carry_out16
);
    integer i;
    //reg [7:0] sum_op;
    always @(posedge clk) begin  //changed to posedge for driver and monitor
        sum[0] <= p[0] ^ cin;  // First bit sum using carry-in

        for (i = 1; i < 16; i = i + 1) begin
            sum[i] <= p[i] ^ cout[i];  // Remaining bits sum using cout[i]
        end
    end
    assign carry_out16 = cout[16];

endmodule



// 16 bit top module
module cla_top (
    input      [15:0] a, b,      // 16-bit input operands
    input             cin,       // Carry-in input
    input             clk,       // Clock signal
    output reg [15:0] sum,       // 16-bit output sum
    output            carry_out16
);

    // Internal wires to connect modules
    wire [15:0] g, p;                           // Generate and Propagate signals for 16 bits
    wire [4:1] cout1, cout2, cout3, cout4;      // Carry-out for 4-bit sections
    wire       cout_mid1, cout_mid2, cout_mid3; // Carry between the 4-bit sections
    // wire       signed_carry_out;                // Final carry out for signed overflow detection
    // wire       signed_overflow;                 // To detect overflow in signed addition

    // Instantiate the generate and propagate unit for 16 bits
    gen_prop_unit gen_prop_inst (
        .a(a),
        .b(b),
        .g(g),
        .p(p)
    );

    // Instantiate the base4 carry unit for the lower 4 bits (a[3:0], b[3:0])
    base4_carry_unit carry_unit1 (
        .g(g[3:0]),
        .p(p[3:0]),
        .cin(cin),             // The initial carry-in
        .cout(cout1)           // Carry out for lower 4 bits
    );

    // Carry-out from the first unit (cout1[4]) becomes the carry-in for the second unit
    assign cout_mid1 = cout1[4];

    // Instantiate the base4 carry unit for the next 4 bits (a[7:4], b[7:4])
    base4_carry_unit carry_unit2 (
        .g(g[7:4]),
        .p(p[7:4]),
        .cin(cout_mid1),        // Carry-out from the first unit as carry-in
        .cout(cout2)            // Carry out for bits [7:4]
    );

    // Carry-out from the second unit (cout2[4]) becomes the carry-in for the third unit
    assign cout_mid2 = cout2[4];

    // Instantiate the base4 carry unit for the next 4 bits (a[11:8], b[11:8])
    base4_carry_unit carry_unit3 (
        .g(g[11:8]),
        .p(p[11:8]),
        .cin(cout_mid2),        // Carry-out from the second unit as carry-in
        .cout(cout3)            // Carry out for bits [11:8]
    );

    // Carry-out from the third unit (cout3[4]) becomes the carry-in for the fourth unit
    assign cout_mid3 = cout3[4];

    // Instantiate the base4 carry unit for the upper 4 bits (a[15:12], b[15:12])
    base4_carry_unit carry_unit4 (
        .g(g[15:12]),
        .p(p[15:12]),
        .cin(cout_mid3),        // Carry-out from the third unit as carry-in
        .cout(cout4)            // Carry out for bits [15:12]
    );

    // Instantiate the summation unit to calculate the final 16-bit sum
    summation_unit sum_unit (
        .p(p),                 // Propagate signal from the gen_prop_unit
        .cin(cin),             // Carry-in
        .cout({cout4[4:1], cout3[4:1], cout2[4:1], cout1[4:1]}),  // Carry-out bits from all carry units
        .clk(clk),
        .sum(sum),              // Output sum
        .carry_out16(carry_out16)
    );

endmodule
