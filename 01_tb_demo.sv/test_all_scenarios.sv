class test_all_scenarios extends base_test;

    function new(virtual uart_if vif);
        super.new(vif);
    endfunction

    // ---------------------------------------------------------
    // 1. Task Hỗ trợ ghi/đọc thanh ghi (Dùng cho Case 5, 6, 12)
    // ---------------------------------------------------------
    task bus_write(bit [7:0] addr, bit [7:0] data);
        env.bus_sem.get();
        vif.cb.UREG_ADDR  <= addr;
        vif.cb.UREG_WRDAT <= data;
        vif.cb.UREG_RDWR  <= 1'b1; // Write
        vif.cb.UREG_REQ   <= 1'b1;
        @(vif.cb);
        vif.cb.UREG_REQ   <= 1'b0;
        env.bus_sem.put();
        $display("[BUS_WRITE] Addr: 0x%h, Data: 0x%h at %t", addr, data, $time);
    endtask

    task bus_read(bit [7:0] addr, output bit [7:0] data);
        env.bus_sem.get();
        vif.cb.UREG_ADDR  <= addr;
        vif.cb.UREG_RDWR  <= 1'b0; // Read
        vif.cb.UREG_REQ   <= 1'b1;
        @(vif.cb);
        vif.cb.UREG_REQ   <= 1'b0;
        @(vif.cb); 
        data = vif.cb.UREG_RDDAT;
        env.bus_sem.put();
        $display("[BUS_READ] Addr: 0x%h, Data: 0x%h at %t", addr, data, $time);
    endtask

    // ---------------------------------------------------------
    // 2. Các Scenario chi tiết hiện thực hóa 12 Testcases
    // ---------------------------------------------------------

    // Case 1: Reset Scenarios
    task scenario_reset_test();
        $display("\n[TEST] === Case 1: Reset Test ===");
        setup(); // Gọi task reset từ base_test
        // Checkpoint: Các tín hiệu quan trọng phải về 0
        if(vif.UART_INTR !== 0) $error("CP FAIL: Case 1 - INTR not zero after reset");
        else $display("CP PASS: Case 1 - Reset successful.");
    endtask

    // Case 2: RX Disabled
    task scenario_rx_disabled();
        uart_transaction tr;
        $display("\n[TEST] === Case 2: RX Disabled Test ===");
        bus_write(8'h00, 8'h00); // Ghi 0 để tắt bit rx_enable
        
        tr = new();
        tr.rx_enable = 0;
        tr.data = 8'h55;
        env.gen2drv.put(tr); 
        
        #150000; // Đợi hết 1 frame
        if(vif.UART_INTR !== 0) $error("CP FAIL: Case 2 - INTR raised when RX disabled!");
        else $display("CP PASS: Case 2 - DUT ignored incoming data.");
    endtask

    // Case 5: Interrupt Clear
    task scenario_intr_clear();
        bit [7:0] rdata;
        $display("\n[TEST] === Case 5: Interrupt Clear Test ===");
        bus_write(8'h00, 8'h02); // Bật RX
        
        // Gửi 1 gói để lên INTR
        env.gen.start_random(1);
        wait(vif.UART_INTR == 1);
        
        // Checkpoint: Đọc thanh ghi data phải xóa được INTR
        bus_read(8'h01, rdata);
        #100;
        if(vif.UART_INTR !== 0) $error("CP FAIL: Case 5 - INTR not cleared after reading 0x01");
        else $display("CP PASS: Case 5 - Interrupt cleared successfully.");
    endtask

    // Case 3, 4, 9, 11: Dữ liệu (Random, B2B, Corner)
    task scenario_data_stress();
        $display("\n[TEST] === Case 3, 4, 9, 11: Data Stress Scenarios ===");
        bus_write(8'h00, 8'h02); // Đảm bảo RX bật

        // TC9: Corner values (00, FF, A5, 5A)
        env.gen.send_pattern(8'h00);
        env.gen.send_pattern(8'hFF);
        env.gen.send_pattern(8'hA5);
        env.gen.send_pattern(8'h5A);

        // TC4: Back-to-back (Stress test timing)
        // Gửi liên tục không delay [cite: 44]
        env.gen.start_random(20); 

        wait(env.scb.pass_cnt >= 24); 
        $display("CP PASS: Stress tests finished. Current Pass Count: %0d", env.scb.pass_cnt);
    endtask

    // Case 6 & 12: Register Access
    task scenario_reg_test();
        bit [7:0] rdata;
        $display("\n[TEST] === Case 6 & 12: Register Access ===");
        // Case 6: Kiểm tra thanh ghi cấu hình
        bus_write(8'h00, 8'h02); 
        bus_read(8'h00, rdata);
        if(rdata !== 8'h02) $error("CP FAIL: Case 6 - Reg R/W mismatch");

        // Case 12: Illegal Address (0x55)
        bus_read(8'h55, rdata);
        if(rdata !== 8'h00) $error("CP FAIL: Case 12 - Illegal addr should return 0");
    endtask

    // Case 10: Reset Mid-RX
    /*
    task scenario_reset_mid_rx();
        $display("\n[TEST] === Case 10: Reset Mid-RX ===");
        fork
            begin
                env.gen.send_pattern(8'hFF);
            end
            begin
                #50000; // Delay đến giữa khung truyền [cite: 35]
                setup(); // Thực hiện reset đột ngột
            end
        join
        if(vif.UART_INTR !== 0) $error("CP FAIL: Case 10 - Reset did not clear INTR");
    endtask
    */
    

    // ---------------------------------------------------------
    // 3. Task RUN chính - Điều phối 12 Cases
    // ---------------------------------------------------------
    virtual task run();
        $display("*******************************************");
        $display("* STARTING MASTER TEST: 12 SCENARIOS    *");
        $display("*******************************************");

        fork
            env.run(); // Chạy Driver, Monitor, SCB, Coverage
        join_none

        // Thực hiện tuần tự các nhóm kịch bản [cite: 40]
        scenario_reset_test();      // Case 1
        scenario_reg_test();        // Case 6, 12
        scenario_rx_disabled();     // Case 2
        scenario_intr_clear();      // Case 5
        scenario_data_stress();     // Case 3, 4, 9, 11
        scenario_reset_mid_rx();    // Case 10

        #10000;
        $display("\n*******************************************");
        $display("* ALL TESTCASES EXECUTED             *");
        $display("* Final PASS: %0d, FAIL: %0d         *", env.scb.pass_cnt, env.scb.fail_cnt);
        $display("*******************************************");
        // Gọi báo cáo chuyên nghiệp
                env.scb.report();
                        env.cov.report(); 

                                $display("TEST COMPLETED AT %t", $time);
        $finish;
    endtask
endclass
