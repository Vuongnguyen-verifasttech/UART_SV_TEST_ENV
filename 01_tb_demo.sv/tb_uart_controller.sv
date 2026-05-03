`timescale 1ns/1ps

module tb_uart_controller;
    // 1. Khai báo tín hiệu
    logic clk, rst_n, RXD;
    logic UREG_RDWR, UREG_REQ, UREG_GNT, UART_INTR;
    logic [7:0] UREG_ADDR, UREG_WRDAT, UREG_RDDAT;

    // DUT
    uart_controller dut (.*);

    // Clock 100MHz
    always #5 clk = (clk === 1'b0);

    // Task gửi dữ liệu (Dịch bit thực thụ - LSB first)
    task send_uart_byte(input [7:0] data_in);
        begin
            @(negedge clk); RXD = 1'b0; // Start bit
            for (int i = 0; i < 8; i++) begin
                @(negedge clk); RXD = data_in[i];
            end
            @(negedge clk); RXD = 1'b1; // Stop bit
            @(negedge clk);
        end
    endtask

    // Task đọc thanh ghi
    task host_read_reg(input [7:0] addr, output [7:0] data_out);
        begin
            @(posedge clk);
            UREG_ADDR = addr; UREG_RDWR = 1'b0; UREG_REQ = 1'b1;
            wait (UREG_GNT == 1'b1);
            @(posedge clk); data_out = UREG_RDDAT;
            UREG_REQ = 1'b0;
        end
    endtask

    // 2. Kịch bản Test tự động
    initial begin
        // Khởi tạo danh sách 10 test cases ngẫu nhiên hoặc cụ thể
        logic [7:0] test_data [10] = '{8'hA5, 8'h5A, 8'hFF, 8'h00, 8'h12, 8'h34, 8'h56, 8'h78, 8'h9A, 8'hBC};
        logic [7:0] read_val;
        int pass_count = 0;

        // Init signals
        clk = 0; rst_n = 0; RXD = 1; UREG_REQ = 0;
        #20 rst_n = 1; #20;

        $display("--- STARTING TEST (10 CASES) ---");

        foreach (test_data[i]) begin
            $display("[CASE %0d] Gửi: 8'h%h", i+1, test_data[i]);
            
            send_uart_byte(test_data[i]); // Gửi serial
            
            wait (UART_INTR == 1'b1);     // Đợi ngắt
            host_read_reg(8'h01, read_val); // Đọc parallel

            // Tự động kiểm tra (Self-checking)
            if (read_val === test_data[i]) begin
                $display(" => PASS: RECEIVED RIGHT VALUE 8'h%h", read_val);
                pass_count++;
            end else begin
                $display(" => FAIL: RECEIVED 8'h%h (EXPECTED 8'h%h)", read_val, test_data[i]);
            end
            #50; // Khoảng nghỉ giữa các byte
        end

        // Tổng kết
        $display("---------------------------------------");
        $display("RESULT: %0d/10 cases SUCCESS !", pass_count);
        if (pass_count == 10) $display("NGON LUON !");
        $display("---------------------------------------");
        
        $finish;
    end

endmodule