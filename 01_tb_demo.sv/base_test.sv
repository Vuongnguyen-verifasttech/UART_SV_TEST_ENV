class base_test;
    virtual uart_if vif;
    uart_env env;

    function new(virtual uart_if vif);
        this.vif = vif;
        env = new(vif);
    endfunction

    // Task khởi tạo mặc định (Reset hệ thống)
    virtual task setup();
        $display("[BASE_TEST] System Resetting...");
        vif.rst_n <= 1'b0;
        #100;
        vif.rst_n <= 1'b1;
        #10;
        $display("[BASE_TEST] System Ready.");
    endtask

    // Task chạy chính - sẽ được override ở class con
    virtual task run();
        setup();
        $display("[BASE_TEST] Starting Environment...");
        env.run(); 
    endtask
endclass
