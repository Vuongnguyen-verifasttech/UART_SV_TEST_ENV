class uart_monitor;
    virtual uart_if.mon vif; // ket noi voi interface
    mailbox #(uart_transaction) mon2scb; // gui transaction den scoreboard
    semaphore bus_sem; // key de dung chung bus voi driver
    int last_stop_time = 0;
    task run();
    uart_transaction tr;
    forever begin
        tr = new();
        @(posedge vif.cb.RXD); // Đợi Start bit [cite: 62]
                tr.gap_cycles = ($time - last_stop_time) / 10; // Giả sử clock là 10ns
        @(vif.cb); // Đợi mỗi cạnh clock
        // Thay vì dùng IF, hãy dùng WAIT để chắc chắn Monitor dừng lại đợi Interrupt
        wait(vif.cb.UART_INTR == 1'b1); 
        
        
        bus_sem.get();
        
        // Giao thức đọc thanh ghi Rx_Data (Địa chỉ 0x01)
        vif.cb.UREG_ADDR <= 8'h01;
        vif.cb.UREG_RDWR <= 1'b0; // Read
        vif.cb.UREG_REQ  <= 1'b1;
        
        repeat(2) @(vif.cb); // Đợi 2 clock để DUT phản hồi dữ liệu
        
        tr.data = vif.cb.UREG_RDDAT;
        vif.cb.UREG_REQ <= 1'b0;
        bus_sem.put();
        
        mon2scb.put(tr);
        $display("[MON] Captured Data: 0x%h at time %t", tr.data, $time);
        
        // Quan trọng: Đợi Interrupt xuống 0 trước khi lặp lại để tránh đọc trùng
        wait(vif.cb.UART_INTR == 1'b0); 
        last_stop_time = $time; // Lưu lại mốc kết thúc
    end
endtask
endclass 
