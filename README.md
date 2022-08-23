

需要实现的乘除法模块的接口如下



| 信号       | 方向   | 位宽 | 说明                                                         |
| ---------- | ------ | ---- | ------------------------------------------------------------ |
| clock      | input  | 1    | 时钟信号                                                     |
| reset      | input  | 1    | 复位信号（高有效）                                           |
| dividend   | input  | xlen | 被除数（xlen表示要实现的位数，ysyx中是64）                   |
| divisor    | input  | xlen | 除数                                                         |
| div_valid  | input  | 1    | 为高表示输入的数据有效，如果没有新的除法输入，在除法被接受的下一个周期要置低 |
| divw       | input  | 1    | 为高表示输入的是32位乘法                                     |
| div_signed | input  | 1    | 表示是不是有符号除法，为高表示是有符号除法                   |
| flush      | input  | 1    | 为高表示要取消除法（修改一下除法器状态就行）                 |
| div_ready  | output | 1    | 为高表示除法器空闲，可以输入数据                             |
| out_valid  | output | 1    | 为高表示除法器输出了有效结果                                 |
| quotient   | output | xlen | 余数                                                         |
| remainder  | output | xlen | 除数                                                         |



乘法器端口信号

| 信号         | 方向   | 位宽 | 说明                                                         |
| ------------ | ------ | ---- | ------------------------------------------------------------ |
| clock        | input  | 1    | 时钟信号                                                     |
| reset        | input  | 1    | 复位信号（高有效）                                           |
| mul_valid    | input  | 1    | 为高表示输入的数据有效，如果没有新的乘法输入，在乘法被接受的下一个周期要置低 |
| flush        | input  | 1    | 为高表示取消乘法                                             |
| mulw         | input  | 1    | 为高表示是32位乘法                                           |
| mul_signed   | input  | 2    | 2’b11（signed x signed）；2’b10（signed x unsigned）；2’b00（unsigned x unsigned）； |
| multiplicand | input  | xlen | 被乘数，xlen表示乘法器位数（ysyx中xlen=64）                  |
| multiplier   | input  | xlen | 乘数                                                         |
| mul_ready    | output | 1    | 为高表示乘法器准备好，表示可以输入数据                       |
| out_valid    | output | 1    | 为高表示乘法器输出的结果有效                                 |
| result_hi    | output | xlen | 高xlen结果                                                   |
| result_lo    | output | xlen | 低xlen结果                                                   |



目前已经实现的模块



乘法

| 文件夹        | 类型                                    |
| ------------- | --------------------------------------- |
| base_mul      | 32bit一位迭代乘法                       |
| booth_mul     | 32bit，booth两位迭代乘法                |
| Wallace_booth | 32bit，booth两位Xwalloc树乘法（两周期） |



除法

| 文件夹   | 类型               |
| -------- | ------------------ |
| base_div | 32bit,一位迭代除法 |
|          |                    |
|          |                    |



