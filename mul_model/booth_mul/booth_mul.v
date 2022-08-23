module boothmul# (parameter COMPUTER_WIDTH=32,parameter WIDTH =COMPUTER_WIDTH+2)
(
  input               clk           ,
  input               reset         ,
  input  [COMPUTER_WIDTH:0] src1,
  input  [COMPUTER_WIDTH:0] src2,
  input         in_valid,
  output reg    in_ready,
  output reg    out_valid,
  output [COMPUTER_WIDTH*2-1:0] result

);
//68bits
//32+1+1+1bits
//两位booth要补补够倍数
reg [WIDTH*2-1:0] tem_result, multiplicand;
reg [WIDTH:0] multiplier;
reg doing;
reg [4:0] count;
wire calculate_done,ready_to_doing,doing_to_done,done_to_ready;
wire [WIDTH*2-1:0] mid_result;

//state transition  ; three states
//in_ready,doing,done
assign ready_to_doing = in_valid && in_ready;
assign doing_to_done  = calculate_done;
assign done_to_ready  = out_valid;
always@(posedge clk) begin
    if (reset|| ready_to_doing) begin
        count <=5'b0;
    end
    else if (doing) begin
        count <= count +1;
    end
end
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
    // lowest bit is 0
    if (ready_to_doing) begin
        multiplier <= {src1[COMPUTER_WIDTH],src1,1'b0};
    end
    //set lowest bit to zero    
    else if (doing && count == 5'h10) begin
         multiplier <= {2'b0,multiplier[WIDTH:3],1'b0};
    end
    //shift right >> 2
    else if (doing) begin 
        multiplier <= {2'b0,multiplier[WIDTH:2]};
    end
end
//Don't care about the lowest bit
assign calculate_done = doing && multiplier[WIDTH:1+2] == {WIDTH-2{1'b0}};//

wire partial_cout;
booth_partial  #(.WIDTH (WIDTH))
booth_partial   (
    .x_src  (multiplicand),
    .y_src   (multiplier[2:0]),
    .p_result (mid_result),
    .cout      (partial_cout)
);


// WIDTH*2-bit adder
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
assign result = adder_result[63:0];
//assign result = tem_result[63:0];
endmodule
