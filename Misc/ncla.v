module gen_prop_unit(
    input [15:0] a, b,
    output [15:0] g, p
);
    assign g = a & b;  // Bitwise generate
    assign p = a ^ b;  // Bitwise propagate
endmodule


module base2_carry_unit(
    input [1:0] g,  // Generate signals for 2 bits
    input [1:0] p,  // Propagate signals for 2 bits
    input        cin, // Carry-in
    output [2:1] cout // Carry-out vector
);

    assign cout[1] = g[0] | (p[0] & cin);
    assign cout[2] = g[1] | (p[1] & cout[1]);

endmodule

module base4_carry_unit(
    input [3:0] g,  // Generate signals for 4 bits
    input [3:0] p,  // Propagate signals for 4 bits
    input        cin, // Carry-in
    output [4:1] cout // Carry-out vector
);

    assign cout[1] = g[0] | (p[0] & cin);
    assign cout[2] = g[1] | (p[1] & cout[1]);
    assign cout[3] = g[2] | (p[2] & cout[2]);
    assign cout[4] = g[3] | (p[3] & cout[3]);

endmodule

module base8_carry_unit(
    input [7:0] g,  // Generate signals for 8 bits
    input [7:0] p,  // Propagate signals for 8 bits
    input        cin, // Carry-in
    output [8:1] cout // Carry-out vector
);

    assign cout[1] = g[0] | (p[0] & cin);
    assign cout[2] = g[1] | (p[1] & cout[1]);
    assign cout[3] = g[2] | (p[2] & cout[2]);
    assign cout[4] = g[3] | (p[3] & cout[3]);
    assign cout[5] = g[4] | (p[4] & cout[4]);
    assign cout[6] = g[5] | (p[5] & cout[5]);
    assign cout[7] = g[6] | (p[6] & cout[6]);
    assign cout[8] = g[7] | (p[7] & cout[7]);

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
    always @(posedge clk) begin
        sum[0] <= p[0] ^ cin;  // First bit sum using carry-in

        for (i = 1; i < 16; i = i + 1) begin
            sum[i] <= p[i] ^ cout[i];  // Remaining bits sum using cout[i]
        end
    end
    assign carry_out16 = cout[16];

endmodule


module ncla_alu_top (
    input      [15:0] a, b,      // 16-bit input operands
    input             cin,       // Carry-in input
    input             clk,       // Clock signal
    output reg [15:0] sum,       // 16-bit output sum
    output            carry_out16
);

    // Internal wires to connect modules
    wire [15:0] g, p;                           // Generate and Propagate signals for 16 bits
    wire [2:1] cout1;                           // Carry-out for the first 2 bits
    wire [2:1] cout2;                           // Carry-out for the next 2 bits
    wire [4:1] cout3;                           // Carry-out for the 4-bit section
    wire [8:1] cout4;                           // Carry-out for the 8-bit section
    wire       cout_mid1, cout_mid2, cout_mid3; // Carry between sections

    // Instantiate the generate and propagate unit for 16 bits
    gen_prop_unit gen_prop_inst (
        .a(a),
        .b(b),
        .g(g),
        .p(p)
    );

    // Instantiate the base2 carry unit for the first 2 bits
    base2_carry_unit carry_unit1 (
        .g(g[1:0]),
        .p(p[1:0]),
        .cin(cin),              // Initial carry-in
        .cout(cout1)            // Carry-out for first 2 bits
    );

    // Carry-out from the first unit (cout1[2]) becomes the carry-in for the second unit
    assign cout_mid1 = cout1[2];

    // Instantiate the second base2 carry unit for the next 2 bits
    base2_carry_unit carry_unit2 (
        .g(g[3:2]),
        .p(p[3:2]),
        .cin(cout_mid1),        // Carry-out from first unit as carry-in
        .cout(cout2)            // Carry-out for next 2 bits
    );

    // Carry-out from the second unit (cout2[2]) becomes the carry-in for the third unit
    assign cout_mid2 = cout2[2];

    // Instantiate the base4 carry unit for the next 4 bits
    base4_carry_unit carry_unit3 (
        .g(g[7:4]),
        .p(p[7:4]),
        .cin(cout_mid2),        // Carry-out from the second unit as carry-in
        .cout(cout3)            // Carry-out for 4-bit section
    );

    // Carry-out from the third unit (cout3[4]) becomes the carry-in for the fourth unit
    assign cout_mid3 = cout3[4];

    // Instantiate the base8 carry unit for the upper 8 bits
    base8_carry_unit carry_unit4 (
        .g(g[15:8]),
        .p(p[15:8]),
        .cin(cout_mid3),        // Carry-out from the third unit as carry-in
        .cout(cout4)            // Carry-out for 8-bit section
    );

    // Instantiate the summation unit to calculate the final 16-bit sum
    summation_unit sum_unit (
        .p(p),                 // Propagate signal from the gen_prop_unit
        .cin(cin),             // Carry-in
        .cout({cout4[8:1], cout3[4:1], cout2[2:1], cout1[2:1]}),  // Carry-out bits from all carry units
        .clk(clk),
        .sum(sum),              // Output sum
        .carry_out16(carry_out16)
    );

endmodule
