
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
    parameter WIDTH = 34
)

(
  input [2*WIDTH-1:0]  x_src,
  input [2:0] y_src,
  output [2*WIDTH-1:0]   p_result,
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

endmodule

