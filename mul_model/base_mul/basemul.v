module basemul(
  input                          clk           ,
  input                          reset         ,
  input  [32:0] src1,
  input  [32:0] src2,
  input         in_valid,
  output reg    in_ready,
  output reg    out_valid,
  output [63:0] result

);

reg [65:0] tem_result, multiplicand;
reg [32:0] multiplier;
reg [5:0]   count;
reg doing;
wire calculate_done,ready_to_doing,doing_to_done,done_to_ready,last_op;
wire [65:0] mid_result;

//state transition  ; three states
//in_ready,doing,done
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
    else if (done_to_ready)  begin
        out_valid <=1'b0;
    end
 //Done signal remains for one cycle
    else if (doing_to_done ) begin
        out_valid <= 1'b1;
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
//iterate
//update multiplicand
always @(posedge clk) begin
    if (ready_to_doing ) begin
        multiplicand <= {{33{src2[32]}},src2};
    end
    //shift left  << 1
    else if (doing) begin
        multiplicand <= {multiplicand[64:0],1'b0};
    end
end
//update multiplier
always @(posedge clk) begin
    if (ready_to_doing) begin
        multiplier <= src1;
    end
    //shift right >> 1
    else if (doing) begin 
        multiplier[32:0] <= {1'b0,multiplier[32:1]};
    end
end
//counter
always @(posedge clk) begin
    if (reset || ready_to_doing || done_to_ready) begin
        count <= 6'h0;
    end
    else if (doing) begin
        count <= count + 1'h1;
    end
end
//The last operation is sub
//Other operations are add
assign calculate_done = count[5:0] == 6'h20 && doing;
assign last_op        = count[5:0] == 6'h20 && doing;
assign mid_result = multiplicand & {66{multiplier[0]}};

// 66-bit adder
wire [65:0] adder_a;
wire [65:0] adder_b;
wire         adder_cin;
wire [65:0] adder_result;
wire        adder_cout;

assign adder_a   = last_op ? ~mid_result : mid_result;
assign adder_b   = tem_result;
assign adder_cin = last_op ? 1'h1 : 1'h0;
assign {adder_cout, adder_result} = adder_a + adder_b + {65'b0,adder_cin};

// Temporary Results or Final Results
always @(posedge clk) begin
    if (ready_to_doing) begin
        tem_result <=66'b0;
    end
    else if (doing) begin
    tem_result <= adder_result;
    end
end
assign result = tem_result[63:0];

endmodule