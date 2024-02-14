`timescale 1ns / 1ps
module mod100(clk,an1,ca);
input clk;
output reg [7:0]an1=0;
output reg [7:0]ca=0;
wire [7:0]ca1,ca2;
reg [3:0]mod1=0;
reg [3:0]mod2=0;
reg clk1=0;
reg clk2=0;
reg m=0;
integer count1=0;
integer count2=0;
//block to generate clk both seconds and refreshing
always@(posedge clk)
begin
if (count1==50000000)
    begin
        count1<=0;
        clk1<=~clk1;
    end
else
    begin
        count1<=count1+1;
    end

if (count2==10000)
    begin
        count2<=0;
        clk2<=~clk2;
    end
else
    begin
    count2<=count2+1;
    end
end
//logic for mod 100
always@(posedge clk1)
begin
if (mod1<9)
    begin
        mod1<=mod1+1;
    end
else
   mod1<=0;
if( mod2<=9)
    begin
       if (mod1==9)
            begin
                if (mod2<9)
                mod2<=mod2+1;
                else
                    mod2<=0;
            end
        else
            mod2<=mod2;
    end  
else
    begin
        mod2<=0;
    end
end
//printing mod 100
always@(posedge clk2)
begin
case(m)
0:begin
        an1<=8'b11111110;
        m<=~m;
        ca<=ca1;
   end
1:begin
    an1<=8'b11111101;
    m<=~m;
    ca<=ca2;
    end
endcase
end
display a(clk1,mod1,ca1);
display b(clk1,mod2,ca2);

endmodule
module display(clk,count,cathode);
input clk;
input [3:0]count;
output  reg [7:0]cathode;
always@(posedge clk)
begin
case({count})
0:cathode=8'b00000011;
1:cathode=8'b10011111;
2:cathode=8'b00100101;
3:cathode=8'b00001101;
4:cathode=8'b10011001;
5:cathode=8'b01001001;
6:cathode=8'b11000001;
7:cathode=8'b00011111;
8:cathode=8'b00000001;
9:cathode=8'b00011001;
endcase
end
endmodule
