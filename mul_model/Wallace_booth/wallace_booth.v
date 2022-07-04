module csa(
  input [2:0] in,
  output cout,s

);
wire a,b,cin;
assign a=in[2];
assign b=in[1];
assign cin=in[0];
assign s = a ^ b ^ cin;
assign cout = a & b | b & cin | a & cin;
endmodule



module partial_34bits(
  input [67:0] x,
  input [33:0] y,

  output [16:0] cout,
  output [67:0] partial_out00,partial_out01,partial_out02,partial_out03,
                partial_out04,partial_out05,partial_out06,partial_out07,
                partial_out08,partial_out09,partial_out10,partial_out11,
                partial_out12,partial_out13,partial_out14,partial_out15,
                partial_out16
);


booth_partial part00 (.x_src (x), .y_src ({y[1:0],1'b0}), .p_result (partial_out00), .cout (cout[00]));
booth_partial part01 (.x_src (x), .y_src (y[03:01]), .p_result (partial_out01), .cout (cout[01]));
booth_partial part02 (.x_src (x), .y_src (y[05:03]), .p_result (partial_out02), .cout (cout[02]));
booth_partial part03 (.x_src (x), .y_src (y[07:05]), .p_result (partial_out03), .cout (cout[03]));
booth_partial part04 (.x_src (x), .y_src (y[09:07]), .p_result (partial_out04), .cout (cout[04]));
booth_partial part05 (.x_src (x), .y_src (y[11:09]), .p_result (partial_out05), .cout (cout[05]));
booth_partial part06 (.x_src (x), .y_src (y[13:11]), .p_result (partial_out06), .cout (cout[06]));
booth_partial part07 (.x_src (x), .y_src (y[15:13]), .p_result (partial_out07), .cout (cout[07]));
booth_partial part08 (.x_src (x), .y_src (y[17:15]), .p_result (partial_out08), .cout (cout[08]));
booth_partial part09 (.x_src (x), .y_src (y[19:17]), .p_result (partial_out09), .cout (cout[09]));
booth_partial part10 (.x_src (x), .y_src (y[21:19]), .p_result (partial_out10), .cout (cout[10]));
booth_partial part11 (.x_src (x), .y_src (y[23:21]), .p_result (partial_out11), .cout (cout[11]));
booth_partial part12 (.x_src (x), .y_src (y[25:23]), .p_result (partial_out12), .cout (cout[12]));
booth_partial part13 (.x_src (x), .y_src (y[27:25]), .p_result (partial_out13), .cout (cout[13]));
booth_partial part14 (.x_src (x), .y_src (y[29:27]), .p_result (partial_out14), .cout (cout[14]));
booth_partial part15 (.x_src (x), .y_src (y[31:29]), .p_result (partial_out15), .cout (cout[15]));
booth_partial part16 (.x_src (x), .y_src (y[33:31]), .p_result (partial_out16), .cout (cout[16]));


endmodule

module switch_17x68bits(
   input [1155:0] part_group,

  /*  output [16:0]
                sw_out00,sw_out01,sw_out02,sw_out03,sw_out04,sw_out05,sw_out06,sw_out07,
                sw_out08,sw_out09,sw_out10,sw_out11,sw_out12,sw_out13,sw_out14,sw_out15,
                sw_out16,sw_out17,sw_out18,sw_out19,sw_out20,sw_out21,sw_out22,sw_out23,
                sw_out24,sw_out25,sw_out26,sw_out27,sw_out28,sw_out29,sw_out30,sw_out31,
                sw_out32,sw_out33,sw_out34,sw_out35,sw_out36,sw_out37,sw_out38,sw_out39,
                sw_out40,sw_out41,sw_out42,sw_out43,sw_out44,sw_out45,sw_out46,sw_out47,
                sw_out48,sw_out49,sw_out50,sw_out51,sw_out52,sw_out53,sw_out54,sw_out55,
                sw_out56,sw_out57,sw_out58,sw_out59,sw_out60,sw_out61,sw_out62,sw_out63,
                sw_out64,sw_out65,sw_out66,sw_out67*/
      output [1155:0] sw_group
);

wire [67:0] po16,po15,po14,po13,po12,po11,po10,po09,po08,po07,po06,po05,po04,po03,po02,po01,po00;
assign {po16,po15,po14,po13,po12,po11,po10,po09,po08,po07,po06,po05,po04,po03,po02,po01,po00} = part_group;

genvar x;
generate for ( x =0;x<68;x=x+1) begin : gen_switch
    assign sw_group[(x+1)*17-1:x] = {po16[x],po15[x],po14[x],po13[x],po12[x],po11[x],po10[x],po09[x],
                                     po08[x],po07[x],po05[x],po04[x],po03[x],po02[x],po01[x],po00[x]};
end endgenerate


endmodule

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
        in_ready <=1;
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
    multiplicand <= {{WIDTH{src2[COMPUTER_WIDTH]}},src1};
    multiplier <= {src1[COMPUTER_WIDTH],src1,1'b0};
  end
end



//////////////////////////////////first_buf/////////////////////////////////
////////booth_part_34bits//////////////
wire [1155:0] part_group;
wire [16:0]   part_cout;

booth_partial part0 (.x_src (multiplicand), .y_src({multiplier[1:0]}), 
                        .p_result (part_group[67:0]), .cout(part_cout[0]));
genvar x;
generate for ( x =1;x<17;x=x+1) begin : gen_partial
booth_partial part (.x_src (multiplicand), .y_src({multiplier[(x+1)*2:x*2]}), 
                    .p_result (part_group[(x+1)*68:x*68]), .cout(part_cout[x]));
    
end endgenerate

//////////switch//////////
wire [1155:0] swo_group; 
switch_17x68bits switch (.part_group (part_group), .sw_group (swo_group));

//////////walloc_tree////////////
wire [937:0] wt_cout;
wire [66:0]  wt_c;
wire [67:0]  wt_s;

walloc_17bits walloc00 (.src_in (swo_group[16:0]), .cin({part_cout[13:0]}), 
                    .cout_group (),  .cout(), .s (wt_s[67]));

genvar y;
generate for ( y =1;y<67;y=y+1) begin : gen_walloc
walloc_17bits walloc  (.src_in (swo_group[(x+1)*17-1:x*17]), .cin({wt_cout[x*14-1:(x-1)*14]}), 
                    .cout_group (wt_cout[(x+1)*14-1:x*14]),  .cout(wt_c[x]), .s (wt_s[x]));
end endgenerate
walloc_17bits walloc67(.src_in (swo_group[1155:1087]), .cin({wt_cout[937:924]}), 
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