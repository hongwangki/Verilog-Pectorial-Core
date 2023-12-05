`timescale 1ns/100ps
module tb_Top;
	 //reg type
    reg clk, reset_n, m_wr, m_req,Intr_En;
    reg [15:0] m_addr;
    reg [63:0] m_dout;
    reg [63:0] opdone, result_h, result_l;
    //wire type
	 wire [63:0] m_din;
    wire m_grant, interrupt;

	 //top module instance
	 Top U0_Top( .clk(clk), .reset_n(reset_n), .m_req(m_req), .m_wr(m_wr), .m_addr(m_addr),
         .m_dout(m_dout), .m_grant(m_grant), .m_din(m_din), .interrupt(interrupt) );

	//clk 5 set
	always
	begin
		 #5 clk = ~clk;
	end



initial
begin
	 #0
    clk = 1'b0;
    reset_n = 1'b0;
    m_req = 1'b0;
    m_wr = 1'b0;
    m_addr = 16'h0;
    m_dout = 64'd0;
    Intr_En = 1'b0;
    opdone = 64'd0;
    result_h = 64'd0;
    result_l = 64'd0;
	 
	 //reset set
    #30
    reset_n = 1'b1;
	 
	 //oeprand
	 #100
    m_req = 1'b1;
    m_wr = 1'b1;
	 m_dout = 64'd20;
    m_addr = 16'h7020;
	 
	 //intrEn
	 #100
    m_addr = 16'h7018;
    m_dout = 64'd1;
    
	 //opstart
	 #100
    m_addr = 16'h7000;
	 
	 //opdone
	 #100
	 m_addr = 16'h7010;
	 m_wr = 1'b0;
	 #10
	 opdone = m_din;
	
	 #800000 //facttorial deley
    opdone = m_din;
	 
	 //result_h WRITE AND READ
    m_wr = 1'b0;
    m_addr = 16'h7028;
	 #20;
    result_h = m_din;
    m_req = 1'b0;

	 #100
    m_req = 1'b1;
    m_wr = 1'b1;
    m_addr = 16'h0081;
    m_dout = result_h;
	 
	 //result_l REAND AND WRITE
	 #100
    m_wr = 1'b0;
    m_addr = 16'h7035;
	 #20
    result_l = m_din;
	 #100
    m_wr = 1'b1;
    m_addr = 16'h0030;
    m_dout = result_l;
	 //opclear
	 #100
    m_addr = 16'h7008;
    m_dout = 64'd1;

    //finish
    #300 $finish;
end

endmodule