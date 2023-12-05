module bus_arbit (clk,reset_n,m_req,m_grant);
   
	//input
   input clk,reset_n,m_req;
	//output reg
   output reg m_grant;


	// Declare FSM state register
	reg state, next_state;

	always @(posedge clk or negedge reset_n)
	begin
	 // Synchronous reset condition: executed on the falling edge of reset_n
	  if (~reset_n)
		 state <= 0;
	  else
		 state <= next_state;
	end

	
	//ns logic
	always @(m_req,state)
	begin 
	  // If m1_reg is 0 and m0_reg is 1
	  if (m_req===0) next_state = 0;
	  // If m1_reg is 1 and m0_reg is 0
	  else if (m_req==1) next_state = 1;
	   // If m1_reg is 0 and m0_reg is 0
	  else
		 next_state = state;
	end

// Output logic
	always @(posedge clk or negedge reset_n)
	begin
		//grant set case
	  if (~reset_n)
		 m_grant <= 0;
	  else begin
			if (state == 1'b0)
				 m_grant <= 0;
			else if (state == 1'b1)
				 m_grant <= 1;
			else
				 m_grant <= 1'bx;
			end	 				 
	end
endmodule