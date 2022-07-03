关于超前进位加法器，最后的结果不是在顶层输出的，最后的结果是在第一层输出的，就是相当于去绕了一圈然后原路返回。

Booth的补码乘法器（以8位为例子）

Booth一位变换
$$
\quad -y_7*2^7+y_6*2^6+y_5*2^5+y_4*2^4+y_3*2^3+y_2*2^2+y_1*2^1+y_0*2^0\\
  = -y_7*2^7-y_6*2^6-y_5*2^5-y_4*2^4-y_3*2^3-y_2*2^2-y_1*2^1-y_0*2^0\\
  \quad +y_6*2^7+y_5*2^6+y_4*2^5+y_3*2^4+y_2*2^3+y_1*2^2+y_0*2^1\\
  =(y_6-y_7)*2^7+(y_5-y_6)*2^6+(y_4-y_5)*2^5+(y_3-y_4)*2^4+(y_2-y_3)*2^3+(y_1-y_2)*2^2+(y_0-y_1)*2^1+(y_{-1}-y_0)*2^0
$$
其中的$y_{-1}$取值为0， 经过变换，公式变得更加规整，不再需要专门对最后一次部分积采用补码 减法，更适合硬件实现。这个新公式被称为 Booth 一位乘算法 。

 为了实现Booth一位乘算法，需要根据乘数的最末两位来确定如何将被乘数累加到结果中，再 将乘数和被乘数移一位。根据算法公式，很容易得出它的规则 

| $y_i$ | $y_{i-1}$ | 操作                     |
| ----- | --------- | ------------------------ |
| 0     | 0         | 不需要加(+0)             |
| 0     | 1         | 补码加X（$+[X]_补\quad$) |
| 1     | 0         | 补码减X（$-[X]_补\quad$) |
| 1     | 1         | 不需要加（+0）           |

 注意算法开始时，要**隐含地在乘数最右侧补**一个 $y_{-1}$的值（补0）。(就是弄得上下对齐)

两位Booth乘法

 补码加法器面积大、电路延迟长，限制了硬件乘法器的计算速度，因此重新对补码乘法公式进行 变换，得到 Booth 两位乘算法 
$$
\quad -y_7*2^7+y_6*2^6+y_5*2^5+y_4*2^4+y_3*2^3+y_2*2^2+y_1*2^1+y_0*2^0\\
  = -2*y_7*2^6+y_6*2^6+y_5*2^6-2*y_5*2^4+y_4*2^4+y_3*2^4\\
\quad  -2*y_3*y2+y_2*2^2+y_1*2^2-2*y_1*2^0+y_0*2^0+y_{-1}*2^0 \\
  =(y_5+y_6-2*y_7)*2^6+(y_3+y_4-2*y_5)*2^4+(y_1+y_2-2*y_3)*2^2+(y_{-1}+y_0-2*y_1)*2^0
$$
 根据 Booth 两位乘算法，需要**每次扫描 3 位**的乘数，并在每次累加完成后，将被乘数和乘数移 2 位。根据算法公式，可以推导出操作的方式。注意被扫描的 3 位是当前操作阶数 i 加 上其左右各 1 位。 (举例子，如果是8位的数字，起始位为0位。那么i就为0，2，4，6)

booth两位运算规则

| $y_{i+1}$ | $y_i$ | $y_{i-1}$ | 操作                          |
| --------- | ----- | --------- | ----------------------------- |
| 0         | 0     | 0         | 不需要加（+0）                |
| 0         | 0     | 1         | 补码加X（$+[X]_补\quad$)      |
| 0         | 1     | 0         | 补码加X（$+[X]_补\quad$)      |
| 0         | 1     | 1         | 补码加2X（$+[X]_补\quad$左移) |
| 1         | 0     | 0         | 补码减2X（$-[X]_补\quad$左移) |
| 1         | 0     | 1         | 补码减X（$-[X]_补\quad$)      |
| 1         | 1     | 0         | 补码减X（$-[X]_补\quad$)      |
| 1         | 1     | 1         | 不需要加（+0）                |

 如果使用 Booth 两位乘算法，计算 N 位的补码乘法时，只需要 N/2‑1 次加法，如果使用移位加 策略，则需要 N/2 个时钟周期来完成计算。 

 Booth 乘法的核心是部分积的生成，共需要生成 N/2 个部分积。每个部分积与 [X]补 相关，总共 有‑X、‑2X、+X、+2X和0五种可能，而其中减去[X]补 的操作，可以视作加上按位取反的[X]补 再末位加1。  

