module BUS (
    input clk, reset_n, m_req, m_wr,
    input [15:0] m_addr,
    input [63:0] m_dout, s0_dout, s1_dout,
    output reg m_grant,
    output reg [63:0] m_din,
    output reg s0_sel, s1_sel,
    output [15:0] s_addr,
    output s_wr,
    output [63:0] s_din
);
    ///////parameter///////
   parameter IDEL = 2'b00;
   parameter READY = 2'b01;
   parameter DEFI= 2'b10;

    /////////reg type//////
   reg [1:0] state, next_state;
   reg END;
   reg s_END;//END set Signal


   always @(posedge clk, negedge reset_n)
   begin
       if(~reset_n) state <= IDEL;
       else state <= next_state;
   end
//////////////next state//////////////
   always @(*)
   begin
      if (~reset_n) next_state = IDEL; // reset = 0
      else begin
         case (state)
            //mreq==1 => READY else IDEL
            IDEL : next_state = m_req ? READY : IDEL;
            READY : next_state = DEFI;
            //END==1 => IDEL else DEFI
            DEFI : next_state = (END) ? IDEL : DEFI;
            default : next_state = IDEL;
         endcase
      end
   end

//////////os///////////   
always @(posedge clk, negedge reset_n)
begin
    if(!reset_n) begin //reset= 0 case
        m_grant <= 1'b0;
        END <= 1'b0;
        s_END <= 1'd0;
        s0_sel <= 1'b0;
        s1_sel <= 1'b0;
    end
    else begin
        case (state)
            //IDEL state output define
            IDEL :  begin
                m_grant <= 1'b0;
                END <= 1'b0;
                s_END <= 1'd0;
                s0_sel <= 1'b0;
                s1_sel <= 1'b0;
            end
            //READY state output define
            READY:
                m_grant <= 1'b1;
            //DEFI state output define
            DEFI : begin
                s_END <= s_END + 1'd1;
                //s0 or s1 select define
                if ((m_addr>=16'h0000)&&(m_addr<=16'h07ff)) begin 
                    s0_sel  <= 1'b1;
                    s1_sel  <= 1'b0;
                end
                else if((m_addr>=16'h7000)&&(m_addr<=16'h71ff)) begin
               s0_sel  <= 1'b0;
                    s1_sel  <= 1'b1;

                end
                else begin
                    s0_sel <= 1'b0;
                    s1_sel <= 1'b0;
                end
                if (m_wr) begin
                    END <= 1'b1;
                end
                else begin
                    END <= s_END;
                end
            end
            //default
            default : begin
                m_grant <= 1'b0;
                END <= 1'b0;
                s_END <= 1'd0;
                s0_sel <= 1'b0;
                s1_sel <= 1'b0;
            end
        endcase
    end
end
////////////// s0, s1 dout define///////////////
   always @(*)
   begin
      //s0 sel set case
      if(s0_sel==1'b1 && s1_sel==1'b0)
         m_din=s0_dout;
      else begin
      //s1 sel set case
         if(s0_sel==1'b0 && s1_sel==1'b1)
         m_din= s1_dout;
         else m_din = 64'b0;
      end
   end
   
   /////////assign/////////
   assign s_addr = m_addr;
   assign s_din = m_dout;
   assign s_wr = m_wr;
   
endmodule
