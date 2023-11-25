module regfile (
    input clk, reset_n,
    input s_sel, s_wr,
    input [15:0] s_addr,
    input [63:0] s_din,
    input [1:0] in_opdone,
    input [63:0] in_result_h, in_result_l,
    output out_opstart, out_intrEn, out_opclear,
    output reg [63:0] s_dout,
    output [63:0] out_operand
);
   //parameter
   parameter OPSTART = 16'h7000;
   parameter OPCLEAR = 16'h7008;
   parameter OPDONE = 16'h7010;
   parameter INTREN = 16'h7018;
   parameter OPERAND = 16'h7020;
   parameter RESULT_H = 16'h7028;
   parameter RESULT_L = 16'h7030;
   
   //reg type
   reg [63:0] opstart, opclear, intrEn, operand;
   //wire type
   wire we, re;

   always @(posedge clk or negedge reset_n) begin
    //reset==0
    if(~reset_n) begin
        opstart <= 64'h0;
        opclear <= 64'h0;
        intrEn <= 64'h0;
        operand <= 64'h0;
        s_dout <= 64'h0;
    end
    //opclear==0
    else begin
        if(out_opclear) begin
            opstart <= 64'h0;
            opclear <= 64'h0;
            intrEn <= 64'h0;
            operand <= 64'h0;
            s_dout <= 64'h0;
        end
        
        else begin
            //write_enable set
            if(we) begin
                case(s_addr)
                    OPSTART: opstart <= s_din;
                    OPCLEAR: opclear <= s_din;
                    INTREN: intrEn <= s_din;
                    OPERAND: operand <= s_din;
                endcase
            end
            //read_enable set
            else if(re) begin
                case (s_addr)
                    OPDONE : s_dout <= {63'h0,in_opdone};
                    RESULT_H : s_dout <= in_result_h;
                    RESULT_L : s_dout <= in_result_l;
                    default : s_dout <= 64'h0;
                endcase
            end
    end
end
    end

   //assign
   assign out_opstart = opstart[0];
   assign out_opclear = opclear[0];
   assign out_intrEn  = intrEn[0];
   assign out_operand = operand;
   assign we = s_sel & s_wr;
   assign re = s_sel & ~s_wr;
endmodule