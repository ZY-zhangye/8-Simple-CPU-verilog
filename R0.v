//==============================================================
// 模块名称：R0
// 功能描述：8位通用寄存器R0，支持三态总线输出
//==============================================================
module R0 (
    input  wire       clk,      // 时钟信号
    input  wire       Rin,      // 写入使能信号
    input  wire       Rout,     // 输出使能信号
    inout  wire [7:0] buswires  // 8位双向总线
);

reg [7:0] R0_reg; // R0寄存器存储单元
reg       enable; // 三态输出控制信号

// 时序逻辑：根据Rin和Rout控制寄存器读写和三态输出
always @ (posedge clk) begin
    if (Rin) begin
        R0_reg <= buswires; // 从总线读取数据到R0
        enable <= 0;        // 禁止总线输出
    end
    if (Rout) begin
        enable <= 1;        // 允许R0输出到总线
    end
    if (!Rin && !Rout) begin
        enable <= 0;        // 禁止总线输出
    end
end

// 三态总线输出：enable有效时输出R0_reg，否则高阻态
assign buswires = enable ? R0_reg : 8'bz;

endmodule