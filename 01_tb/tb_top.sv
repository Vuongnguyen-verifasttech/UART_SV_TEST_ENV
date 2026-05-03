module tb_top;
    bit clk;
    always #5 clk = ~clk;
    uart_if uif(clk);
    
    uart_controller dut (
        .clk(clk), .rst_n(uif.RXD), // Reset logic tùy biến
        .RXD(uif.RXD), .UREG_RDWR(uif.UREG_RDWR),
        .UREG_ADDR(uif.UREG_ADDR), .UREG_WRDAT(uif.UREG_WRDAT),
        .UREG_REQ(uif.UREG_REQ), .UREG_GNT(uif.UREG_GNT),
        .UREG_RDDAT(uif.UREG_RDDAT), .UART_INTR(uif.UART_INTR)
    );

    uart_test test;
    initial begin
        uif.RXD = 1; #20;
        test = new(uif);
        test.run();
    end
endmodule