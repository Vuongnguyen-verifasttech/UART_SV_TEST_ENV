`timescale 1ns/1ps
interface uart_if (input logic clk);
    logic RXD;
    logic UREG_RDWR, UREG_REQ, UREG_GNT, UART_INTR;
    logic [7:0] UREG_ADDR, UREG_WRDAT, UREG_RDDAT;

    clocking cb @(posedge clk);
        default input #1ns output #1ns;
        output RXD, UREG_RDWR, UREG_ADDR, UREG_WRDAT, UREG_REQ;
        input  UREG_GNT, UREG_RDDAT, UART_INTR;
    endclocking

    modport drv (clocking cb);
    modport mon (clocking cb);
endinterface