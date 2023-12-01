module bus_addr(s_addr, m_req, s0_sel, s1_sel);
	input m_req;
	input [15:0] s_addr;
	output reg s0_sel, s1_sel;
	
	always @(*)
	begin
		 if (m_req) begin
			  if (s_addr >= 16'h0000 && s_addr <= 16'h07FF) begin
					s0_sel = 1'b1;
					s1_sel = 1'b0;
			  end
			  else if (s_addr >= 16'h7000 && s_addr <= 16'h71FF) begin
					s0_sel = 1'b0;
					s1_sel = 1'b1;
			  end
			  else begin
					s0_sel = 1'b0;
					s1_sel = 1'b0;
			  end
		 end
		 else begin
			  s0_sel = 1'b0;
			  s1_sel = 1'b0;
		 end
	end

endmodule
