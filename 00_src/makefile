  1 # --- Khai báo biến ---
  2 TOP_MODULE = tb_uart_controller          # thay nếu tên top khác
  3 TB_FILE    = 01_tb/tb_uart_controller.sv     # điều chỉnh đường dẫn nếu cần
  4 FILELIST   = 00_src/filelist.f     # ← sửa thành cái này
  5
  6 # --- Lệnh mặc định ---
  7 all: clean init compile sim
  8
  9 # --- 1. Tạo thư viện ---
 10 init:
 11   vlib work
 12   vmap work work
 13
 14 # --- 2. Biên dịch ---
 15 compile:
 16   vlog -work work -sv -mfcu -timescale 1ns/1ps \
 17        +incdir+00_src \
 18        -f $(FILELIST) $(TB_FILE)
 19
 20 # --- 3a. Chạy simulation không GUI ---
 21 sim:
 22   vsim -c $(TOP_MODULE) -do "run -all; quit"
 23
 24 # --- 3b. Chạy với GUI ---
 25 gui:
 26   vsim -voptargs="+acc" $(TOP_MODULE) -do "add wave -r /*; run -all"
 27
 28 # --- 4. Dọn dẹp ---
 29 clean:
 30   rm -rf work transcript vsim.wlf dump.vcd modelsim.ini
