module  multiplier(clk,reset_n,multiplier,multiplicand,op_start,op_clear,op_done,result);
    
    //////input///////
    input clk, reset_n;
	 input op_start, op_clear;
    input [63:0] multiplier, multiplicand;
    //////output//////
    output op_done;
    output [127:0] result;

   /////////parameter///////
   parameter IDLE = 3'b000;
   parameter OPSTART = 3'b001;
   parameter JUDGE = 3'b010;
   parameter ADD = 3'b011;
   parameter SHIFT = 3'b100;
   parameter DONE = 3'b101;
   
   ///////wire type ////////
	wire C_add, C_sub;
   wire [63:0] SumAdd, SumSub;
	
	/////////reg type///////
   reg [2:0] state, next;
   reg [63:0]  R_multiplier, R_multiplicand, counter;
   reg [128:0] R_result;
    
   /*
   wire [63:0] w_counter_sub;
   wire        w_counter_cout;
	*/
   
   ///////Reaction whenever reset and clk change///////
   always @(posedge clk, negedge reset_n)
   begin
       if(!reset_n) state <= IDLE;
       else state <= (!op_clear) ? next : IDLE;
   end
////////////next state///////////////
	 always @(*) begin
		 case (state)
			  //IDLE Next State Condition
			  IDLE:   next = (reset_n && op_start && !op_clear) ? OPSTART : IDLE;
			  //OP_START Next State Condition
			  OPSTART:  next = JUDGE;
			  //JUDGE Next State Condition
			  JUDGE:  next = (R_result[1] ^ R_result[0]) ? ADD : SHIFT;
			  //ADD Next State Condition
			  ADD:    next = SHIFT;
			  //SHIFT Next State Condition
			  SHIFT:  next = (counter == 64'b1) ? DONE : JUDGE;
			  //DONE Next State Condition 
			  DONE:   next = IDLE;
		 endcase
	end
 
 
   //////////////os result//////////////// 
   always @(posedge clk, negedge reset_n)
   begin
      if(!reset_n) R_result  <= 129'b0;
      //State-based result definition
      else begin
			//opclear=1 case
			if (op_clear) R_result <= 129'b0;
		   else begin
			  case (state)
			    //OPSTART State Output
				 OPSTART: R_result <= { 64'b0, multiplier, 1'b0 }; //129but r_result
				 //Shift State Output
				 SHIFT: R_result <= { R_result[128], R_result[128:1] }; //shift
				 
				 //ADD State Output
				 //result[0]==0 connect SumSub, R_result[64:0],
				 //result[0]!=0 connect SumAdd, R_result[64:0]
				 ADD: R_result <= (R_result[0] == 1'b0) ? {SumSub, R_result[64:0]} : {SumAdd, R_result[64:0]};

				 default: R_result <= R_result;
				endcase
			 end
		end
   end

	
   /////////////counter /////////////
   always @(posedge clk, negedge reset_n)
   begin
       if(!reset_n) counter <= 64'h8000_0000_0000_0000;
       else begin
         if(op_clear) counter <= 64'h8000_0000_0000_0000;
         else  counter <= (state == SHIFT) ? {1'b0, counter[63:1]} : counter;
       end
   end
	
	
 ////////multplier, multiplicand copy////////////
   always @(posedge clk, negedge reset_n) begin
    if (!reset_n) {R_multiplier, R_multiplicand} <= 64'b0;
    
	 else begin
		  //opclear==1 case
        if (op_clear) {R_multiplier, R_multiplicand} <= 64'b0;

		  //opstart==1case
        else if (state == OPSTART) {R_multiplier, R_multiplicand} <= {multiplier, multiplicand};
        
		  //else case
		  else  {R_multiplier, R_multiplicand} <= {R_multiplier, R_multiplicand};
     end
	end

   

   //////////cla instance///////////
   cla64 sub( .a(R_result[128:65]), .b(~R_multiplicand), .ci(1'b1), .s(SumSub), .co(C_sub));
    
   cla64 add( .a(R_result[128:65]), .b(R_multiplicand), .ci(1'b0), .s(SumAdd), .co(C_add));
	
	
	////////////assign//////////////
   assign result  = R_result[128:1];
   assign op_done = (state == DONE);
 
endmodule

  
module _inv(
    input a,
    output y
    );
    assign y=~a;
endmodule
 
module _and2(
 
    input a,
    input b,
    output y
 
    );
    assign y=a&b;
endmodule

 
module _and3(
    input a,
    input b,
    input c,
    output y
    );
    assign y=a&b&c;
endmodule
 
module _and4(
    input a,
    input b,
    input c,
    input d,
    output y
    );
    assign y=a&b&c&d;
endmodule

module _and5(
    input a,
    input b,
    input c,
    input d,
    input e,
    output y
    );
    assign y=a&b&c&d&e;
endmodule

module _or2(
 
    input a,
    input b,
    output y
    );
    assign y=a|b;
endmodule

module _or3(
    input a,
    input b,
    input c,
    output y
    );
    assign y=a|b|c;
endmodule

module _or4(
    input a,
    input b,
    input c,
    input d,
    output y
    );
    assign y=a|b|c|d;
endmodule

module _or5(
    input a,
    input b,
    input c,
    input d,
    input e,
    output y
    );
    assign y=a|b|c|d|e;
endmodule 

module _xor2(
    input a,
    input b,
    output y
    );
    wire inv_a, inv_b;
    wire w0, w1;
    _inv U0_inv(.a(a), .y(inv_a));
    _inv U1_inv(.a(b), .y(inv_b));
    _and2 U2_and2(.a(inv_a), .b(b), .y(w0));
    _and2 U3_and2(.a(a),.b(inv_b), .y(w1));
    _or2 U4_or2(.a(w0), .b(w1),.y(y));
endmodule

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

module cla32(
 
    input [31:0]    a,      // 32-bit input a
    input [31:0]    b,      // 32-bit input b
    input           ci,     // Carry input
   output [31:0]    s,     // 32-bit output s
   output           co     // Carry output
 
    );
    // Wires to connect intermediate carry outputs
    wire c1, c2, c3, c4, c5, c6, c7;  
    //make cla32bit
    cla4 U0_cla4(.a(a[3:0]), .b(b[3:0]), .ci(ci), .s(s[3:0]), .co(c1));
    cla4 U1_cla4(.a(a[7:4]), .b(b[7:4]), .ci(c1), .s(s[7:4]), .co(c2));
    cla4 U2_cla4(.a(a[11:8]), .b(b[11:8]), .ci(c2), .s(s[11:8]), .co(c3));
    cla4 U3_cla4(.a(a[15:12]), .b(b[15:12]), .ci(c3), .s(s[15:12]), .co(c4));
    cla4 U4_cla4(.a(a[19:16]), .b(b[19:16]), .ci(c4), .s(s[19:16]), .co(c5));
    cla4 U5_cla4(.a(a[23:20]), .b(b[23:20]), .ci(c5), .s(s[23:20]), .co(c6));
    cla4 U6_cla4(.a(a[27:24]), .b(b[27:24]), .ci(c6), .s(s[27:24]), .co(c7));
    cla4 U7_cla4(.a(a[31:28]), .b(b[31:28]), .ci(c7), .s(s[31:28]), .co(co));
endmodule

module cla64(
 
    input [63:0]    a,      // 64-bit input a
    input [63:0]    b,      // 64-bit input b
    input           ci,     // Carry input
    output [63:0]   s,      // 64-bit output s
    output          co      // Carry output
    );
    wire co1;
    // Instantiate the first 32-bit CLA32 module for bits 0-31
    cla32 U0_cla32(.a(a[31:0]), .b(b[31:0]), .ci(ci), .s(s[31:0]), .co(co1));
    // Instantiate the second 32-bit CLA32 module for bits 32-63
    cla32 U1_cla32(.a(a[63:32]), .b(b[63:32]), .ci(co1), .s(s[63:32]), .co(co));
endmodule
