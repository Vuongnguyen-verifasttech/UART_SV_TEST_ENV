class uart_scoreboard; 
    mailbox #(uart_transaction) mon2scb; // Du lieu thuc te tu monitor
    mailbox #(uart_transaction) gen2scb; // Du lieu mong doi tu generator
    uart_coverage cov; // Ket noi de tinh diem coverage

    int pass_cnt = 0;
    int fail_cnt = 0; 
/*
    task run();
        uart_transaction exp_tr, act_tr;
        forever begin
            // 1. Dung fork..join de doi ca 2 du lieu cung luc
            fork
                gen2scb.get(exp_tr); // Lay du lieu mong doi tu generator
                mon2scb.get(act_tr); // Lay du lieu thuc te tu monitor
            join

            // 2. So sanh du lieu
            // dau "===" so sanh tuyet doi, ke ca x va z, dau "==" so sanh tuong doi, khong ke x va z
            if (exp_tr.data === act_tr.data) begin 
                pass_cnt++;
                $display("[SCB] PASS: Data=0x%h",exp_tr.data);
            // 3. Neu dung thi cap nhat coverage
                cov.sample(exp_tr);
            end else begin
                fail_cnt++;
                $display("[SCB] FAIL: expected=0x%h, actual=0x%h", exp_tr.data, act_tr.data);
            end
        end
    endtask
    */
    task run();
    uart_transaction exp_tr, act_tr;
    forever begin
        gen2scb.get(exp_tr); // Lấy dữ liệu mong đợi
        mon2scb.get(act_tr); // Đợi dữ liệu thực tế từ Monitor
        
        if (exp_tr.data === act_tr.data) begin
            pass_cnt++;
            $display("[SCB] PASS: Expected=0x%h, Actual=0x%h", exp_tr.data, act_tr.data);
            cov.sample(exp_tr); 
        end else begin
            fail_cnt++;
            $display("[SCB] FAIL: Expected=0x%h, Actual=0x%h", exp_tr.data, act_tr.data);
        end
    end
endtask
    // Ham in ket qua test sau khi ket thuc
    function void report();
        $display("===================================================");
        $display("SCOREBOARD REPORT: %0d PASS, %0d FAIL", pass_cnt, fail_cnt);
        $display("===================================================");
        if (fail_cnt == 0) begin
            $display("TEST PASSED!");
        end else begin
            $display("TEST FAILED!");
        end
        $display("====================================================");
    endfunction
    
endclass

