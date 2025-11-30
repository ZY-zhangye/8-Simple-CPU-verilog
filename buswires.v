//==============================================================
// 模块名称：buswires
// 功能描述：8位三态总线驱动模块，根据控制信号Entern决定是否将Data输出到总线BusWires
//==============================================================
module buswires (
    input  wire [7:0] Data,    // 输入数据
    input  wire       Entern,  // 三态控制信号，高电平时输出Data到总线
    inout  wire [7:0] BusWires // 8位双向总线
);

// 当Entern为高电平时，将Data输出到总线；否则总线处于高阻态
assign BusWires = Entern ? Data : 8'bz;

endmodule