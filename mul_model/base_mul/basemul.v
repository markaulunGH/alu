module basemul(
  input                          clk           ,
  input                          reset         ,
  input  [31:0] src1,
  input  [31:0] src2,
  input         in_valid,
  output        in_ready,
  output        out_valid,
  output [63:0] result,

);

reg [63:0] tem_result, multiplicand;
reg [31:0] multiplier;
reg in_ready,out_valid,doing;

wire calculate_done,ready_to_doing,doing_to_done,done_to_ready;
wire [63:0] mid_result;
assign ready_to_doing = in_valid && in_ready;
assign doing_to_done  = calculate_done;
assign done_to_ready  = out_valid;
assign result         = tem_result;
always @(posedge clk) begin
    if (reset) begin
        in_ready<=1;
    end
    else if (ready_to_doing) begin
        in_ready <= 1'b0;
    end
    else if (done_to_ready) begin
        in_ready <= 1'b1;
    end    
end

always @(posedge clk) begin
    if (reset ) begin
        out_valid <=1'b0;
    end
    else if (doing_to_done ) begin
        out_valid <= 1'b1;
    end
    //Done signal remains for one cycle
    else begin
        out_valid <=1'b0;
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
    if (ready_to_dong ) begin
        multiplicand <= {32{src2[31]},src2};
    end
    //shift left  << 1
    else if (doing) begin
        multiplicand <= {multiplicand[62:0],1'b0};
    end
end

always @(posedge clk) begin
    if (ready_to_doing) begin
        multiplier <= src1;
    end
    //shift right >> 1
    else if (doing) begin 
        multiplier[31:0] <= {1'b0,multiplier[31;1]};
    end
    
end

assign calculate_done = multiplier == 32'h0;
assign mid_result = multiplicand & {64{multiplier[0]}};

// 64-bit adder
wire [63:0] adder_a;
wire [63:0] adder_b;
wire [63:0] adder_cin;
wire [63:0] adder_result;
wire        adder_cout;

assign adder_a   = mid_result;
assign adder_b   = tem_result;
assign adder_cin = 64'h0;
assign {adder_cout, adder_result} = adder_a + adder_b + adder_cin;

always @(posedge clk) begin
    if (doing) begin
    tem_result <= adder_result;
    end
end