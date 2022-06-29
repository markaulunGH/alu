module basediv(
  input                          clk           ,
  input                          reset         ,
  input  [31:0] x,
  input  [31:0] y,
  input         in_valid,
  input         div_signed,
  output reg    in_ready,
  output reg    out_valid,
  output [31:0] s,
  output [31:0] r

);
reg [63:0] dividend;
reg [31:0] divisor,qutient,remain;
reg doing,divisor_s,dividend_s;
reg [5:0] count;
wire calculate_done,ready_to_doing,doing_to_done,done_to_ready;

//state transition
assign ready_to_doing = in_ready && in_valid;
assign doing_to_done  =  calculate_done;
assign done_to_ready  = out_valid;
assign calculate_done = doing &&  count == 6'h20;
always @(posedge clk) begin
    if (reset  || done_to_ready) begin
        in_ready <= 1'b1;
    end
    else if (ready_to_doing) begin
        in_ready <= 1'b0;
    end 
end

always @(posedge clk) begin
    if (reset || doing_to_done ) begin
        doing <= 1'b0;
    end
    else if (ready_to_doing) begin
        doing <= 1'b1;
    end 
end

always @(posedge clk) begin
    if (reset || done_to_ready ) begin
        out_valid <= 1'b0;
    end
    else if (doing_to_done) begin
        out_valid <= 1'b1;
    end 
end
//signed bit
always @(posedge clk) begin
    if (reset) begin
        divisor_s <= 1'b0;
        dividend_s <= 1'b0;        
    end
    else if (ready_to_doing) begin
        divisor_s <= div_signed & y[31];
        dividend_s <= div_signed & x[31];
    end    
end
//iterative operation and correct
wire sub_cout;
wire [32:0] sub_result;
wire op_correct;
wire [31:0] qutient_correct,remain_correct;
wire [31:0] x_adder_result,y_adder_result,x_abs,y_abs;
wire [31:0] x_adder_src1,y_adder_src1;

assign x_adder_src1 = op_correct ? dividend[63:32] : x;
assign y_adder_src1 = op_correct ? qutient : y;


//signed <==> abs
adder_32 x_adder(
    .src1  (~x_adder_src1),
    .src2  ({32'b1}),
    .cin    (1'b0),
    .cout   (),
    .result (x_adder_result)
);
adder_32 y_adder(
    .src1  (~y_adder_src1),
    .src2  ({32'b1}),
    .cin    (1'b0),
    .cout   (),
    .result (y_adder_result)
);

// sub of iteration
adder_33 suber(
    .src1  (dividend[63:31]),
    .src2  ({1'b1,~divisor}),
    .cin    (1'b1),
    .cout   (sub_cout),
    .result (sub_result)
);
// Choose the abs of dividend and divisor
assign x_abs = div_signed & x[31] ? x_adder_result : x ;
assign y_abs = div_signed & y[31] ? y_adder_result : y ;

//Update dividend ,divisor and qutient
always @(posedge clk) begin
    if (ready_to_doing) begin
        dividend <= {32'b0,x_abs};
        divisor <= y_abs;
    end
    //iterate and shift left  << 1
    else if (doing ) begin
       dividend <= sub_cout ? {sub_result[31:0],dividend[30:0],1'b0} : {dividend[62:0],1'b0};
    end
 
    
end
// counter
always @(posedge clk) begin
    if (reset || done_to_ready ) begin
        count <= 6'b0;
    end
    else if (doing) begin
        count <= count +1'b1;
    end
    
end

//Correct result
wire qutient_need_correct,remain_need_correct;

assign op_correct = calculate_done;
assign remain_correct  = x_adder_result;
assign qutient_correct = y_adder_result;
assign qutient_need_correct = ~dividend_s & divisor_s | dividend_s & ~divisor_s;
assign remain_need_correct  = dividend_s;

always @(posedge clk ) begin
    if (op_correct) begin
        remain  <= remain_need_correct  ? remain_correct  : dividend[63:32];
    end
   if (op_correct) begin
        qutient <= qutient_need_correct ? qutient_correct : qutient;
    end 
    else if (doing) begin
        qutient <= {qutient[30:0],sub_cout};
    end    
end
// finally result
assign s = qutient;
assign r = remain;



endmodule



module adder_32 (
    // 32-bit adder
    input [31:0] src1,
    input [31:0] src2,
    input        cin,
    output       cout,
    output [31:0] result
);
assign {cout, result} = src1 + src2 + {31'b0,cin};

endmodule
module adder_33 (
    // 33-bit adder
    input [32:0] src1,
    input [32:0] src2,
    input        cin,
    output       cout,
    output [32:0] result
);
assign {cout, result} = src1 + src2 + {32'b0,cin};

endmodule
