//==============================================================================
// File          : uart_test.sv
// Author        : [vnguyen]
// Company       : [Verifast]
// Project       : UART Verification Environment
// Description   : UART Test class
//                 - Contains test cases and test logic
//                 - Connects to environment and runs tests
//
// Version       : 1.0
// Date          : 21-Apr-2026
//==============================================================================
/*
tai sao can test class?
- Enviroment la co dinh.
-Test class la thu thay doi.
Hôm nay muốn chạy Test ngẫu nhiên (Random Test), ngày mai  muốn viết một Test đặc biệt chỉ gửi toàn data 0xFF (Directed Test). 
Khi đó,  chỉ cần tạo một file uart_test_special.sv mới mà không cần sửa bất kỳ dòng code nào trong Environment.
*/
class uart_test; 
    uart_env env; // Connect to enviroment 
//top → test → env → driver/monitor → interface → DUT
    function new(virtual uart_if vif);
        env = new(vif); // Initialize environment with interface
    endfunction

// Task chay test case 
    task run();
        $display("===[TEST] START RANDOM TEST (300 packets)===");
        // Kich hoat tat ca component trong environment
        env.run();
        // Cho chay trong 300 goi tin
        #500000;
        //Sau khi chay xong, in ket qua test va bao cao coverage
        env.scb.report();
        env.cov.report();
        $display("===[TEST] END RANDOM TEST===");
        $finish;
    endtask
endclass

        
