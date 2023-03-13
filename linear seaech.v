module linearsearch (data_register1,
                      reset,
                      clk,
                      data_ram,
                      str
                     
);
parameter S0=2'b00, S1=2'b01, S2=2'b10,S3=2'b11;

//공용
input wire reset;
input wire clk;

// 레지스터1
input wire [3:0] data_register1;//입력
reg select_register1;           //select
reg [3:0] outdata_register1;    //출력
reg [3:0] ns_register1;         

//RAM
input wire [3:0] data_ram;          //입력
reg  [4:0] addr ;                  //주소
wire  [3:0] outdata_ram;          //출력
reg  rw;                          //읽기 쓰기
reg  [3:0] mem[0:4];
reg  [4:0] r_addr;

//레지스터2
wire [3:0] data_register2;//입력
reg select_register2;           //select
reg [3:0] outdata_register2;    //출력
reg [3:0] ns_register2;         

//Control Unit
input wire str;
reg [1:0] ps_cu;
reg [1:0] ns_cu;
reg [4:0]cnt;


//레지스터1////////////////////////////////
always @ (posedge clk, negedge reset)
begin
    if (!reset)
      outdata_register1 <= 4'b0000;
    else
      outdata_register1 <= ns_register1;
end
always @ (select_register1)
begin
    if(!select_register1)                  //1일때 데이터 입력
        ns_register1 <= outdata_register1; //0일때 데이터 유지
      else
        ns_register1 <= data_register1;  
end
 ///////////////////////////////////////////

 
 //RAM/////////////////////////////////////////

always @ (posedge clk)
begin
    if (rw)
     begin    
       mem[addr] <= data_ram;
     end 
    else
     begin
      r_addr <= addr;
     end 
end

assign outdata_ram = mem[r_addr];
///////////////////////////////////////////////
 
 
 
//레지스터2////////////////////////////////
always @ (posedge clk, negedge reset)
begin
    if (!reset)
      outdata_register2 <= 4'b0000;
    else
      outdata_register2 <= ns_register2;
end
always @ (select_register2)
begin
    if(!select_register2)
        ns_register2 <= outdata_register2;
      else
        ns_register2 <= data_register2;  
end
 ///////////////////////////////////////////


//Control unit////////////////////////////////
always @ (posedge clk, negedge reset)
    begin
    if (!reset)
         ps_cu <= S0;
    else
         ps_cu <= ns_cu;
    end

always @ (str)
        case(str)
        S0 : if(str)
                begin
                    ns_cu <= S0;
                    select_register1 <= 1'b1;
                    select_register2 <= 1'b0;
                end
              else
                begin
                    ns_cu <= S1;
                    select_register1 <= 1'b0;
                    select_register2 <= 1'b0;
                end
         S1 : if(outdata_ram ==outdata_register1)
                  begin
                      ns_cu <= S2;
                      select_register1 <= 1'b0;
                      select_register2 <= 1'b1;
                  end
               else
                  begin
                      ns_cu <= S1;
                      select_register1 <= 1'b0;
                      select_register2 <= 1'b0;
                      cnt<=cnt+1;
                  end
                
        endcase
 
 
 //////////////////////////////////////////////////////
 
 
 
 
endmodule