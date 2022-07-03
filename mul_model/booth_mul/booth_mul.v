module boothmul# (parameter COMPUTER_WIDTH=32,parameter WIDTH =COMPUTER_WIDTH+2)
(
  input               clk           ,
  input               reset         ,
  input  [32:0] src1,
  input  [32:0] src2,
  input         in_valid,
  output reg    in_ready,
  output reg    out_valid,
  output [63:0] result

);
//68bits
//32+1+1+1bits
//两位booth要补补够倍数
reg [WIDTH*2-1:0] tem_result, multiplicand;
reg [WIDTH:0] multiplier;
reg [4:0]   count;
reg doing;
wire calculate_done,ready_to_doing,doing_to_done,done_to_ready,last_op;
wire [WIDTH*2-1:0] mid_result;

//state transition  ; three states
//in_ready,doing,done
assign ready_to_doing = in_valid && in_ready;
assign doing_to_done  = calculate_done;
assign done_to_ready  = out_valid;
//assign result         = tem_result;
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
        multiplicand <= {{WIDTH{src2[COMPUTER_WIDTH]}},src2};
    end
    //shift left  << 2
    else if (doing) begin
        multiplicand <= {multiplicand[WIDTH*2-3:0],2'b0};
    end
end
//update multiplier
always @(posedge clk) begin
    if (ready_to_doing) begin
        multiplier <= {src1[COMPUTER_WIDTH],src1,1'b0};
    end
    //shift right >> 2
    else if (doing) begin 
        multiplier <= {2'b0,multiplier[WIDTH:2]};
    end
end
//counter
always @(posedge clk) begin
    if (reset || ready_to_doing || done_to_ready) begin
        count <= 5'h0;
    end
    else if (doing) begin
        count <= count + 1'h1;
    end
end
//The last operation is sub
//Other operations are add
assign calculate_done = count[4:0] == 5'h10 && doing;
assign last_op        = count[4:0] == 5'h10 && doing;
//assign mid_result = multiplicand & {66{multiplier[0]}};
wire partial_cout;
wire double;
booth_partial  #(.WIDTH (WIDTH))
booth_partial   (
    .x_src  (multiplicand),
    .y_src   (multiplier[2:0]),
    .p_result (mid_result),
    .double    (double),
    .cout      (partial_cout)
);


// 66-bit adder
wire [WIDTH*2-1:0] adder_a;
wire [WIDTH*2-1:0] adder_b;
wire [1:0]        adder_cin;
wire [WIDTH*2-1:0] adder_result;
wire        adder_cout;

assign adder_a   = mid_result;
assign adder_b   = tem_result;
assign adder_cin = {1'b0,partial_cout};
assign {adder_cout, adder_result} = adder_a + adder_b + {{WIDTH*2-3{1'b0}},adder_cin};

// Temporary Results or Final Results
always @(posedge clk) begin
    if (ready_to_doing) begin
        tem_result <={WIDTH*2-1{1'b0}};
    end
    else if (doing) begin
    tem_result <= adder_result;
    end
end
assign result = tem_result[63:0];



endmodule

module booth_sel(
  input [2:0] src,
  output [3:0] sel

);
///y+1,y,y-1///
wire y_add,y,y_sub;
wire sel_negative,sel_double_negative,sel_positive,sel_double_positive;

assign {y_add,y,y_sub} = src;

assign sel_negative =  y_add & (y & ~y_sub | ~y & y_sub);
assign sel_positive = ~y_add & (y & ~y_sub | ~y & y_sub);
assign sel_double_negative =  y_add & ~y & ~y_sub;
assign sel_double_positive = ~y_add &  y &  y_sub;

assign sel={sel_negative,sel_positive,sel_double_negative,sel_double_positive};
endmodule

module booth_result_sel(
  input [3:0] sel,
  input [1:0] src,
  output      p 
);
////x,x-1////
wire x,x_sub;
wire sel_negative,sel_double_negative,sel_positive,sel_double_positive;
assign {sel_negative,sel_positive,sel_double_negative,sel_double_positive}=sel;
assign {x,x_sub} =src;
assign p = ~(~(sel_negative & ~x) & ~(sel_double_negative & ~x_sub) 
           & ~(sel_positive & x ) & ~(sel_double_positive &  x_sub));

endmodule

module booth_partial
#(
    parameter WIDTH = 4
)

(
  input [2*WIDTH-1:0]  x_src,
  input [2:0] y_src,
  output [2*WIDTH-1:0]   p_result,
  output                double,
  output                cout 
);

///y+1,y,y-1///
wire y_add,y,y_sub;

assign {y_add,y,y_sub} = y_src;
wire [3:0] sel;
wire sel_negative,sel_double_negative,sel_positive,sel_double_positive;
assign {sel_negative,sel_positive,sel_double_negative,sel_double_positive}=sel;
assign cout=sel_negative || sel_double_negative;
booth_sel booth_sel(
    .src    (y_src),
    .sel    (sel)
);

booth_result_sel partial0(.sel (sel), .src ({x_src[0],1'b0}), .p (p_result[0]));
genvar x;
generate for ( x =1;x<WIDTH*2;x=x+1) begin : gen_partial
    booth_result_sel partial(.sel (sel), .src (x_src[x:x-1]), .p (p_result[x]));
end endgenerate
//assign p_result[2*WIDTH-1:WIDTH] = {WIDTH{1'b0}};
assign double = sel_double_negative ;

endmodule

