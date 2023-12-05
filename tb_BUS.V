`timescale 1ns/100ps

module tb_BUS;

  // Inputs
  reg clk;
  reg reset_n;
  reg m_req;
  reg m_wr;
  reg [15:0] m_addr;
  reg [63:0] m_dout;
  reg [63:0] s0_dout, s1_dout;
  // Outputs
  wire s0_sel, s1_sel, m_grant;
  wire [63:0] m_din;
  wire s_wr;
  wire [15:0] s_addr;
  wire [63:0] s_din;

  // Instantiate the BUS module
  BUS uut (
    .clk(clk),
    .reset_n(reset_n),
    .m_req(m_req),
    .m_wr(m_wr),
    .m_addr(m_addr),
    .m_dout(m_dout),
    .s0_dout(s0_dout), 
    .s1_dout(s1_dout),
    .m_grant(m_grant),
    .m_din(m_din),
    .s0_sel(s0_sel),
    .s1_sel(s1_sel),
    .s_addr(s_addr),
    .s_wr(s_wr),
    .s_din(s_din)
  );
  
    // Clock generation using always block
  always begin
	#5 clk = ~clk;  // 5
	end

 // Initial block
  initial begin
    // Initialize inputs
    #0 clk = 0;
    reset_n = 0;
    m_req = 1;
    m_wr = 0;
    m_addr = 15'h0;
    m_dout = 64'h0;


    // Apply reset
    #20 reset_n = 1;
	 
	 //in address
	 #10
	 m_addr = 15'd10;
	 
	 //in dout
	 #10
	 m_dout =64'd1111;
	 s0_dout=64'haaa;
	 
	 //in dout
	 #20
	 m_dout =64'd2222;
	 s0_dout=64'hbbb;
	 
	 //in dout
	 #20
	 m_addr = 15'd11;
	 m_dout =64'd3333;
	 s0_dout=64'hccc;
    
	 //in dout and s1 set
	 #20
	 m_addr = 15'd28965;
	 m_dout =32'd7777;
	 s1_dout=32'hddd;
	 
	 #10
	 
	 //in dout
	 #20
	 m_dout =32'd8888;
	 s1_dout=32'heee;
	 
	 //in dout
	 #20
	 m_dout =32'd9999;
	 s1_dout=32'hfff;
	 
	 #30
	 m_req=0;
	 
	 #500 $finish;
  end

endmodule
