//==============================================================
// 模块名称：top
// 功能描述：处理器顶层模块，连接ALU、控制单元、寄存器组和总线
//==============================================================
module top (
    input  wire       clk,       // 时钟信号
    input  wire       reset,     // 复位信号
    input  wire       Run,       // 启动信号
    input  wire [1:0] Rx,        // 源寄存器选择
    input  wire [1:0] Ry,        // 目标寄存器选择
    input  wire [1:0] Fun,       // 功能选择
    input  wire [7:0] Data,      // 外部输入数据
    output wire       Done,      // 操作完成标志
    inout  wire [7:0] BusWires   // 8位双向总线
);

// 控制信号连线
wire Rin0, Rin1, Rin2, Rin3;
wire Rout0, Rout1, Rout2, Rout3;
wire Ain, Gin, Gout, AddSub, Entern;

// 实例化ALU模块
ALU alu (
    .clk(clk),
    .Ain(Ain),
    .Gin(Gin),
    .AddSub(AddSub),
    .Gout(Gout),
    .buswires(BusWires)
);

// 实例化控制器模块
control controller (
    .clk(clk),
    .reset(reset),
    .Run(Run),
    .Rx(Rx),
    .Ry(Ry),
    .Fun(Fun),
    .Done(Done),
    .Rin0(Rin0),
    .Rin1(Rin1),
    .Rin2(Rin2),
    .Rin3(Rin3),
    .Rout0(Rout0),
    .Rout1(Rout1),
    .Rout2(Rout2),
    .Rout3(Rout3),
    .Ain(Ain),
    .Gin(Gin),
    .Gout(Gout),
    .AddSub(AddSub),
    .Entern(Entern)
);

// 实例化总线驱动模块
buswires buswires_inst (
    .Data(Data),
    .Entern(Entern),
    .BusWires(BusWires)
);

// 实例化4个通用寄存器
R0 r0 (
    .clk(clk),
    .Rin(Rin0),
    .Rout(Rout0),
    .buswires(BusWires)
);

R0 r1 (
    .clk(clk),
    .Rin(Rin1),
    .Rout(Rout1),
    .buswires(BusWires)
);

R0 r2 (
    .clk(clk),
    .Rin(Rin2),
    .Rout(Rout2),
    .buswires(BusWires)
);

R0 r3 (
    .clk(clk),
    .Rin(Rin3),
    .Rout(Rout3),
    .buswires(BusWires)
);

endmodule