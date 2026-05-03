class uart_coverage;
    uart_transaction tr; 

    covergroup cg_uart;
        // 1. Dữ liệu (TC3, TC9): Kiểm tra đủ 256 giá trị và các giá trị biên
        cp_data: coverpoint tr.data {
            bins all_values[] = {[0:255]};
            bins corners[] = {8'h00, 8'hFF, 8'hA5, 8'h5A}; // Cho TC9
        }

        // 2. Trạng thái RX Enable (TC2): Đảm bảo đã test cả khi bật và tắt [cite: 50]
        cp_en: coverpoint tr.rx_enable; 

        // 3. Địa chỉ thanh ghi (TC6, TC12): Quan trọng để check Illegal Address
        cp_addr: coverpoint tr.addr {
            bins valid_regs[] = {8'h00, 8'h01}; // Các thanh ghi hợp lệ
            bins illegal = {8'h55};                   // Cho TC12
        }

        // 4. Khoảng cách giữa các gói (TC4): Kiểm tra Back-to-back
        cp_gap: coverpoint tr.gap_cycles {
            bins b2b = {0};           // Cho TC4: Gửi liên tục không nghỉ
            bins small_gap = {[1:5]};
            bins large_gap = {[6:20]};
        }

        // 5. Trạng thái FSM & Reset (TC1, TC10): Kiểm tra reset ở các trạng thái khác nhau
        cp_rst: coverpoint tr.reset_occurred {
            bins rst_happened = {1}; // Ghi nhận khi có reset giữa chừng
        }

        // 6. Cross Coverage: Kết hợp dữ liệu và trạng thái enable [cite: 52]
        cross_data_en: cross cp_data, cp_en;
    endgroup

    function new();
        cg_uart = new();// [cite: 54]
    endfunction

    // Cập nhật hàm sample để nhận thêm thông tin từ Monitor/Test
    task sample(uart_transaction t);
        this.tr = t; 
        cg_uart.sample(); 
    endtask 

    // Hàm báo cáo chi tiết từng mục để bạn theo dõi sát Test Plan
    function void report();
        $display("\n========================================");
        $display("      DETAILED COVERAGE REPORT          ");
        $display("========================================");
        $display("Total Functional Coverage : %0.2f%%", cg_uart.get_coverage()); 
        $display("Data Coverage (TC3/9)    : %0.2f%%", cg_uart.cp_data.get_inst_coverage());
        $display("Addr Coverage (TC6/12)   : %0.2f%%", cg_uart.cp_addr.get_inst_coverage());
        $display("Gap Coverage (TC4)       : %0.2f%%", cg_uart.cp_gap.get_inst_coverage());
        $display("Reset Coverage (TC1/10)  : %0.2f%%", cg_uart.cp_rst.get_inst_coverage());
        $display("========================================\n");
    endfunction
endclass
