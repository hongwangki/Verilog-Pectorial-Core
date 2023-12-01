module BUS(clk, reset_n, m_req, m_wr, m_addr, m_dout, s0_dout, s1_dout, m_grant, m_din, s0_sel, s1_sel, s_addr, s_wr, s_din);
				
	input clk, reset_n, m_req, m_wr;
	input [15:0] m_addr;
	input [63:0] m_dout, s0_dout, s1_dout;
	
	output s0_sel, s1_sel,m_grant;
	output [63:0] m_din;
	output reg s_wr;
	output reg [15:0] s_addr;
	output reg [63:0] s_din;
	reg [1:0] select_reg;
	
	always @(*)
	begin
    {s_addr, s_wr, s_din} <= m_grant ? {m_addr, m_wr, m_dout} : {16'bx, 1'bx, 64'bx};
	end

	always @(posedge clk or negedge reset_n)
	begin
		if(~reset_n) select_reg <=2'b00;
		else select_reg <= {s1_sel,s0_sel};
	end
	
	
	bus_arbit U0_aribt(.clk(clk), .reset_n(reset_n), .m_req(m_req), .m_grant(m_grant));
	bus_addr U1_addr(.s_addr(s_addr), .m_req(m_req), .s0_sel(s0_sel), .s1_sel(s1_sel));
	mx3_64bit u2_mx3(.d0(64'h0), .d1(s0_dout), .d2(s1_dout), .select(select_reg), .result(m_din));
	
endmodule
