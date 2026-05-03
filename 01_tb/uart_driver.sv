class uart_driver;
    virtual uart_if.drv vif;
    mailbox #(uart_transaction) gen2drv;

    task run();
        uart_transaction tr;
        forever begin
            gen2drv.get(tr);
            // Bước 1: Config Enable/Disable RX qua Host Bus
            vif.cb.UREG_ADDR  <= 8'h00;
            vif.cb.UREG_WRDAT <= {6'b0, tr.rx_enable, 1'b0};
            vif.cb.UREG_RDWR  <= 1'b1;
            vif.cb.UREG_REQ   <= 1'b1;
            wait(vif.cb.UREG_GNT === 1'b1);
            @(vif.cb); vif.cb.UREG_REQ <= 1'b0;

            // Bước 2: Gửi Serial Frame nếu Enable
            if (tr.rx_enable) send_frame(tr.data);
            else #100; // Delay giả lập nếu disable
        end
    endtask

    task send_frame(input [7:0] d);
        vif.cb.RXD <= 1'b0; // Start
        repeat(1) @(vif.cb);
        for(int i=0; i<8; i++) begin
            vif.cb.RXD <= d[i]; // Data LSB first
            @(vif.cb);
        end
        vif.cb.RXD <= 1'b1; // Stop
        @(vif.cb);
    endtask
endclass