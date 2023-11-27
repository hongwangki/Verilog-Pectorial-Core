module ram (clk,cen,wen,s_addr,s_din,s_dout);
  ////////input//////////
  input clk, cen, wen;
  input [7:0] s_addr;
	input [63:0] s_din;
  /////////output//////////
  output reg [63:0] s_dout;

	//63 bit memory 255 save
	reg [63:0] memory [0:255];

	integer i;
	initial begin
	//memory initialization
	for(i=0; i<64; i=i+1)begin
	memory[i]<=64'd0;
	end
	end
	
	always @(posedge clk)
	begin
			//cen && wen ==1 case
		 if((cen==1'b1) && (wen==1'b1)) begin
			  memory[s_addr] <= s_din;
			  s_dout <= 64'h0;
		 end
			//cen =1 && wen ==0 case
		 else if((cen==1'b1) && (wen==1'b0)) begin
			  s_dout <= memory[s_addr];
		 end
			//cen =0 case
		 else if(cen==1'b0) begin
		 s_dout <= 64'd0;
		 end
	end
endmodule
