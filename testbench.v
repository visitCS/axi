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
// ��������
parameter DATA_WD = 32;
parameter DATA_BYTE_WD = DATA_WD / 8;
parameter BYTE_CNT_WD = $clog2(DATA_BYTE_WD);

// ʱ�Ӻ͸�λ�ź�
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


// ʵ����
axi_stream_insert_header #(
    .DATA_WD(DATA_WD)
    ) tb (
    .clk                (clk            ),
    .rst_n              (rst_n          ),
    // ��������ӿ�
    .valid_in           (valid_in       ),
    .data_in            (data_in        ),
    .keep_in            (keep_in        ),
    .last_in            (last_in        ),
    .ready_in           (ready_in       ),
    // ����ӿ�
    .valid_out          (valid_out      ),
    .data_out           (data_out       ),
    .keep_out           (keep_out       ),
    .last_out           (last_out       ),
    .ready_out          (ready_out      ),
    // Header����ӿ�
    .valid_insert       (valid_insert   ),
    .data_insert        (data_insert    ),
    .keep_insert        (keep_insert    ),
    .byte_insert_cnt    (byte_insert_cnt),
    .ready_insert       (ready_insert   )
);

// ��ʼ��ʱ�Ӻ͸�λ
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
// ������֤���루�������ɡ���ء����Եȣ�
// ...
// ����������
task generate_data_stream();
    while (1) begin
        @(posedge clk);
        if (rst_n) begin

            valid_in = $random % 2;          // ���valid�ź�
            data_in  = $urandom();           // �������
            last_in  = valid_in? ($random % 10 == 0) : 0;  // 10%����Ϊ���һ��

            keep_in  = (!last_in) ? {DATA_BYTE_WD{1'b1}} : // �����һ��ȫ��Ч
                       (4'b1111 << $urandom_range(0, 3));        // ���һ�����������Ч
        end
    end
endtask

// Header����
task generate_header();
    while (1) begin
        @(posedge clk);begin
                valid_insert = $random % 2;
                data_insert  = $urandom();
                // ����������keep_insert����4'b0011��
                keep_insert = (4'b1111 >>  $urandom_range(0, 3));
                byte_insert_cnt = keep_insert[0] + keep_insert[1] + keep_insert[2] +keep_insert[3];
        end
    end
endtask

// ���η�ѹ����
task generate_backpressure();
    while (1) begin
        @(posedge clk);
        ready_out = 1;  // �����ѹ
    end
endtask
endmodule
