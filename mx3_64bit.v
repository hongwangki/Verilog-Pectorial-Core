module mx3_64bit (
  input [63:0] d0,
  input [63:0] d1,
  input [63:0] d2,
  input [1:0]  select,
  output reg [63:0] result
);
	// Case statement based on the 'select' input
	always @ (select, d0 ,d1 , d2)
	begin
	  case (select)
		 2'b00: result <= d0;
		 2'b01: result <= d1;
		 2'b10: result <= d2;
		 2'b11: result <= 64'b0; // Undefined for select value 2'b11
		 default: result <= 64'hzzzzzzzz; // Default undefined case
	  endcase
	end

endmodule
