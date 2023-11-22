module ram (
    input clk, wen, cen,
    input [63:0] s_din,
    input [7:0] s_addr,
    output reg [63:0] s_dout
);
   //63 bit mem 255 save
   reg [63:0] mem [0:255];

   
   integer i;
   initial begin
   //mem initialization
   for(i=0; i<64; i=i+1)begin
   mem[i]<=64'd0;
   end
   end
   
   always @(posedge clk)
   begin
         //cen && wen ==1 case
       if((cen==1'b1) && (wen==1'b1)) begin
           mem[s_addr] <= s_din;
           s_dout <= 64'h0;
       end
         //cen =1 && wen ==0 case
       else if((cen==1'b1) && (wen==1'b0)) begin
           s_dout <= mem[s_addr];
       end
         //cen =0 case
       else if(cen==1'b0) begin
       s_dout <= 64'd0;
       end
   end
endmodule
