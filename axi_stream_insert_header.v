`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/02/23 13:52:28
// Design Name: 
// Module Name: axi_stream_insert_header
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


module axi_stream_insert_header #(
    parameter DATA_WD = 32,
    parameter DATA_BYTE_WD = DATA_WD / 8,
    parameter BYTE_CNT_WD = $clog2(DATA_BYTE_WD)
    ) (
    input                           clk,
    input                           rst_n,
    // AXI Stream input original data
    input                           valid_in,
    input   [DATA_WD-1 : 0]         data_in,
    input   [DATA_BYTE_WD-1 : 0]    keep_in,
    input                           last_in,                   
    output                          ready_in,

    // AXI Stream output with header inserted
    output  reg                     valid_out,
    output  reg [DATA_WD-1 : 0]     data_out,
    output  reg [DATA_BYTE_WD-1 : 0]keep_out,
    output  reg                     last_out,
    input                           ready_out,

    // The header to be inserted to AXI Stream input
    input                           valid_insert,
    input   [DATA_WD-1 : 0]         data_insert,
    input   [DATA_BYTE_WD-1 : 0]    keep_insert,
    input   [BYTE_CNT_WD : 0]       byte_insert_cnt,
    output                          ready_insert
);
// Your code here

// // 插入数据提取，保存有效插入数数据,将有效数据存在高位，低位补0
reg [DATA_WD-1 : 0]         r_data_insert;
always@(posedge clk or negedge rst_n)begin
    if (!rst_n) begin
        r_data_insert <= 0;
    end
    else if (valid_insert & ready_insert) begin
        r_data_insert <= data_insert << (8 * (DATA_BYTE_WD - byte_insert_cnt)); 
    end
end

// 保存插入的数据个数据
reg [BYTE_CNT_WD : 0]     r_byte_insert_cnt;
always@(posedge clk or negedge rst_n)begin
    if (!rst_n) begin
        r_byte_insert_cnt <= 0;
    end
    else if (valid_insert & ready_insert) begin
        r_byte_insert_cnt <= byte_insert_cnt; 
    end
end

// yes_insert处理
reg yes_insert;
always@(posedge clk or negedge rst_n)begin
    if (!rst_n) begin
        yes_insert <= 0;
    end
    else if (valid_insert & ready_insert) begin
            yes_insert <= 1;
    end
end

reg [DATA_WD-1 : 0]             temp_data;
reg                             yes_temp;
reg [DATA_BYTE_WD - 1 : 0]      temp_keep;
reg [10 : 0]                    r_num;
reg                             yes_last;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_out <= 0;
        yes_temp <= 0;
        keep_out <= 0;
        temp_data <= 0;
        temp_keep <= 0;
        last_out <= 0;
        yes_last <= 0;
    end
    else if (r_valid_out & ready_out) begin
        if (yes_insert) begin
            if (r_byte_insert_cnt == DATA_BYTE_WD) begin
                data_out <= r_data_insert;
                keep_out <= 4'b1111;

                temp_data <= r_data_in;
                temp_keep <= 4'b1111;

                yes_temp <= 1;
                yes_insert <= 0;
            end
            else begin
                data_out <= r_data_insert | r_data_in >> (8 * r_byte_insert_cnt);
                keep_out <= 4'b1111;

                temp_data <= r_data_in << (8 * (DATA_BYTE_WD - r_byte_insert_cnt));
                temp_keep <= r_keep_in << (DATA_BYTE_WD - r_byte_insert_cnt);     

                yes_temp <= 1;
                yes_insert <= 0;
            end
        end
        else if (yes_temp) begin
            if (!r_last_in & !yes_last) begin
                data_out <= temp_data | r_data_in >> (8 * r_byte_insert_cnt);
                keep_out <= 4'b1111;

                temp_data <= r_data_in << (8 * (DATA_BYTE_WD - r_byte_insert_cnt));
                temp_keep <= r_keep_in << (DATA_BYTE_WD - r_byte_insert_cnt);     

            end 
            else if (yes_last) begin
                data_out <= temp_data | r_data_in >> (8 * r_byte_insert_cnt);
                keep_out <= 4'b1111 << (DATA_BYTE_WD - ( r_byte_insert_cnt));
                last_out <= 1;

                temp_data <= 0;
                temp_keep <= 0;
                
                yes_temp <= 0;
                yes_last <= 0;
            end
            else begin
                if (keep_in[0] + keep_in[1] +keep_in[2] + keep_in[3] + r_byte_insert_cnt > 4) begin
                    data_out <=  temp_data | r_data_in >> (8 * r_byte_insert_cnt);
                    keep_out <= 4'b1111;

                    temp_data <= r_data_in << (8 * (DATA_BYTE_WD - r_byte_insert_cnt));
                    temp_keep <= 4'b1111 << ((r_keep_in[0] + r_keep_in[1] +r_keep_in[2] + r_keep_in[3] + r_byte_insert_cnt) - DATA_BYTE_WD);

                    yes_last <= 1;

                end 
                else begin
                    data_out <= temp_data | r_data_in >> (8 * r_byte_insert_cnt);
                    keep_out <= 4'b1111 << (DATA_BYTE_WD - (r_keep_in[0] + r_keep_in[1] +r_keep_in[2] + r_keep_in[3] + r_byte_insert_cnt));
                    last_out <= 1;

                    temp_data <= 0;
                    temp_keep <= 0;
                    
                    yes_temp <= 0;
                end
            end
        end
        else begin
            data_out <= r_data_in;
            keep_out <= r_keep_in;
            last_out <= 0;
        end
    end
    
end

// ready_in
assign ready_in = 1;

// ready_insert
reg ready_insert;
always@(posedge clk or negedge rst_n)begin
    if (!rst_n ) begin
        ready_insert <= 1;
    end
    else if(last_out)begin
        ready_insert <= 1;
    end
    else if (valid_insert && ready_insert) begin
        ready_insert <= 0;
    end 
        
end



// valid_out
reg r_valid_out;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n | last_out) begin
        r_valid_out<= 0;
    end
    else begin
        r_valid_out <= valid_in | yes_last;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n ) begin
        valid_out <= 0;
    end
    else begin
        valid_out <= r_valid_out;
    end
end

// 暂存原始数据
reg [DATA_WD-1 : 0]             r_data_in;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        r_data_in <= 0;
    end
    else if (valid_in & ready_in) begin
        r_data_in <= data_in;
    end 
    else if (last_out) begin
        r_data_in <= 0;
    end
end

reg                             r_last_in;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        r_last_in <= 0;
    end 
    else if (valid_in & ready_in) begin
        r_last_in <= last_in;
    end

end

reg [DATA_BYTE_WD-1 : 0]        r_keep_in;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        r_keep_in <= 0;
    end 
    else if (valid_in & ready_in) begin
        r_keep_in <= keep_in;
    end
end


endmodule