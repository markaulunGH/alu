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

module walloc_17bits(
    input [16:0] cin,
    output      cout,s
);
wire [13:0] c;
///////////////first////////////////
wire [4:0] first_s;
csa csa0 (.in (cin[16:14]), .cout (c[4]), .s (first_s[4]) );
csa csa1 (.in (cin[13:11]), .cout (c[3]), .s (first_s[3]) );
csa csa2 (.in (cin[10:08]), .cout (c[2]), .s (first_s[2]) );
csa csa3 (.in (cin[07:05]), .cout (c[1]), .s (first_s[1]) );
csa csa4 (.in (cin[04:02]), .cout (c[0]), .s (first_s[0]) );

///////////////secnod//////////////
wire [3:0] secnod_s;
csa csa5 (.in ({first_s[4:2]}       ), .cout (c[8]), .s (secnod_s[3]));
csa csa6 (.in ({first_s[1:0],cin[1]}), .cout (c[7]), .s (secnod_s[2]));
csa csa7 (.in ({cin[0],c[4:3]}      ), .cout (c[6]), .s (secnod_s[1]));
csa csa8 (.in ({c[2:0]}             ), .cout (c[5]), .s (secnod_s[0]));

//////////////thrid////////////////
wire [1:0] thrid_s;
csa csa9 (.in (secnod_s[3:1]        ), .cout (c[10]), .s (thrid_s[1]));
csa csaA (.in ({secnod_s[0],c[6:5]} ), .cout (c[09]), .s (thrid_s[0]));

//////////////fourth////////////////
wire [1:0] fourth_s;

csa csaB (.in ({thrid_s[1:0],c[10]} ),  .cout (c[12]), .s (fourth_s[1]));
csa csaC (.in ({c[9:7]             }),  .cout (c[11]), .s (fourth_s[0]));

//////////////fifth/////////////////
wire fifth_s;

csa csaD (.in ({fourth_s[1:0],c[11]}),  .cout (c[13]), .s (fifth_s));

///////////////sixth///////////////

csa csaE (.in ({fifth_s,c[13:12]}   ),  .cout (cout),  .s  (s));


endmodule