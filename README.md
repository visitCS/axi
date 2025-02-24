# 通过axi协议完成，输入流和输出流有一个时钟信号差，默认ready_in一直拉高，ready_out一直拉高
# 一个输入流数据只插入一个数据，即一个数据插入完成后，需要等待输入数据流结束才能插入下一个
# 第一个输出流数据由有效插入数据和第一个输入数据流高字节组成，其余为上一个低字节和当前高字节
# 如果出现last_in信号，存在两种情况，即第一个种当前last_in就可以输出，第二种需要输出一个之后再输出一个。
# 以下为测试图片
![image](https://github.com/user-attachments/assets/ddc499e5-ef3e-4d4d-a859-b1c5a7a16e5f)

![image](https://github.com/user-attachments/assets/5641ac9c-c3fa-4cdf-b05b-1a4844a89025)

![image](https://github.com/user-attachments/assets/2f57f5bb-61ed-427f-b577-8caeb31979bd)
