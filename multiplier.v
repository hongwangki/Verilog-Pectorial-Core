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
   reg [1:0]over;

   
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
      if(!reset_n)begin
      R_result  <= 129'b0;
      end
      //State-based result definition
      else begin
         //opclear=1 case
         if (op_clear) begin
         R_result  <= 129'b0;
         end
         else begin
           case (state)
             //OPSTART State Output
             OPSTART:begin
               R_result <= { 64'b0, multiplier, 1'b0 }; //129but r_result
               over<=2'b00;
               end
             
             //Shift State Output
             SHIFT:
                  // Consider shift value according to over
                  casex(over)
                    2'b0x: begin
                            R_result <= { R_result[128], R_result[128:1] }; //shift
                            over<=2'b00;
                          end
                    2'b10: begin
                            R_result <= { 1'b0, R_result[128:1] };
                            over<=2'b00;
                          end
                    2'b11: begin
                            R_result <= { 1'b1, R_result[128:1] };
                            over<=2'b00;
                          end
                    endcase
             
             //ADD State Output
             ADD: begin 
                //result[0]==0 connect SumSub, R_result[64:0],
                //result[0]!=0 connect SumAdd, R_result[64:0]

                    R_result <= (R_result[0] == 1'b0) ? {SumSub, R_result[64:0]} : {SumAdd, R_result[64:0]};

                //Sub case                        (-)       -    (+)          =        (+)
                if ((R_result[0] == 1'b0 && R_result[128] && ~R_multiplicand[63] && ~SumSub[63]) ||
                 //Add case                       (-)   +      (-)            =   (+)
                  (R_result[0] != 1'b0 && R_result[128] && R_multiplicand[63] && ~SumAdd[63]))
                  over<=2'b11;

                //Sub case                         (+)          -      (-)          =    (-)
                else if((R_result[0] == 1'b0 && ~R_result[128] && R_multiplicand[63] && SumSub[63]) || 
                //Add case                      (+)       +            (+)          =    (-)
                     (R_result[0] != 1'b0 && ~R_result[128] && ~R_multiplicand[63] && SumAdd[63]))
                     over<=2'b10;
                else
                    //not case
                     over<=2'b00;
            end
            //default   
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
    if (!reset_n) {R_multiplier, R_multiplicand} <= 128'b0;
    
	 else begin
		  //opclear==1 case
        if (op_clear) {R_multiplier, R_multiplicand} <= 128'b0;

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