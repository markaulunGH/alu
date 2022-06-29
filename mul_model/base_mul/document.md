32位迭代乘法器

主要参考资料：《 计算机体系结构基础  （第三版》，《CPU设计实战》

对外接口

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

三个状态

```verilog
//该乘法器一共有三个状态，三个状态互相排斥
//in_ready == 1表示该乘法器已经准备好，可以往里面输入数据
//doing==1 表示该乘法器正在工作，不接受输入新的数据
//out_valid == 1 表示该乘法器已经完成工作，输出的数据就是正确的结果，这个信号只会保持一个周期
reg in_ready,out_valid,doing;
```

三个转换条件

```
wire ready_to_doing,doing_to_done,done_to_ready;
```

