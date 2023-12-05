module fa_v2(
    input a,    // Inputs a
    input b,    // Inputs b
    input ci,   // Inputs carry-in (ci)
    output s    // Sum output (s)
    );
     // Intermediate wire for the first XOR gate
     wire w0;          

     // XOR gate instances
     _xor2 U0_xor2(a, b, w0);
     _xor2 U1_xor2(w0, ci, s);
endmodule
