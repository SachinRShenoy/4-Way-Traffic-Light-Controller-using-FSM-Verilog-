`timescale 1ns/1ps

/*
DEFAULT ALL RED

s0 - 0000-All Red

s2 - 0001-North Yellow
s1 - 0010-North Green

s4 - 0101-East Yellow
s3 - 0110-East Green

s6 - 1001-South Yellow
s5 - 1010-South Green

s8 - 1101-West Yellow
s7 - 1110-West Green

*/
module Traffic_4way(input clk,reset,output reg[2:0]North,South,East,West);
	
	parameter [3:0] s0=4'd0,s1=4'd2,s2=4'd1,s3=4'd6,s4=4'd5,s5=4'd10,s6=4'd9,s7=4'd14,s8=4'd13;
	parameter [2:0]G=3'b001,R=3'b100,Y=3'b010;

	parameter integer CLK_FREQ  = 100;
	parameter integer HALF_SEC  = CLK_FREQ / 2;      
	parameter integer THREE_SEC = CLK_FREQ * 3;      
	
	reg [21:0] timer_cnt;
	reg [21:0] timer_limit;
	wire timer_done;

	reg [3:0] NS,PS;
	reg [1:0] phase;
	
	//Allot time for states
	always @(*) begin
    if (PS == s0)
        timer_limit = HALF_SEC;
    else if (PS == s2 || PS == s4 || PS == s6 || PS == s8)
        timer_limit = HALF_SEC;
    else
        timer_limit = THREE_SEC;
	end
	
	//Count time
	always @(posedge clk or posedge reset) begin
    if (reset)
        timer_cnt <= 0;
    else if (timer_done)
        timer_cnt <= 0;
    else
        timer_cnt <= timer_cnt + 1;
	end

	//Alert signal after counting
	assign timer_done = (timer_cnt == timer_limit - 1);
	
	//Present State changes
	always@(posedge clk or posedge reset)
	begin
		if(reset)
			PS<=s0;
		else if(timer_done)
				PS<=NS;
	end
	
	//Phase allocation
	always @(posedge clk or posedge reset) begin
    if (reset)
        phase <= 2'd0;
    else if (timer_done &&
            (PS == s2 || PS == s4 || PS == s6 || PS == s8))
        phase <= phase + 1;
	end


	//Next state allocation
	always@(*) begin
		NS=s0;
		case(PS)
			s0: begin
            case (phase)
                2'd0:NS=s1;
                2'd1:NS=s3;
                2'd2:NS=s5;
                2'd3:NS=s7;
            endcase
			end
			s1:NS=s2;
			s3:NS=s4;
			s5:NS=s6;
			s7:NS=s8;
			s2:NS=s0;
			s4:NS=s0;
			s6:NS=s0;
			s8:NS=s0;
			default: 
					NS=s0;
		endcase
	end
	
	//Output allocation
	always@(*) begin
		North<=R;
		South<=R;
		East<=R;
		West<=R;
		case(PS)
			s1:North<=G;
			s2:North<=Y;
			s3:East<=G;
			s4:East<=Y;
			s5:South<=G;
			s6:South<=Y;
			s7:West<=G;
			s8:West<=Y;
			default:
			begin
				North<=R;
				South<=R;
				East<=R;
				West<=R;
			end
		endcase
	end
	
	
endmodule