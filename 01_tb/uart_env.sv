class uart_env;
    uart_generator gen; uart_driver drv;
    uart_monitor mon; uart_scoreboard scb; uart_coverage cov;
    mailbox #(uart_transaction) g2d, g2s, m2s;
    virtual uart_if vif;

    function new(virtual uart_if v);
        vif = v; g2d = new(); g2s = new(); m2s = new();
        gen = new(); drv = new(); mon = new(); scb = new(); cov = new();
        gen.gen2drv = g2d; gen.gen2scb = g2s;
        drv.vif = vif; drv.gen2drv = g2d;
        mon.vif = vif; mon.mon2scb = m2s;
        scb.gen2scb = g2s; scb.mon2scb = m2s;
    endfunction

    task run();
        fork
            gen.run(); drv.run(); mon.run(); scb.run();
        join_any // Kết thúc khi Generator xong
    endtask
endclass