//==============================================================================
// File          : tb_top.sv
// Author        : [vnguyen]
// Company       : [Verifast]
// Project       : UART Verification Environment
// Description   : UART testbench top module
//                 - Instantiates DUT and connects to test environment
//                 - Generates clock and rst_n
//
// Version       : 1.0
// Date          : 21-Apr-2026
//==============================================================================
import uart_pkg::*;
module tb_top;
    bit clk= 0;
    bit rst_n = 0;

    always #5 clk = ~clk; // 100MHz clock
    // Instantiate interface
    uart_if u_if(.clk(clk));
    uart_controller dut (
    .clk      (u_if.clk),     // Phải nối từ Interface vào
    .rst_n    (u_if.rst_n),   // Phải nối từ Interface vào
    .RXD      (u_if.RXD),
    .UART_INTR(u_if.UART_INTR),
    .UREG_GNT (u_if.UREG_GNT),
    .UREG_RDDAT(u_if.UREG_RDDAT),
    .UREG_ADDR(u_if.UREG_ADDR),
    .UREG_RDWR(u_if.UREG_RDWR),
    .UREG_WRDAT(u_if.UREG_WRDAT),
    .UREG_REQ (u_if.UREG_REQ)
);
    // Instantiate test class
    test_all_scenarios test;
    initial begin
    forever begin
        #100;
        if (u_if.RXD == 0) $display("Time %t: Detected Start Bit on RXD!", $time);
        if (u_if.UART_INTR == 1) $display("Time %t: Interrupt is HIGH!", $time);
    end
    end
    initial begin 
        rst_n =0 ;
        #20; // Hold rst_n for 20ns
        rst_n = 1; // Release rst_n

        // Initialize test class with interface
        test = new(u_if);

        // Run the test
        test.run();
    end
endmodule

