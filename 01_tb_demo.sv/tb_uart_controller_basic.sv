`timescale 1ns/1ps
module tb_uart_controller;
    // 1. Khai báo tín hiệu
    logic       clk;
    logic       rst_n;
    logic       RXD;
    logic       UREG_RDWR;
    logic [7:0] UREG_ADDR;
    logic [7:0] UREG_WRDAT;
    logic       UREG_REQ;
    logic       UREG_GNT;
    logic [7:0] UREG_RDDAT;
    logic       UART_INTR;

    // Kết nối DUT
    uart_controller dut (.*);

    // 2. Tạo xung Clock
    always #5 clk = ~clk;

    // Task gửi 1 byte qua RXD (LSB trước)
    task send_uart_byte(input [7:0] data);
        begin
            @(posedge clk);
            RXD = 1'b0; // Start bit
            for (int i = 0; i < 8; i++) begin
                @(posedge clk);
                RXD = data[i];
            end
            @(posedge clk); RXD = 1'b1; // Stop bit 1
            @(posedge clk); RXD = 1'b1; // Stop bit 2
        end
    endtask

    // Task đọc thanh ghi từ host
    task host_read_reg(input [7:0] addr, output [7:0] data_out);
        begin
            @(posedge clk);
            UREG_ADDR = addr;
            UREG_RDWR  = 1'b0;
            UREG_REQ   = 1'b1;
            wait (UREG_GNT == 1'b1);
            @(posedge clk);
            data_out = UREG_RDDAT;
            UREG_REQ = 1'b0;
        end
    endtask

    initial begin
     //   $dumpfile("uart_onecase.vcd");
    //    $dumpvars(0, tb_uart_controller_onecase);
      //  $display("--- Single Test Case for uart_controller ---");
        logic [7:0] expected_data;
        logic [7:0] read_val;
        // Khởi tạo ban đầu
        clk      = 1'b0;
        rst_n    = 1'b0;
        RXD      = 1'b1;
        UREG_REQ = 1'b0;
        UREG_ADDR = 8'h00;
        UREG_RDWR = 1'b0;
        UREG_WRDAT = 8'h00;

        #20 rst_n = 1'b1; // Tháo reset

        // Test case 1: gửi một byte và đọc lại từ thanh ghi RX_DATA


        expected_data = 8'hA5;
        $display("[CASE 1] Send byte = 8'h%0h", expected_data);

        send_uart_byte(expected_data);

        wait (UART_INTR == 1'b1);
        $display("[CASE 1] UART_INTR asserted => data ready");

        host_read_reg(8'h01, read_val);

        if (read_val === expected_data) begin
            $display("[CASE 1] PASS: read 8'h%0h matches expected", read_val);
        end else begin
            $display("[CASE 1] FAIL: read 8'h%0h but expected 8'h%0h", read_val, expected_data);
        end

        #20 $display("--- Single testbench completed ---");
        $finish;
    end

endmodule
