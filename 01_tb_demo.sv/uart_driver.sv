class uart_driver;
    virtual uart_if.drv vif;
    mailbox #(uart_transaction) gen2drv;
    semaphore bus_sem;
    uart_transaction tr; // Đổi tên từ transaction thành uart_transaction cho chuẩn class

    task run();
        // Khởi tạo giá trị IDLE ngay lập tức để tránh X
        vif.cb.RXD <= 1'b1;
        vif.cb.UREG_REQ <= 1'b0;

        forever begin
            gen2drv.get(tr); // Lấy packet từ Generator
            
            // 1. Cấu hình Register (Bật/Tắt RX)
            bus_sem.get();
            vif.cb.UREG_ADDR  <= 8'h00;
            vif.cb.UREG_WRDAT <= {6'b0, tr.rx_enable, 1'b0};
            vif.cb.UREG_RDWR  <= 1'b1;
            vif.cb.UREG_REQ   <= 1'b1;
            @(vif.cb);
            vif.cb.UREG_REQ   <= 1'b0;
            bus_sem.put();
            /*
            // 2. Gửi UART Frame nếu enable
            if (tr.rx_enable) begin
                send_uart_frame(tr.data);
            end else begin
                repeat(11) @(vif.cb); // Đợi một khoảng thời gian tương đương 1 frame để đồng bộ
            end
        end*/
        // 2. Kiểm tra điều kiện gửi frame
        if (tr.rx_enable) begin
            send_uart_frame(tr.data);
            
            // Đợi DUT xử lý xong gói này (Dựa vào Interrupt)
            wait(vif.cb.UART_INTR == 1'b1);
            wait(vif.cb.UART_INTR == 1'b0);
        end else begin
            // Nếu disable, Driver nghỉ một khoảng thời gian ngắn 
            // rồi quay lại lấy transaction tiếp theo
            repeat(100) @(vif.cb); 
        end
        
        $display("[DRV] Finished transaction, rx_enable=%b", tr.rx_enable);
    end
        
    endtask

    task send_uart_frame(input [7:0] data);
        // Start bit
        vif.cb.RXD <= 1'b0;
        @(vif.cb);
        
        // 8 Data bits
        for (int i=0; i<8; i++) begin 
            vif.cb.RXD <= data[i]; 
            @(vif.cb); // Đợi clock xong mới chuyển sang bit tiếp theo
        end
        
        // Stop bit
        vif.cb.RXD <= 1'b1;
        @(vif.cb);
        
        $display("[DRV] Sent Frame: 0x%h at time %t", data, $time);
    endtask
endclass
/*
// Generator → (mailbox) → Driver → (interface) → DUT
class uart_driver;
virtual uart_if.drv vif; // Driver nói chuyện với interface qua modport drv,mọi truy cập đều qua vif.cb.* (clocking block)

mailbox #(uart_transaction) gen2drv; // Nhận transaction từ generator qua mailbox
semaphore bus_sem; // key de dung chung bus voi monitor 
transaction tr; // Transaction hiện tại đang xử lý
task run();
// Lay transaction tu generator 
    tr = new(); 
    forever begin // them vong lap de driver lien tuc lay transaction tu generator
    gen2drv.get(tr);
// Cau hinh register ( dung bus_sem de tranh xung dot voi monitor )
    bus_sem.get(); // lay key truoc khi truy cap bus
    vif.cb.UREG_ADDR <= 8'h00; // Dia chi register cau hinh
    vif.cb.UREG_WRDAT <= {6'b0, tr.rx_enable, 1'b0}; // Cau hinh RX enable/disable
    vif.cb.UREG_RDWR <= 1'b1; // Write operation
    vif.cb.UREG_REQ <= 1'b1; // Request bus
    @(vif.cb); // cho 1 canh clock 
    vif.cb.UREG_REQ <= 1'b0; // Release bus
    bus_sem.put(); // tra key sau khi xong

//Gui du lieu qua chan RXD neu RX enable
    send_uart_frame(tr.data);
    end
endtask

// Task gui 1 frame UART (start bit + 8 data bits + stop bit)
task send_uart_frame(input [7:0] data);
    vif.cb.RXD <= 1'b0; // Start bit
    @(vif.cb);
    for (int i=0;i<8;i++) begin 
    @(vif.cb);
    vif.cb.RXD <= data[i]; // Data bit (LSB first)
    end
    @(vif.cb);
    vif.cb.RXD <= 1'b1; // Stop bit
    @(vif.cb);
endtask
endclass*/