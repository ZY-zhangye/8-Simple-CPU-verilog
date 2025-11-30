//==============================================================
// 模块名称：control
// 功能描述：控制单元，负责ALU、寄存器组等模块的时序控制
//==============================================================
module control (
    input  wire       clk,      // 时钟信号
    input  wire       reset,    // 异步复位信号
    input  wire       Run,      // 启动信号
    input  wire [1:0] Rx,       // 源寄存器选择
    input  wire [1:0] Ry,       // 目标寄存器选择
    input  wire [1:0] Fun,      // 功能选择信号
    output reg        Done,     // 操作完成标志
    output reg        Entern,   // 总线写入使能
    output reg        AddSub,   // 运算选择（1-加法，0-减法）
    output reg        Ain,      // A寄存器使能
    output reg        Gin,      // G寄存器使能
    output reg        Gout,     // G寄存器输出使能
    output reg        Rout0, Rout1, Rout2, Rout3, // 4个寄存器输出使能
    output reg        Rin0, Rin1, Rin2, Rin3      // 4个寄存器输入使能
);

// 状态寄存器
reg [3:0] state_ALU;   // ALU操作状态
reg [1:0] state_Load;  // Load操作状态
reg [4:0] state_Move;  // Move操作状态

// 任务：清零所有Rin和Rout
task clear_RinRout;
begin
    Rin0 <= 0; Rin1 <= 0; Rin2 <= 0; Rin3 <= 0;
    Rout0 <= 0; Rout1 <= 0; Rout2 <= 0; Rout3 <= 0;
end
endtask

// 任务：清零所有Rin
task clear_Rin;
begin
    Rin0 <= 0; Rin1 <= 0; Rin2 <= 0; Rin3 <= 0;
end
endtask

// 任务：清零所有Rout
task clear_Rout;
begin
    Rout0 <= 0; Rout1 <= 0; Rout2 <= 0; Rout3 <= 0;
end
endtask

