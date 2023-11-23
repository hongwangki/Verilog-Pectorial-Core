module  multiplier(
    input clk, reset_n,
    input [63:0] multiplier, multiplicand,
    input op_start, op_clear,
    output op_done,
    output [127:0] result
);
	//state define
	parameter IDLE = 3'b000;
	parameter OP_START = 3'b001;
	parameter JUDGE = 3'b010;
	parameter ADD = 3'b011;
	parameter SHIFT = 3'b100;
	parameter DONE = 3'b101;
	
	//reg type
	reg [2:0] state, next;
	reg [63:0] counter;
	 
	reg [63:0]  REG_multiplier;
	reg [63:0]  REG_multiplicand;
	reg [128:0] REG_result;
	 
	//wire type 
	wire [63:0] w_add, w_sub;
	wire        w_add_cout, w_sub_cout;
	wire [63:0] w_counter_sub;
	wire        w_counter_cout;
	
	//Reaction whenever reset and clk change
	always @(posedge clk, negedge reset_n)
	begin
		 if(!reset_n) state <= IDLE;
		 else begin
			if(op_clear) state <= IDLE;//op_clear==1 => state= IDEL
			else state  <= next;
		 end
	end
////////////next state///////////////
	always @(*)
	begin
		case(state) 
			  //IDLE Next State Condition
			  IDLE : begin
				if(reset_n && op_start && !op_clear) next = OP_START;
			     else next = IDLE;
				end
			  //OP_START Next State Condition
			  OP_START : next = JUDGE;
			  //JUDGE Next State Condition
			  JUDGE : begin 
				if(REG_result[1]^REG_result[0]) next = ADD;
				else next = SHIFT;
				end
			  //ADD Next State Condition
			  ADD :  next = SHIFT;
			  //SHIFT Next State Condition
			  SHIFT    : begin
				f(counter == 64'b1) next = DONE;
				else next = JUDGE;
				end
			  //DONE Next State Condition			 
			  DONE : next = IDLE;
		endcase 
	end
 
	//////////////os result//////////////// 
	always @(posedge clk, negedge reset_n)
	begin
		if(!reset_n) REG_result  <= 129'b0;
		//State-based result definition
		else begin
			if(op_clear) REG_result  <= 129'b0;
			//64b'0 connect 64b multiplier connect 1'b0 =129b result
			else if(state == OP_START) REG_result  <= { 64'b0,  multiplier, 1'b0 };
			//1bit right shift 
			else if(state == SHIFT) REG_result  <= {REG_result[128], REG_result[128:1] }; 
			// sub cla result[128:65] connect REG reuslt [64:0]
			else if(state == ADD && (REG_result[0]==1'b0)) REG_result  <= {w_sub, REG_result[64:0]};
			//ADD cla result[128:65] connect REG reuslt [64:0] 
			else if(state == ADD && (REG_result[0]==1'b1)) REG_result  <= {w_add, REG_result[64:0]};
			else REG_result <= REG_result;
		end
	end
 
	//////////// multiplier ///////////////
	always @(posedge clk, negedge reset_n)
	begin
		if(!reset_n) REG_multiplier <= 64'b0;
		else begin
			if(op_clear) REG_multiplier  <= 64'b0; //multiplier clear
			else if(state == OP_START) REG_multiplier  <= multiplier;
			else REG_multiplier  <= REG_multiplier;
		end
	end

	/////////// multiplicand ////////////
	always @(posedge clk, negedge reset_n)
	begin
		if(!reset_n) REG_multiplicand  <= 64'b0;
		else begin
			if(op_clear) REG_multiplicand  <= 64'b0; //multiplicand clear
			else if(state == OP_START) REG_multiplicand  <= multiplicand;
			else REG_multiplicand  <= REG_multiplicand;
		end
	end
 
	//counter 
	always @(posedge clk, negedge reset_n)
	begin
		 if(!reset_n) counter <= 64'h8000_0000_0000_0000;
		 else begin
			if(op_clear) counter <= 64'h8000_0000_0000_0000;
			else if(state == SHIFT) counter <= {1'b0, counter[63:1]};
			else counter <= counter;
		 end
	end
	
	//assign
	assign result  = REG_result[128:1];
	assign op_done = (state == DONE);

	//cla instance
	cla64 sub( .a(REG_result[128:65]), .b(~REG_multiplicand), .ci(1'b1), .s(w_sub), .co(w_sub_cout));
	 
	cla64 add( .a(REG_result[128:65]), .b(REG_multiplicand), .ci(1'b0), .s(w_add), .co(w_add_cout));
 
endmodule
