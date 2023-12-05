module clb4(
    input [3:0] a,
    input [3:0] b,
    input       ci,
    output      c1,
    output      c2,
    output      c3,
    output      co
 
    );
   wire [3:0] g,p;
   wire w0_c1;
   wire w0_c2, w1_c2;
   wire w0_c3, w1_c3, w2_c3;
   wire w0_co, w1_co, w2_co, w3_co;
   //Generate
   _and2 a0(a[0],b[0],g[0]);
   _and2 a1(a[1],b[1],g[1]);
   _and2 a2(a[2],b[2],g[2]);
   _and2 a3(a[3],b[3],g[3]);
   //Propogate
   _or2 o0(a[0],b[0],p[0]);
   _or2 o1(a[1],b[1],p[1]);
   _or2 o2(a[2],b[2],p[2]);
   _or2 o3(a[3],b[3],p[3]);
   // c1 = g[0] | (p[0] & ci);
   _and2 c1_a0(p[0],ci,w0_c1);
   _or2 c1_o0(g[0],w0_c1, c1);
   // c2 = g[1] | (p[1]&g[0]) | (p[1]&p[0]&ci);
   _and2 c2_a2(p[1],g[0],w0_c2);
   _and3 c2_a3(p[1],p[0],ci, w1_c2);
   _or3 c2_o3(g[1], w0_c2, w1_c2, c2);
   // c3 = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0]) | (p[2] & p[1] & p[0] & ci);
   _and2 c3_a2(p[2],g[1],w0_c3);
   _and3 c3_a3(p[2],p[1],g[0], w1_c3);
   _and4 c3_a4(p[2],p[1],p[0],ci,w2_c3);
   _or4 c3_o4(g[2],w0_c3, w1_c3, w2_c3, c3);
   //     co = g[3]
   // | (p[3] & g[2])
   // | (p[3] & p[2] & g[1])
   // | (p[3] & p[2] & p[1] & g[0])
   // | (p[3] & p[2] & p[1] & p[0] & ci)
   _and2 co_a2(p[3],g[2],w0_co);
   _and3 co_a3(p[3],p[2],g[1], w1_co);
   _and4 co_a4(p[3],p[2],p[1],g[0],w2_co);
   _and5 co_a5(p[3],p[2],p[1],p[0],ci,w3_co);
   _or5 co_o5(g[3],w0_co,w1_co,w2_co,w3_co,co);
endmodule
