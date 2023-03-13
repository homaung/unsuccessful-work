module main( data1,
             data2,
             clk,
             addr0,
             overflow,
             reset2,
             q5,
             shstr,
             sch,
             rst
             
             
             
             
);


parameter S0=2'b00, S1=2'b01,S2=2'b10,S3=2'b11;

input wire [2:0] data1;
input wire [2:0] data2;
input wire rst;
reg select0;
reg select1;
reg select2;

reg reset0; 
reg reset1;
input wire reset2;

input wire shstr;
input wire clk;  
wire rw;

wire [2:0] q0;
wire [2:0] q1;
wire [2:0] q2;
reg q3;
wire q4;
output wire [5:0]q5;
reg q6;
reg q7;
wire q8;

input wire [5:0] addr0;
reg [5:0] addr1 = 6'b0000;
reg [5:0]addr2;
reg of= 6'b100000;
output reg overflow;

reg [1:0]cucs;
reg [1:0]cuns;
output reg sch;

ram utt1(.clk(clk),.rw(rw), .addr(addr1),.data(data1), .q(q0));
register utt2(.data(q0), .reset(reset0),.q(q1), .select(select0), .clk(clk));
register utt3(.data(data2), .reset(reset0),.q(q2), .select(select1), .clk(clk));
register utt4(.data(addr), .reset(reset1),.q(q5), .select(select2), .clk(clk));





  always@(q1,q2)
    begin
      if(q1==q2)
        q3<=1'b1;
      else
        q3<=1'b0;
    end
     
  always@ (rw)
    begin
      if(rw)
        addr1<=addr2;
      else
        addr1<=addr0;
    end  
    
  assign q4 = ~q3;
 
          
                 
  always@(q4, addr2)
      begin
        if(q4)
          begin
            if(q6)
              begin
                reset1<=1'b0;
                overflow<=1'b1;
              end
            else
              begin  
                overflow<=1'b0;
                addr2<=addr2+1;
                select2 <=q3;
              end
          end
        else 
          begin
            addr2<=addr2;
            select2 <=q3;
          end
     end

    
    
  always@(addr2,of)
    begin
      if(addr2==of)
        q6<=1'b1;
      else
        q6<=1'b0;
    end
  
  always @ (posedge clk, negedge reset2)
    begin
      if (!reset2)
        cucs <= S0;
      else
        cucs <= cuns;
    end
  
    assign q8 = ~q7;
  
  always@(q3,overflow)
    begin
      if(q3==overflow)
        q7<=1'b1;
      else
        q7<=1'b0;
    end
  
  always@(cucs,rw,q3)
    case(cucs)
      S0 : if(rw)
             begin
               cuns<=S0;
               reset0  <= 1'b0;
               select0 <= 1'b0;
               select1 <= 1'b1;
               sch     <= 1'b0;
             end
           else
             begin
               cuns<=S1;
               reset0  <= 1'b1;
               select0 <= 1'b1;
               select1 <= 1'b1;
               sch     <= 1'b0;
             end
      S1 : if(shstr)
             begin
               cuns<=S2;
               reset0  <= 1'b1;
               select0 <= 1'b1;
               select1 <= 1'b1;
               sch     <= 1'b1;
             end
           else
             begin
               cuns<=S1;
               reset0  <= 1'b1;
               select0 <= 1'b1;
               select1 <= 1'b1;
               sch     <= 1'b0;
             end
      S2 : if(rst)
             begin
               cuns<=S0;
               reset0  <= 1'b0;
               select0 <= 1'b0;
               select1 <= 1'b1;
               sch     <= 1'b0;
             end
           else
             begin   
               if(q8)
                 begin
                   cuns<=S3;
                   reset0  <= 1'b1;
                   select0 <= 1'b1;
                   select1 <= 1'b0;
                   sch     <= 1'b1;
                 end
               else
                 begin
                   cuns<=S2;
                   reset0  <= 1'b1;
                   select0 <= 1'b1;
                   select1 <= 1'b1;
                   sch     <= 1'b1;
                 end
             end
      S3 : if(rst)
             begin
               cuns<=S0;
               reset0  <= 1'b0;
               select0 <= 1'b0;
               select1 <= 1'b1;
               sch     <= 1'b0;
             end
           else
             begin
               cuns<=S3;
               reset0  <= 1'b1;
               select0 <= 1'b1;
               select1 <= 1'b0;
               sch     <= 1'b1;
             end
    endcase
  
    



endmodule
         
   



module register ( data,
                  reset,
                  q,
                  select,
                  clk
    );
    
input wire [2:0] data;
input wire reset;
input wire select;
input wire clk;
output reg [2:0] q;

reg [2:0] ns;

always @ (posedge clk, negedge reset)
begin
    if (!reset)
      q <= 3'b000;
    else
      q <= ns;
end
always @ (select)
begin
    if(!select)
        ns <= q;
      else
        ns <= data;  
end

endmodule



module ram(
    clk,
    rw,
    addr,
    data,
    q
    );
input  clk,
       rw;
input  [4:0] addr ;
input  [2:0] data;
output [2:0] q;

// wire & regs
reg         [      2:0]  mem[0:4]  ;
reg         [      4:0]  r_addr     ;


always @ (posedge clk)
begin
    if (rw)
     begin    
       mem[addr] <= data;
     end 
    else
     begin
      r_addr <= addr;
     end 
end
assign q = mem[r_addr];

endmodule 



module counter(clk,
               reset,
               count_enble,
               count,
               countout                   
);

input wire clk;         
input wire reset;
input wire count_enble;       
output reg [5:0] count;
output reg countout;
reg [5:0] q = 6'b111111;
reg [5:0] q1;
    
always @(posedge clk,negedge reset,count_enble)
    begin
       if (!reset) 
          begin
             count <= 6'b000000;  // 리셋 상태에서는 카운터 0으로 초기화
          end 
       else
          begin
             if(count_enble==1'b0)
                begin
                
                end              
             else
                begin
                   if (q1) 
                      begin
                         count <= 6'b000000; // 63에 도달하면 다시 0으로 초기화
                      end 
                   else 
                      begin
                         count <= count + 1;
                      end
                end
          end

    end

always @ (count)
   begin
      if(count==q)
         q1<=1'b1;
      else             
         q1<=1'b0;
   end        
endmodule