class uart_transaction;
    rand bit rx_enable; //1: Enable RX, 0: Disable RX
    rand bit [7:0] data;
    // Thêm các biến sau để phục vụ Coverage
        bit [7:0] addr;           // Cho TC6, TC12
            int       gap_cycles;     // Cho TC4 (Lỗi của bạn nằm ở đây)
                bit       reset_occurred; // Cho TC1, TC10
    // Thêm các biến mới để Coverage và Scoreboard có thể nhận diện
      //  bit [7:0] addr;           // Dùng cho Case 5, 6, 12
          //  bit       reset_occurred; // Dùng cho Case 1, 10
// Constraint to ensure percentage of rx_enable values
//constraint c_rx_en { rx_enable == 1; } // Ép buộc luôn bật nhận dữ liệu

    constraint c_rx_enable {
        rx_enable dist {1:=80, 0:=20};  // 80% chance to enable RX, 20% chance to disable   
     }
// fucntion display to debug
    function string to_string();
        return $sformatf("Data: 0x%h, RX_EN: %b", data, rx_enable);
    endfunction

endclass

