`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 07.02.2022 19:17:18
// Design Name:
// Module Name: ALU
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
module incore(
        input clk,
        //input reset,
        //input wire [31:0] indata,
        //output reg [31:0] outdata,
        //output reg [31:0] outmemaddr,
       // output reg mem_wr,        
       // output reg mem_rd,
        input [31:0] INSTR,
       output reg [31:0] ALUResult
    );
   
    reg [31:0] PC;
    reg [31:0] instr  ;
   
    wire [4:0] rd;
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire [6:0] opcode;
    wire WriteBackEn;
       
    Decoder MyDecoder(
                 .instr(instr),
                 .rd(rd),
                 .WriteBackEn(WriteBackEn),
                 .rs1(rs1),
                 .rs2(rs2),
                 .funct3(funct3),
                 .funct7(funct7),
                 .opcode(opcode)
                 );
                 
    //// Register File ////
    reg [31:0] Data_in ;
    wire [31:0] Regdata1;
    wire [31:0] Regdata2;
   
     RegisterFile MyRegFile(
                 .clk(clk),
                 .Data_in(Data_in),
                 .Wr_idx(rd),
                 .En(WriteBackEn),
                 .R1_idx(rs1),
                 .R2_idx(rs2),
                 .Reg_1(Regdata1),
                 .Reg_2(Regdata2)
                 );
                 
    //// ALU ////
   
   // reg [31:0] ALUin1;
   wire [31:0] aluout;
    reg [31:0] aluIn1;
    reg [31:0] aluIn2;
    ALU MyALU(
             .In1(aluIn1),
             .In2(aluIn2),
             .opcode(opcode),
             .funct3(funct3),
             .funct7(funct7),
             .Result(aluout)
              );
             
           
        //// State Machine ////
       reg [2:0] state = 3'b000;
       parameter s0=3'b000, s1=3'b001, s2=3'b010, s3=3'b011 ;
       
    always @(posedge clk)
    begin
        case(state)
        s0    :      begin
                     instr <= INSTR;
                     #5;
                     state <= s1;
                     end
       s1     :      begin
                     aluIn1 <= Regdata1;
                aluIn2 <= Regdata2;
                #5;
                     state <= s2;
                     end
       s2     :      begin
                     ALUResult <= aluout;
                     Data_in <= aluout;
                     #5;
                     state <= s3;
                     end
         endcase
         end                                                                    
endmodule
module ALU(
    input [31:0] In1,
    input [31:0] In2,
    input [6:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7,
    output reg [31:0] Result
    );
   
    `define add   17'b00000000000110011
    `define sub   17'b01000000000110011
    `define sll   17'b00000000010110011
    `define slt   17'b00000000100110011
    `define sltu  17'b00000000110110011
    `define xor   17'b00000001000110011
    `define srl   17'b00000001010110011
    `define sra   17'b01000001010110011
    `define or    17'b00000001100110011
    `define and   17'b00000001110110011
   
        always@(*)
  begin
   case({funct7,funct3,opcode})
   //// add Instruction ////
   `add : begin
           Result = In1 + In2;
          end
   `sub : begin
           Result = In1 - In2;
          end
   `sll : begin
           Result = In1 << In2;
          end
   `slt : begin
           Result = (In1 < In2) ? 1 : 0;
          end
   `sltu : begin
           Result = (In1 < In2) ? 1 : 0;
          end
   `xor : begin
           Result = In1 ^ In2;
          end
    `srl : begin
           Result = In1 >> In2;
          end
    `sra : begin
           Result = In1 >> In2;
          end
    `or : begin
           Result = In1 | In2;
          end
    `and : begin
           Result = In1 & In2;
           end                                          
   endcase
  end
     
   
endmodule
module Decoder(
    input [31:0] instr,
    output wire [4:0]  rd,
    output wire [4:0]  rs1,
    output wire [4:0]  rs2,
    output wire [2:0] funct3,
    output wire [6:0] funct7,
    output wire [6:0] opcode,
    output wire WriteBackEn
    );
    // Decoding //
    assign opcode = instr[6:0];
    assign rd     = instr[11:7];
    assign funct3 = instr[14:12];
    assign rs1    = instr[19:15];
    assign rs2    = instr[24:20];
    assign funct7 = instr[31:25];
   
   
endmodule
module Memory(
    input clk,
    input [31:0] PC,
    input rd,
    input wr,
    input [31:0] inputdata,
    output reg [31:0] outputdata
   
    );
    reg [31:0] memory [15:0];
   
    always@(posedge clk) begin
        if (wr) begin
            memory[PC] <= inputdata;
        end      
        if (rd) begin
            outputdata <= memory[PC];
        end
    end
   
endmodule

module RegisterFile(
    input clk,
    input [31:0] Data_in,
    input [4:0] Wr_idx,
    input En,
    input [4:0] R1_idx,
    input [4:0] R2_idx,
    output [31:0] Reg_1,
    output [31:0] Reg_2    
    );
    reg [31:0] GPR [15:0];
    // integer i;
    initial
    begin
     GPR[1] = 32'd1;
     GPR[2] = 32'd2;
     GPR[3] = 32'd3;
     end
   
    assign Reg_1 = GPR[R1_idx];
    assign Reg_2 = GPR[R2_idx];
    //assign GPR[Wr_idx] <= Data_in;
    always @(negedge clk)
    begin
     GPR[Wr_idx] <= Data_in;
    end
endmodule
