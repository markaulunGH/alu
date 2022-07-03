`timescale 1ns / 1ps
//��tbΪ��CPU���ʵս��ʵ��tb,�޸��˲�������
module mul_tb;

	// Inputs
	reg mul_clk;
	reg resetn;
	reg mul_signed;
	reg [31:0] x;
	reg [31:0] y;
	reg 		in_valid;

	// Outputs
	wire signed [63:0] result;
	wire  in_ready;
	wire out_valid;

	// Instantiate the Unit Under Test (UUT)
	boothmul uut (
		.clk(mul_clk), 
		.reset (!resetn), 
//		.mul_signed(), 
		.src2({mul_signed & x[31],x}), 
		.src1({mul_signed & y[31],y}), 
		.in_valid(in_valid),
		.in_ready(in_ready),
		.out_valid(out_valid),
		.result(result)
	);

	initial begin
		// Initialize Inputs
		mul_clk = 0;
		resetn = 0;
		mul_signed = 0;
		x = 0;
		y = 0;
		#100;
		resetn = 1;
	end
	always #5 mul_clk = ~mul_clk;

//��������������з��ſ����ź�
always @(posedge mul_clk)
begin
    x          <= $random;//32'h04000000;//
    y          <= $random;//32'hd0000000;// //$randomΪϵͳ���񣬲���һ�������32λ�з�����
    mul_signed <= {$random}%2; //����ƴ�ӷ���{$random}����һ���Ǹ�������2ȡ��õ�0��1
end

//�Ĵ�������з��ų˿����źţ���Ϊ��������ˮ���ʴ�һ��
reg [31:0] x_r;
reg [31:0] y_r;
reg          mul_signed_r;

always @(posedge mul_clk)
begin
    if (!resetn)
    begin
        x_r          <= 32'd0;
        y_r          <= 32'd0;
        mul_signed_r <= 1'b0;
		in_valid 	 <= 1'b1;
    end
    else if (in_ready && in_valid)
    begin
        x_r          <= x;
        y_r          <= y;
        mul_signed_r <= mul_signed;
    end
end

//�ο����
wire signed [63:0] result_ref;
wire signed [32:0] x_e;
wire signed [32:0] y_e;
wire  [63:0] diff;
assign x_e        = {mul_signed_r & x_r[31],x_r};
assign y_e        = {mul_signed_r & y_r[31],y_r};
assign result_ref = x_e * y_e;
assign ok         = (result_ref == result);
assign diff       = result_ref ^ result;

//��ӡ������
/*initial begin
    $monitor("x = %d, y = %d, signed = %d, result = %d,OK=%b",x_e,y_e,mul_signed_r,result,ok);
end*/

//�жϽ���Ƿ���ȷ
always @(posedge mul_clk)
begin
	if (!ok && out_valid)
    begin
	    $display("Error��x_r = %h, y_r = %h,result = %h, result_ref = %h, OK=%b, diff=%h",x_e,y_e,result,result_ref,ok,diff);
	    $finish;
	end
end
      
endmodule
