module basemul(
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
reg [31:0] divisor;
reg doing,op_signed,divisor_s,dividend_s;

wire calculate_done,ready_to_doing,doing_to_done,done_to_ready;
wire [31:0] x_add,y_add,x_abs,y_abs;

always @(posedge clk) begin
    if (reset  || done_to_ready) begin
        in_ready <= 1'b1;
    end
    else if (ready_to_doing) begin
        in_ready <= 1'b0;
    end 
end

always @(posedge clk) begin
    if (reset ) begin
        doing <= 1'b0;
    end
    else if (ready_to_doing) begin
        doing <= 1'b1;
    end 
    else if (doing_to_done) begin
        doing <= 1'b0;
    end
end

always @(posedge clk) begin
    if (reset ) begin
        out_valid <= 1'b0;
    end
    else if (doing_to_done) begin
        out_valid <= 1'b1;
    end 
    else if (done_to_ready) begin
        out_valid <= 1'b0;
    end
end

always @(posedge clk) begin
    if (reset) begin
        op_signed <= 1'b0;
        divisor_s <= 1'b0;
        dividend_s <= 1'b0;        
    end
    else if (ready_to_doing) begin
        op_signed <= div_signed;
        divisor_s <= div_signed & y[31];
        dividend_s <= div_signed & x[31];
    end    
end

adder_32 x_adder(
    .src1  (x),
    .src2  ({32'b1}),
    .cin    (1'b0),
    .cout   (),
    .result (x_add)
);
adder_32 y_adder(
    .src1  (y),
    .src2  ({32'b1}),
    .cin    (1'b0),
    .cout   (),
    .result (y_add)
);

assign x_abs = div_signed & x[31] ? x_add : x ;
assign y_abs = div_signed & y[31] ? y_add : y ;

always @(posedge clk) begin
    if (ready_to_doing) begin
        dividend <= {32'b0,x_abs};
        divisor <= y_abs;
    end
    else if (doing ) begin
     //   dividend <= sub_cout ? {sub_re}  //working here
    end
    
end

wire sub_cout;
wire [32:0] sub_result;
adder_33 suber(
    .src1  (dividend[63:31]),
    .src2  ({1'b1,~divisor}),
    .cin    (1'b1),
    .cout   (sub_cout),
    .result (sub_result)
);



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
    output [33:0] result
);
assign {cout, result} = src1 + src2 + {32'b0,cin};

endmodule
