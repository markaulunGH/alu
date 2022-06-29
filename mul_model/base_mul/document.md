# 32位迭代乘法器

主要参考资料：《 计算机体系结构基础  （第三版》（第八章），《CPU设计实战》（第五章）

## 对外接口

````verilog
  input         clk           ,
  input         reset         ,
//src1,src2为输入的乘数和被乘数 
input  [31:0] src1,
  input  [31:0] src2,
//in_valid表示输入的数据是有效的
  input         in_valid,
//in_ready表示乘法器目前是空闲的，可以输入数据进行计算
//握手，只有当in_valid和in_ready同时有效的时候才能说明乘法器正确接收了数据并准备开始计算
  output        in_ready,
//out_valid表示乘法的结果已经计算完毕，该信号只会保持一个周期，也就是说只有当out_valid为1的时候
//输出的才是正确的结果
  output        out_valid,
//输出的64位结果
  output [63:0] result,
````

## 三个状态

```verilog
//该乘法器一共有三个状态，三个状态互相排斥
//in_ready == 1表示该乘法器已经准备好，可以往里面输入数据
//doing==1 表示该乘法器正在工作，不接受输入新的数据
//只有in_ready&&in_valid==1时才表示除法器已经接受了数据
//out_valid == 1 表示该乘法器已经完成工作，输出的数据就是正确的结果，这个信号只会保持一个周期
reg in_ready,out_valid,doing;
```

## 三个转换条件

```verilog
/*ready_to_doing表示乘法器空闲且输入了有效数据*/
/*doing_to_done 表示乘法器快要完成计算*/
/*done_to_ready 表示乘法器已经输出了正确结果，正在为新的乘法做准备*/
wire ready_to_doing,doing_to_done,done_to_ready;
assign ready_to_doing = in_ready && in_valid;
assign doing_to_done  =  calculate_done;
assign done_to_ready  = out_valid;
assign calculate_done = doing &&  count == 6'h20;

```

## 主要迭代步骤

1. 将乘法结果设置为0.
2. 在每个时钟周期，判断乘数的最低位，如果值是1，则将被乘数加到乘法结果。如果值为零就不进行加法操作。然后将乘数右移一位，将被乘数左移一位。
3. 共执行32次操作，最后一次操作为减法（有符号）。

## 支持无符号乘法

第一种，分别实例化有符号乘法和无符号乘法模块（X)

第二种，改造一下乘法器让其支持有符号和无符号，具体方法：将32位的数额外扩展一位，有符号数将这位设置成符号位，无符号数则将这位设置成0。这样需要扩展一下加法器的位数。

第三种，可以额外增加一位用于表示是不是有符号乘法，无符号和有符号的差别应该是最后一步（是加还是减法）存在差别。

## 能不能更快？占用面积更小？

如果是64bits乘法，那至少需要128bit的加法器，这个时候可以考虑一下器件的复用。

建议学有余力的同学可以去实现一下booth两位乘法+华莱士树。这里不建议在流片的时候使用（占用的面积过大）。

