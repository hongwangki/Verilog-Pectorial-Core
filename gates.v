//make inverter
module _inv(
    input a,
    output y
    );
    assign y=~a;
endmodule

//make 2input or gate
module _or2(a,b,y);
input a,b;
output y;
assign y=a|b;
endmodule


//make 2 intput and gate
module _and2(a,b,y);
input a,b;
output y;
assign y=a&b;
endmodule

////make 2input xor gate
module _xor2(a,b,y);
input a, b;
output y;
wire inv_a, inv_b;
wire w0, w1;
_inv U0_inv(.a(a), .y(inv_a));
_inv U1_inv(.a(b), .y(inv_b));
_and2 U2_and2(.a(inv_a), .b(b), .y(w0));
_and2 U3_and2(.a(a),.b(inv_b), .y(w1));
_or2 U4_or2(.a(w0), .b(w1),.y(y));
endmodule

//make 3input and gate
module _and3(a,b,c,y);
input a,b,c;
output y;
assign y=a&b&c;
endmodule

//manke 4input and gate
module _and4(a,b,c,d,y);
input a,b,c,d;
output y;
assign y=a&b&c&d;
endmodule

//make 5input and gate
module _and5(a,b,c,d,e,y);
input a,b,c,d,e;
output y;
assign y=a&b&c&d&e;
endmodule

//make 3input or gate
module _or3(a,b,c,y);
input a,b,c;
output y;
assign y=a|b|c;
endmodule

//make 4input or gate
module _or4(a,b,c,d,y);
input a,b,c,d;
output y;
assign y=a|b|c|d;
endmodule

//make 5input or gate
module _or5(a,b,c,d,e,y);
input a,b,c,d,e;
output y;
assign y=a|b|c|d|e;
endmodule
