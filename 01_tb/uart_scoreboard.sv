class uart_scoreboard;
    mailbox #(uart_transaction) gen2scb;
    mailbox #(uart_transaction) mon2scb;
    int pass = 0, fail = 0;

    task run();
        uart_transaction exp, act;
        forever begin
            gen2scb.get(exp);
            if (exp.rx_enable) begin
                mon2scb.get(act);
                if (exp.data === act.data) begin
                    $display("[SCB] PASS: Exp=0x%h, Act=0x%h", exp.data, act.data);
                    pass++;
                end else begin
                    $error("[SCB] FAIL: Exp=0x%h, Act=0x%h", exp.data, act.data);
                    fail++;
                end
            end else begin
                $display("[SCB] Info: RX Disabled, skipping check.");
            end
        end
    endtask
endclass