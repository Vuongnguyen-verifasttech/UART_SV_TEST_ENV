class uart_monitor;
    virtual uart_if.mon vif;
    mailbox #(uart_transaction) mon2scb;

    task run();
        forever begin
            @(vif.cb);
            if (vif.cb.UART_INTR === 1'b1) begin
                uart_transaction tr = new();
                vif.cb.UREG_ADDR <= 8'h01; // Đọc RX_DATA
                vif.cb.UREG_RDWR <= 1'b0;
                vif.cb.UREG_REQ  <= 1'b1;
                wait(vif.cb.UREG_GNT === 1'b1);
                @(vif.cb);
                tr.data = vif.cb.UREG_RDDAT;
                vif.cb.UREG_REQ <= 1'b0;
                mon2scb.put(tr);
            end
        end
    endtask
endclass