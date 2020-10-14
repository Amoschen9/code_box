module code_box(led,clk,rst,num_led1,num_led2,comf,inputt_code,button_code,times1,times2,times3);
	input [2:0]inputt_code;//输入密码的拨码
	input [2:0]button_code;//输入密码的按钮
	input comf;//确认键
	input clk;//时钟
	input rst;//复位键
	output  [2:0] led;//解锁指示灯
	output reg [8:0] num_led1;//第一根数码管(右).
	output reg [8:0] num_led2;//第二根数码管(左).
	output [1:0] times1,times2,times3;//记录剩余次数
	
	parameter password1=5;//设置第一位密码为5（来自拨码）
	parameter password2=6;//设置第一位密码为6（来自按键）
	
	reg [2:0] sgn;//两位指示灯信号,对应两路6指示灯(一红一绿).
	reg [8:0] seg [8:0];//9位宽信号,用来储存数码管数字显示数据
	reg [8:0] seg_data [1:0];//数码管显示信号寄存器.
	reg [1:0] cnt;//计数器,用以统计错误次数.
	reg lock;//程序锁,以避免次数用完后或者密码正确之后的误操作.
 
	wire cfm_dbs;//消抖后的确认脉冲.
	
	
	initial begin//初始化.
	seg[8] = 9'h40;														 //7段显示符号  -  
	seg[0] = 9'h3f;                                           //7段显示数字  0
	seg[1] = 9'h06;                                           //7段显示数字  1
	seg[2] = 9'h5b;                                           //7段显示数字  2
	seg[3] = 9'h4f;                                           //7段显示数字  3
	seg[4] = 9'h66;                                           //7段显示数字  4
	seg[5] = 9'h6d;                                           //7段显示数字  5
	seg[6] = 9'h7d;                                           //7段显示数字  6
	seg[7] = 9'h07;                                           //7段显示数字  7
	sgn = 3'b111;
//	seg[inputt_code]= 9'h3f;
//	seg[button_code]= 9'h3f;//数码管初始显示数字0.
	cnt = 2'b11;//计数器初始值为3.
	end
	

	always @ (posedge clk or negedge rst)//时钟边沿触发或复位按键触发.
	begin
		if(!rst)begin//复位操作.
			sgn <= 3'b111;//两灯均灭.

			num_led1 <= seg[8];
			num_led2 <= seg[8];
			cnt <= 2'b11;//计数器复位到3.
			
			end
		
		else if(comf_dbs )begin//按下确认键,此处用的消抖后的脉冲信号.若程序锁已锁,此下代码均不会再被执行.
			if(inputt_code == password1 && button_code==password2)begin//密码正确.
				sgn <= 3'b101;//绿灯亮.

				end
			else if(cnt == 2'b11)begin
				sgn <= 3'b011;//红灯亮.
				cnt <= 2'b10;//计数器移至2.
				end
			else if(cnt == 2'b10) begin
				sgn <= 3'b011;//红灯亮.
				cnt <= 2'b01;//计数器移至1.
				end
			else if(cnt == 2'b01)begin
				sgn <= 3'b100;//红灯和绿灯同时亮
				
				end
		end
		else begin
			num_led1 <= seg[inputt_code];
			num_led2 <= seg[button_code];
		end
	end
	assign led=sgn;
	debounce key_cfm_dbs (//调用消抖模块,用以消抖确认键.
		.clk (clk),
		.rst (rst),
		.key (comf),
		.key_pulse (comf_dbs));
endmodule