假设$[X]_补\quad$的二进制格式可以写成$x_7x_6x_5x_4x_3x_2x_1x_0$假设部分积P等于$p_7p_6p_5p_4p_3p_2p_1p_0+c$可以有如下情况

| $p_i$== | ~$x_i$     | 选择-x  |
| ------- | ---------- | ------- |
|         | ~$x_{i-1}$ | 选择-2x |
|         | $x_i$      | 选择+x  |
|         | ~$x_{i-1}$ | 选择+2x |
|         | 0          | 选择0   |
|         |            |         |

 当部分积的选择为 2X 时，可以视作 X 输入左移 1 位，此时 $p_i$就与 $x_{i-1}$ 相等。如果部分积的选择 是‑X 或者‑2X，则此处对 $x_i$ 或者 $x_{i-1}$取反，并设置最后的末位进位 c 为 1。  

根据卡诺图分析可以得到每一位$p_i$的表达式
$$
p_i=\sim (\sim(S_{-x}\& \sim x_i) \& \sim (S_{-2x} \& \sim x_{i-1}) \& \sim (S_{+x} \& x_i) \& \sim (S_{2x} \& x_{i-1}))
$$

```verilog
assign p = ~(~(sel_negative & ~x) & ~(sel_double_negative & ~x_sub) 
           & ~(sel_positive & x ) & ~(sel_double_positive &  x_sub));
```

booth选择信号的生成

```verilog
///y+1,y,y-1///
wire y_add,y,y_sub;
wire sel_negative,sel_double_negative,sel_positive,sel_double_positive;

assign {y_add,y,y_sub} = src;

assign sel_negative =  y_add & (y & ~y_sub | ~y & y_sub);
assign sel_positive = ~y_add & (y & ~y_sub | ~y & y_sub);
assign sel_double_negative =  y_add & ~y & ~y_sub;
assign sel_double_positive = ~y_add &  y &  y_sub;
```

Booth 部分积生成模块

```verilog
module booth_partial
#(
    parameter WIDTH = 4
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
    //选择信号生成
booth_sel booth_sel(.src    (y_src), .sel    (sel));
//结果选择逻辑
 //使用generate生成p_i
booth_result_sel partial0(.sel (sel), .src ({x_src[0],1'b0}), .p (p_result[0]));
genvar x;
generate for ( x =1;x<WIDTH*2;x=x+1) begin : gen_partial
    booth_result_sel partial(.sel (sel), .src (x_src[x:x-1]), .p (p_result[x]));
end endgenerate
```



可以用移位加实现Booth两位乘法， 乘法操作开始时，乘数右侧需要补 1 位的 0，而结果需要预置为全 0。在每个时钟周期的计算  结束后，乘数算术右移 2 位，而被乘数左移 2 位，直到乘数为全 0 时，乘法结束。对于 N 位数的补 码乘法，操作可以在 N/2 个时钟周期内完成，并有可能提前结束。在这个结构中，被乘数、结果、 加法器和 Booth 核心的宽度都为 2N 位 。

注意上面使用的有符号数，要想让其支持无符号数，需要额外扩展两位符号位，对于无符号数只需补零即可。为什么不能扩展一位呢？我的理解是这是两位booth，一次扫描的是3位，要是只扩展一位，到最后的时候可扫描的只有两位，会导致计算结果不正确。

两位Booth的移位加乘法状态机比一位移位的迭代乘法还要简单，可以简单的实现提前退出。

```
//输入输出端口和前面的一位迭代乘法一致
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
```

