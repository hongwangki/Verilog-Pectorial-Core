module cla4(
 
  input [3:0]   a,   // 4-bit inputs a
  input [3:0]   b,   // 4-bit inputs b
  input         ci,  // Carry-in input
  output [3:0]  s,   // 4-bit sum output
  output        co   // Carry-out output
    );
     // Carry outputs from each full adder
     wire [3:0] c;       
    // Full Adder Instances
    // Full Adder for LSB (Least Significant Bit)
    fa_v2 U0_fa_v2(a[0], b[0], ci, s[0]);  
    // Full Adder for bit 1
    fa_v2 U1_fa_v2(a[1], b[1], c[0], s[1]);  
    // Full Adder for bit 2
    fa_v2 U2_fa_v2(a[2], b[2], c[1], s[2]);  
    // Full Adder for MSB (Most Significant Bit)
    fa_v2 U3_fa_v2(a[3], b[3], c[2], s[3]);      
    // Carry Look-Ahead Block (CLB) for generating carry-out
    clb4 U4_clb4(a, b, ci, c[0], c[1], c[2], co);
endmodule
