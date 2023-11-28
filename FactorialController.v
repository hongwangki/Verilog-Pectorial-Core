module FactorialController (clk,reset_n,s_sel,s_wr,s_addr,s_din,OD,RH,RL,OS,OI,OC,OPR,s_dout);
    
	input clk, reset_n;
    input s_sel, s_wr;
    input [15:0] s_addr;
    input [63:0] s_din;
    input [1:0] OD;
    input [63:0] RH, RL;
    output OS, OI, OC;
    output reg [63:0] s_dout;
    output [63:0] OPR;

   ////////parameter///////
   parameter OPSTART = 3'b000;
   parameter OPCLEAR = 3'b001;
   parameter OPDONE = 3'b010;
   parameter INTREN = 3'b011;
   parameter OPERAND = 3'b100;
   parameter RESULT_H = 3'b101;
   parameter RESULT_L = 3'b110;
   parameter NOP = 3'b111;
   
   /////////reg type///////
   reg [63:0] opstart, opclear, intrEn, operand;
   
   ////////wire type///////
   wire we, re;

   ///////////Defined by State////////////
   always @(posedge clk or negedge reset_n) begin
    //reset==0
    if(~reset_n) begin
      {opstart, opclear, intrEn, operand, s_dout} <= 64'h0;
    end
    //opclear==0
    else begin
        if(OC) begin
         {opstart, opclear, intrEn, operand, s_dout} <= 64'h0;
        end
        
        else begin
            //write_enable set
            if(we) begin
                case(s_addr[5:3])
                    OPSTART: opstart <= s_din;
                    OPCLEAR: opclear <= s_din;
                    INTREN: intrEn <= s_din;
                    OPERAND: operand <= s_din;
                endcase
            end
            //read_enable set
            else if(re) begin
                case (s_addr[5:3])
                    OPDONE : s_dout <= {63'h0,OD};
                    RESULT_H : s_dout <= RH;
                    RESULT_L : s_dout <= RL;
                    default : s_dout <= 64'h0;
                endcase
            end
    end
end
    end

   ///////////assign//////////
   assign OS = opstart[0];
   assign OC = opclear[0];
   assign OI  = intrEn[0];
   assign OPR = operand;
   assign we = s_sel & s_wr;
   assign re = s_sel & ~s_wr;
endmodule
