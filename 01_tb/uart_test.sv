class uart_test;
    uart_env env;
    function new(virtual uart_if v); env = new(v); endfunction
task run();
    $display("=== STARTING TEST SCENARIO ===");
    env.run(); 
    
    // Đợi cho đến khi Scoreboard nhận đủ số gói tin mong muốn
    // Giả sử bạn muốn test 10 gói tin như bản cũ
    wait(env.scb.pass + env.scb.fail == env.gen.num_packets);
    
    #100; // Chờ thêm một chút cho chắc chắn
    env.scb.report(); // Gọi hàm báo cáo (nếu có)
    $display("Final Score: PASS=%0d, FAIL=%0d", env.scb.pass, env.scb.fail);
    $finish;
endtask
endclass