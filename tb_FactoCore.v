`timescale 1ns/100ps

module tb_FactoCore;

  // Inputs
  reg clk;
  reg reset_n;
  reg s_sel;
  reg s_wr;
  reg [15:0] s_addr;
  reg [63:0] s_din;
  
  // Outputs
  wire [63:0] s_dout;
  wire interrupt;

  // Instantiate FactoCore module
  FactoCore uut (
    .clk(clk),
    .reset_n(reset_n),
    .s_sel(s_sel),
    .s_wr(s_wr),
    .s_addr(s_addr),
    .s_din(s_din),
    .s_dout(s_dout),
    .interrupt(interrupt)
  );

    // Clock generation using always block
  always begin
	#5 clk = ~clk;  // 5
	end

  // Initial values
  initial begin
	 clk=0;
    reset_n = 0;
    s_sel = 1;
    s_wr = 1;
    s_addr = 16'h0000;
    s_din = 64'h0000000000000000;

    // Apply reset
    #20 reset_n = 1;

    // Test scenario
    #100
        //operand
        s_addr = 16'h7020;
        s_din = 64'h7;

    #100
		 //interen
		  s_addr = 16'h7018;
        s_din = 64'h1;
	 #100 
		 //opstart
		  s_addr = 16'h7000;
        s_din = 64'h1;
	 #100
		  //opdone
		  s_addr = 16'h7010;
        s_din = 64'h1;
		  s_wr=0;
	 #8000

	 #100
		  //result h
		  s_addr = 16'h7028;
	 #100
		  //result l
		  s_addr = 16'h7030;
	 #100
		  //opclear
		  s_addr = 16'h07008;
		  s_din=64'h1;
		  

    #1000 $finish;
  end

endmodule