interface uart_if (input clk);

// Declare signals
logic rst_n;
logic RXD;
logic UREG_RDWR;
logic [7:0] UREG_ADDR;
logic [7:0] UREG_WRDAT;
logic UREG_REQ;
logic UREG_GNT;
logic [7:0] UREG_RDDAT;
logic UART_INTR;

//Clocking block 
clocking cb @(posedge clk);
    default input #1ns output #1ns;
    output RXD, UREG_RDWR, UREG_ADDR, UREG_WRDAT, UREG_REQ;
    input UREG_GNT, UREG_RDDAT, UART_INTR;
endclocking

// Modports: Phân quyền sử dụng các tín hiệu
    modport drv (clocking cb);
    modport mon (clocking cb);
/* dung interface này để kết nối giữa testbench và DUT, đảm bảo đồng bộ tín hiệu qua clocking block. 
   Modport 'drv' dành cho driver (testbench) để điều khiển tín hiệu đầu ra và đọc tín hiệu đầu vào.
   Modport 'mon' dành cho monitor (nếu có) để chỉ đọc tín hiệu mà không can thiệp.
   driver và monitor đều dùng clocking block cb, khong truy cap truc tiep vao cac signal ben ngoai ma phai qua clocking block de dam bao dong bo va timing chinh xac. */
   
endinterface 
