`timescale 1ns / 100ps

module tb_ram;
	 //reg type
    reg clk;
    reg cen, wen;
    reg [7:0] s_addr;
    reg [63:0] s_din;
	 //wire type
    wire [63:0] s_dout;

    // Instantiate the ram module
    ram uut (
        .clk(clk),
        .cen(cen),
        .wen(wen),
        .s_addr(s_addr),
        .s_din(s_din),
        .s_dout(s_dout)
    );

    // Clock generation
    always begin
        #5 clk = ~clk;
    end

    // Initial block for testbench stimulus
    initial begin
        // Initialize inputs
        #0
		  clk = 0;
        cen = 0;
        wen = 0;
        s_addr = 0;
        s_din = 64'h0000_0000;
			//s_addr=5 case data input 3 write
        #8 wen = 1;
        s_din = 64'hABCD_EFFF;
        s_addr = 8'd5;
        cen = 1;
		  
		  #10
		  wen=0;
		  
		  #10
		  wen=1;
		  s_din= 64'hFFFF_FFFF;
		  
		  #10
		  wen=0;
		  
		  #10
		  wen=1;
		  s_din=64'd82732;
		  
		  #10
		  //s_addr=4 case data input 2
		  s_addr=8'd4;
		  s_din=64'd1111111111;
		  
		  #10
		  wen=0;
		  
		  #10
		  s_din=64'd5555555;
		  wen=1;
        #10 
		  wen=0;
		  
		  #20
		  
		  #10 cen=0; //clear
		  //last input read
		  #10 
		  cen=1;
		  s_addr=8'd5;
				
		  #30 $finish;

    end

endmodule
