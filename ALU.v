//==============================================================
// 模块名称：ALU
// 功能描述：8位算术逻辑单元，支持加法和减法运算，并通过三态总线与外部通信
//==============================================================
module ALU (
    input  wire       clk,      // 时钟信号
    input  wire       Ain,      // A寄存器使能信号
    input  wire       Gin,      // G寄存器使能信号
    input  wire       AddSub,   // 运算选择信号，1-加法，0-减法
    input  wire       Gout,     // G寄存器输出使能信号
    inout  wire [7:0] buswires  // 8位双向总线
);

reg [7:0] A;    // A寄存器
reg [7:0] G;    // G寄存器
wire [7:0] temp; // 临时运算结果

// 时序逻辑：根据使能信号将数据写入A或G寄存器
always @ (posedge clk) begin
    // 若所有使能信号均无效，则不进行操作
    if (!Ain && !Gin && !AddSub && !Gout) begin
        // 空操作
    end else begin
        if (Ain) begin
            A <= buswires; // 从总线读取数据到A寄存器
        end else if (Gin) begin
            G <= temp;     // 将运算结果写入G寄存器
        end
    end
end

// 组合逻辑：根据AddSub信号选择加法或减法
assign temp = (AddSub) ? (A + buswires) : (A - buswires); // 1-加法，0-减法

// 三态总线输出：Gout有效时输出G寄存器内容，否则高阻态
assign buswires = (Gout) ? G : 8'hZZ;

endmodule