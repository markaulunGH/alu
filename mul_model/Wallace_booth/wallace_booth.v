


module booth_walloc# (parameter COMPUTER_WIDTH=32,parameter WIDTH =COMPUTER_WIDTH+2)
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

reg [WIDTH-1:0] multiplier;
reg [WIDTH*2-1:0] multiplicand;
reg first_doing;
wire ready_to_doing;
assign ready_to_doing = in_ready && in_valid;
always@(posedge clk ) begin
      if (reset ) begin
        in_ready <=1'b0;
      end
      else begin
        in_ready<=1'b1;
      end

      if (ready_to_doing) begin
        first_doing<=1'b1;
      end
      else begin
        first_doing <= 1'b0;
      end

      out_valid <= first_doing;

end

always @(posedge clk ) begin
  if (ready_to_doing) begin
    multiplicand <= {{WIDTH{src1[COMPUTER_WIDTH]}},src1};
    multiplier <= {src2[COMPUTER_WIDTH],src2};
  end
end



//////////////////////////////////first_buf/////////////////////////////////
////////booth_part_34bits//////////////
wire [1155:0] part_group;
wire [16:0]   part_cout;

booth_partial part0 (.x_src (multiplicand), .y_src({multiplier[1:0],1'b0}), 
                        .p_result (part_group[67:0]), .cout(part_cout[0]));
genvar x;
generate for ( x =1;x<17;x=x+1) begin : gen_walloc_partial
booth_partial part (
                    .x_src ({multiplicand[2*WIDTH-1-2*x:0],
                    {2*x{1'b0}}}), 
                    .y_src({multiplier[(x+1)*2-1:x*2-1]}), 
                    .p_result (part_group[(x+1)*68-1:x*68]), .cout(part_cout[x]));
    
end endgenerate

//////////switch//////////
wire [1155:0] swo_group; 
switch_17x68bits switch (.part_group (part_group), .sw_group (swo_group));

//////////walloc_tree////////////
wire [937:0] wt_cout;//14bitsx68
wire [66:0]  wt_c;
wire [67:0]  wt_s;

walloc_17bits walloc00 (.src_in (swo_group[16:0]), .cin({part_cout[13:0]}), 
                    .cout_group (wt_cout[13:0]),  .cout(wt_c[0]), .s (wt_s[0]));

genvar y;
generate for ( y =1;y<67;y=y+1) begin : gen_walloc
walloc_17bits walloc  (.src_in (swo_group[(y+1)*17-1:y*17]), .cin({wt_cout[y*14-1:(y-1)*14]}), 
                    .cout_group (wt_cout[(y+1)*14-1:y*14]),  .cout(wt_c[y]), .s (wt_s[y]));
end endgenerate
walloc_17bits walloc67(.src_in (swo_group[1155:1139]), .cin({wt_cout[937:924]}), 
                    .cout_group (),  .cout(), .s (wt_s[67]));

//////////////////////////////////second_buf/////////////////////////////////////
reg [67:0] wt_s_buf,wt_c_buf;
reg  part_next_highest_bit;

always@(posedge clk ) begin
  if (first_doing) begin
    wt_c_buf <= {wt_c,part_cout[14]};
    wt_s_buf <= {wt_s};
    part_next_highest_bit <= part_cout[15];
  end
end

// WIDTH*2-bit adder
wire [WIDTH*2-1:0] adder_a;
wire [WIDTH*2-1:0] adder_b;
wire              adder_cin;
wire [WIDTH*2-1:0] adder_result;
wire        adder_cout;

assign adder_a   = wt_c_buf;
assign adder_b   = wt_s_buf;
assign adder_cin = part_next_highest_bit;
assign {adder_cout, adder_result} = adder_a + adder_b + {{WIDTH*2-2{1'b0}},adder_cin};
////////////output//////////////
assign result = adder_result[COMPUTER_WIDTH*2-1:0];

endmodule