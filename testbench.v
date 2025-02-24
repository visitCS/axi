`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/02/23 21:59:06
// Design Name: 
// Module Name: testbench
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module testbench();
// 参数定义
parameter DATA_WD = 32;
parameter DATA_BYTE_WD = DATA_WD / 8;
parameter BYTE_CNT_WD = $clog2(DATA_BYTE_WD);

// 时钟和复位信号
reg                         clk             ;
reg                         rst_n           ;

reg                         valid_in       ;
reg  [DATA_WD-1 : 0]        data_in        ;
reg  [DATA_BYTE_WD-1 : 0]   keep_in        ;
reg                         last_in        ;
wire                        ready_in       ;

wire                        valid_out      ;
wire [DATA_WD-1 : 0]        data_out       ;
wire [DATA_BYTE_WD-1 : 0]   keep_out       ;
wire                        last_out       ;
reg                         ready_out      ;

reg                         valid_insert   ;
reg  [DATA_WD-1 : 0]        data_insert    ;
reg  [DATA_BYTE_WD-1 : 0]   keep_insert    ;
reg  [BYTE_CNT_WD : 0]      byte_insert_cnt;
wire                        ready_insert   ;


// 实例化
axi_stream_insert_header #(
    .DATA_WD(DATA_WD)
    ) tb (
    .clk                (clk            ),
    .rst_n              (rst_n          ),
    // 数据输入接口
    .valid_in           (valid_in       ),
    .data_in            (data_in        ),
    .keep_in            (keep_in        ),
    .last_in            (last_in        ),
    .ready_in           (ready_in       ),
    // 输出接口
    .valid_out          (valid_out      ),
    .data_out           (data_out       ),
    .keep_out           (keep_out       ),
    .last_out           (last_out       ),
    .ready_out          (ready_out      ),
    // Header输入接口
    .valid_insert       (valid_insert   ),
    .data_insert        (data_insert    ),
    .keep_insert        (keep_insert    ),
    .byte_insert_cnt    (byte_insert_cnt),
    .ready_insert       (ready_insert   )
);

// 初始化时钟和复位
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end
initial begin
    keep_in = 0;
    keep_insert = 0;
    rst_n = 0;
    #20 rst_n = 1;
end

initial begin
    generate_data_stream();
end
initial begin
    generate_header();
end
initial begin
    generate_backpressure();

end
wire in_control = ready_in && rst_n;
wire insert_control = ready_insert && rst_n;
// 其他验证代码（激励生成、监控、断言等）
// ...
// 数据流生成
task generate_data_stream();
    while (1) begin
        @(posedge clk);
        if (rst_n) begin

            valid_in = $random % 2;          // 随机valid信号
            data_in  = $urandom();           // 随机数据
            last_in  = valid_in? ($random % 10 == 0) : 0;  // 10%概率为最后一拍

            keep_in  = (!last_in) ? {DATA_BYTE_WD{1'b1}} : // 非最后一拍全有效
                       (4'b1111 << $urandom_range(0, 3));        // 最后一拍随机部分有效
        end
    end
endtask

// Header生成
task generate_header();
    while (1) begin
        @(posedge clk);begin
                valid_insert = $random % 2;
                data_insert  = $urandom();
                // 生成连续的keep_insert（如4'b0011）
                keep_insert = (4'b1111 >>  $urandom_range(0, 3));
                byte_insert_cnt = keep_insert[0] + keep_insert[1] + keep_insert[2] +keep_insert[3];
        end
    end
endtask

// 下游反压生成
task generate_backpressure();
    while (1) begin
        @(posedge clk);
        ready_out = 1;  // 随机反压
    end
endtask
endmodule
