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
    assign sw_group[(x+1)*17-1:x*17] = {po16[x],po15[x],po14[x],po13[x],po12[x],po11[x],po10[x],po09[x],
                                     po08[x],po07[x],po06[x],po05[x],po04[x],po03[x],po02[x],po01[x],po00[x]};
end endgenerate


endmodule