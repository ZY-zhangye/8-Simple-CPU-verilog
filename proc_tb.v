`timescale 1ns/1ps

//==============================================================
// 模块名称：proc_tb
// 功能描述：处理器顶层模块的测试平台
//==============================================================
module proc_tb();

    // 定义参数，与被测模块保持一致
    parameter n = 8;

    // 输入信号声明
    reg [7:0] Data;      // 外部输入数据
    reg       Reset;     // 复位信号
    reg       Run;       // 启动信号
    reg       Clock;     // 时钟信号
    reg [1:0] Fun;       // 功能选择
    reg [1:0] Rx;        // 源寄存器选择
    reg [1:0] Ry;        // 目标寄存器选择

    // 输出信号声明
    wire [7:0] BusWires; // 总线信号
    wire       Done;     // 完成标志

    // 实例化被测试的top模块
    top dut (
        .Data(Data),
        .reset(Reset),
        .Run(Run),
        .clk(Clock),
        .Fun(Fun),
        .Rx(Rx),
        .Ry(Ry),
        .Done(Done),
        .BusWires(BusWires)
    );

    // 时钟生成逻辑，周期10ns
    always #5 Clock = ~Clock;

    // 测试激励产生部分
    initial begin
        // 初始化所有信号
        Data  = 0;
        Reset = 1;
        Run   = 0;
        Clock = 0;
        Fun   = 0;
        Rx    = 0;
        Ry    = 0;

        // 复位操作，保持复位高电平一段时间
        #10;
        Reset = 0;

        // 第一步：将0x33送入R0寄存器
        #10;
        Data = 8'h33;
        Fun  = 0;
        Rx   = 0;
        Ry   = 0;
        Run  = 1;
        #10;
        Run  = 0;

        // 第二步：将0x22送入R1寄存器
        #10;
        Data = 8'h22;
        Fun  = 0;
        Rx   = 1;
        Ry   = 0;
        Run  = 1;
        #10;
        Run  = 0;

        // 第三步：将0x11送入R2寄存器
        #10;
        Data = 8'h11;
        Fun  = 0;
        Rx   = 2;
        Ry   = 0;
        Run  = 1;
        #10;
        Run  = 0;

        // 第四步：执行R0 + R1运算并将结果保存到R0
        #10;
        Fun  = 2;
        Rx   = 0;
        Ry   = 1;
        Run  = 1;
        #10;
        Run  = 0;

        // 第五步：执行R0移入R3
        #30;
        Fun  = 1;
        Rx   = 3;
        Ry   = 0;
        Run  = 1;
        #10;
        Run  = 0;

        // 第六步：执行R1 - R2运算并将结果保存到R1
        #50;
        Fun  = 3;
        Rx   = 1;
        Ry   = 2;
        Run  = 1;
        #10;
        Run  = 0;

        // 持续运行一段时间，观察输出和状态变化并结束仿真
        #40 $finish;
    end

endmodule