// 主状态机
always @ (posedge clk or posedge reset) begin
    if (reset) begin
        // 复位所有控制信号和状态
        Done     <= 0;
        Entern   <= 0;
        AddSub   <= 0;
        Ain      <= 0;
        Gin      <= 0;
        Gout     <= 0;
        clear_RinRout();
        state_ALU  <= 4'b0001; // ALU初始状态
        state_Load <= 2'b01;   // Load初始状态
        state_Move <= 5'b00001;// Move初始状态
    end else begin
        // ALU操作（Fun=2'b10或2'b11）
        if (Fun == 2'b10 || Fun == 2'b11) begin
            case (state_ALU)
                4'b0001: begin // 第1周期：选择Rx输出
                    if (Run) begin
                        Done  <= 1;
                        Gout  <= 0; // 禁止Gout
                        case (Rx)
                            2'b00: Rout0 <= 1;
                            2'b01: Rout1 <= 1;
                            2'b10: Rout2 <= 1;
                            2'b11: Rout3 <= 1;
                        endcase
                        clear_Rin();
                        state_ALU <= 4'b0010;
                    end else begin
                        state_ALU <= 4'b0001;
                        clear_RinRout();
                    end
                end
                4'b0010: begin // 第2周期：选择Ry输出，A寄存器使能
                    case (Rx)
                        2'b00: Rout0 <= 0;
                        2'b01: Rout1 <= 0;
                        2'b10: Rout2 <= 0;
                        2'b11: Rout3 <= 0;
                    endcase
                    case (Ry)
                        2'b00: Rout0 <= 1;
                        2'b01: Rout1 <= 1;
                        2'b10: Rout2 <= 1;
                        2'b11: Rout3 <= 1;
                    endcase
                    Ain    <= 1;
                    AddSub <= (Fun == 2'b10) ? 1 : 0; // 1-加法，0-减法
                    state_ALU <= 4'b0100;
                end
                4'b0100: begin // 第3周期：Ain无效，G寄存器使能
                    case (Ry)
                        2'b00: Rout0 <= 0;
                        2'b01: Rout1 <= 0;
                        2'b10: Rout2 <= 0;
                        2'b11: Rout3 <= 0;
                    endcase
                    Ain <= 0;
                    Gin <= 1;
                    state_ALU <= 4'b1000;
                end
                4'b1000: begin // 第4周期：G寄存器输出，Rx输入使能
                    Gin  <= 0;
                    Gout <= 1; // 允许Gout输出
                    case (Rx)
                        2'b00: Rin0 <= 1;
                        2'b01: Rin1 <= 1;
                        2'b10: Rin2 <= 1;
                        2'b11: Rin3 <= 1;
                    endcase
                    Done <= 0;
                    state_ALU <= 4'b0001;
                end
                default: begin
                    // 恢复初始状态
                    Done   <= 0;
                    Ain    <= 0;
                    Gin    <= 0;
                    AddSub <= 0;
                    clear_RinRout();
                    state_ALU <= 4'b0001;
                end
            endcase
        end 
        // Load操作（Fun=2'b00）
        else if (Fun == 2'b00) begin
            case (state_Load)
                2'b01: begin // 第1周期：Rx输入使能
                    if (Run) begin
                        Done <= 1;
                        case (Rx)
                            2'b00: Rin0 <= 1;
                            2'b01: Rin1 <= 1;
                            2'b10: Rin2 <= 1;
                            2'b11: Rin3 <= 1;
                        endcase
                        clear_Rout();
                        Gout   <= 0; // 禁止Gout
                        Entern <= 1; // 总线写入使能
                        state_Load <= 2'b10;
                    end else begin
                        state_Load <= 2'b01;
                    end
                end
                2'b10: begin // 第2周期：关闭Entern，Rx输入无效
                    Entern <= 0;
                    case (Rx)
                        2'b00: Rin0 <= 0;
                        2'b01: Rin1 <= 0;
                        2'b10: Rin2 <= 0;
                        2'b11: Rin3 <= 0;
                    endcase
                    Done <= 0;
                    state_Load <= 2'b01;
                end
                default: state_Load <= 2'b01;
            endcase
        end 
        // Move操作（Fun=2'b01）
        else if (Fun == 2'b01) begin
            case (state_Move)
                5'b00001: begin // 第1周期：Ry输出
                    if (Run) begin
                        Done  <= 1;
                        Gout  <= 0; // 禁止Gout
                        case (Ry)
                            2'b00: Rout0 <= 1;
                            2'b01: Rout1 <= 1;
                            2'b10: Rout2 <= 1;
                            2'b11: Rout3 <= 1;
                        endcase
                        clear_Rin();
                        state_Move <= 5'b00010;
                    end else begin
                        state_Move <= 5'b00001;
                    end
                end
                5'b00010: begin // 第2周期：Ry输出无效，Rx输入使能
                    case (Ry)
                        2'b00: Rout0 <= 0;
                        2'b01: Rout1 <= 0;
                        2'b10: Rout2 <= 0;
                        2'b11: Rout3 <= 0;
                    endcase
                    case (Rx)
                        2'b00: Rin0 <= 1;
                        2'b01: Rin1 <= 1;
                        2'b10: Rin2 <= 1;
                        2'b11: Rin3 <= 1;
                    endcase
                    state_Move <= 5'b00100;
                end
                5'b00100: begin // 第3周期：Rx输入无效，完成
                    case (Rx)
                        2'b00: Rin0 <= 0;
                        2'b01: Rin1 <= 0;
                        2'b10: Rin2 <= 0;
                        2'b11: Rin3 <= 0;
                    endcase
                    Done <= 0;
                    state_Move <= 5'b00001;
                end
                default: begin
                    state_Move <= 5'b00001;
                end
            endcase
        end
    end
end

endmodule