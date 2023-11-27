module FactoCore (clk,reset_n,s_sel,s_wr,s_addr,s_din,s_dout,interrupt);

    //////////input///////////	 
	 input clk, reset_n, s_sel, s_wr;
    input [15:0] s_addr;
    input [63:0] s_din;
    ////////output///////////
    output [63:0] s_dout;
	 output interrupt;

    ///////wire/////
    wire opstart, opclear, intrEn, done;
    wire [63:0] operand;
    wire [127:0] result;

    ///////reg///////
    reg clear;
	 reg [1:0] opdone;
	 reg [63:0] OPR; //output operand
    reg [63:0] multiplier, multiplicand;
    reg [63:0] result_h, result_l, RH, RL; //output result
    reg [1:0] state, next_state;
 
	                           
   ////////parameter//////////
   parameter IDLE = 2'b00;
   parameter START= 2'b01;
   parameter PROGRESS = 2'b10;
   parameter END = 2'b11;

   ///////////FactorialController instance////////////////
	FactorialController U0_FactorialController (.clk(clk), .reset_n(reset_n), .s_sel(s_sel),
							 .s_wr(s_wr), .s_addr(s_addr), .s_din(s_din), .OD(opdone),
							 .RH(RH), .RL(RL), .OS(opstart),
							 .OI(intrEn), .OC(opclear), .OPR(operand), .s_dout(s_dout));

	/////////////multiplier instance//////////
	multiplier U1_multiplier (.clk(clk), .reset_n(reset_n), .multiplier(multiplier), .multiplicand(multiplicand), 
										.op_start(opstart), .op_clear(opclear|clear), .op_done(done), .result(result));   

   ///////////state/////////////
   always @(posedge clk, negedge reset_n)
   begin
       if (!reset_n) state  <= IDLE;
       else if(opclear) state <= IDLE;
       else state <= next_state;
   end

   ///////////next state////////////
   always @ (*)
   begin
     //reset==0 or opcler==1 => next state=IDEL
     if (!reset_n || opclear) 
        next_state = IDLE;
        
     else begin
         case (state)
            //opstart==1 => next=Start, 0=> IDEL
            IDLE : next_state = opstart ? START : IDLE;
            //OPR==0 => END, else=>PROGRESS
            START : next_state = (OPR == 64'h0) ? END : PROGRESS;
            //OPR==1=>END, else=>PROGRESS 
            PROGRESS : next_state = (OPR == 64'h1) ? END : PROGRESS;
            END : next_state = END;
               default : next_state = IDLE;
         endcase
       end
   end

   ////////////////os///////////////////
   always @(posedge clk, negedge reset_n)
   begin   
       //reset==0
       if(~reset_n) begin
       multiplier <= 64'h0;
       multiplicand <= 64'h0;
       result_h  <= 64'h0;
       result_l <= 64'h1;
		 RH <= 64'h0;
       RL <= 64'h1;
       OPR <= 64'h0;
       opdone <= 2'b00;
       clear <= 1'b0;
       end
       //opclear==0
       else if(opclear)begin
       multiplier <= 64'h0;
       multiplicand <= 64'h0;
       result_h  <= 64'h0;
       result_l <= 64'h1;
		 RH <= 64'h0;
       RL <= 64'h1;
       OPR <= 64'h0;
       opdone <= 2'b00;
       clear <= 1'b0;
       end
       
       else begin
           case (state)
           
               IDLE : begin
                  //OPR=operand, muliplier=OPR, multiplicand=result_l, opdone=2'b00 <== (1)
                  {OPR, multiplier, multiplicand, opdone} <= {operand, OPR, result_l, 2'b00};
                  end
               
               START : opdone <= 2'b10;
               
               PROGRESS : begin
                if (done) begin
                  //(1) proceeding in a way
                  {clear, result_h, result_l, OPR} <= {1'b1, result[127:64], result[63:0], OPR - 1};
                end 
            
               else begin
                  //(1) proceeding in a way
                  {clear, multiplier, multiplicand} <= {1'b0, OPR, (result_l == 64'h0) ? result_h : result_l};
                  end
               end
            
              END : begin
                  //(1) proceeding in a way
                  {RH, RL, opdone} <= {result_h, result_l, 2'b11};
               end
               
            default : ;
          endcase
       end
end

///////////assign////////////
   //assign interrupt
   assign interrupt = intrEn & opdone[0];
endmodule
