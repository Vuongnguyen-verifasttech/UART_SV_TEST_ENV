// UART Generator class
/*hiem vu la tao ra cac tran gui den driver va scoreboard thong qua mailbox(chi gui den scoreboard khi
 rx_enable = 1 de tranh gui nhung tran khong duoc xu ly)
*/
class uart_generator;
    mailbox #(uart_transaction ) gen2drv; // Gửi transaction đến Driver
    mailbox #(uart_transaction ) gen2scb; // Gui transaction đến Scoreboard

    int num_packet = 100 ; // so luong packet muon tao
// Trong uart_generator.sv
task start_random(int count);
    repeat(count) begin
            uart_transaction tr = new();
                    if(!tr.randomize()) $error("Randomization failed");
                            gen2drv.put(tr);
                                end
                                endtask

                                task send_pattern(bit [7:0] data);
                                    uart_transaction tr = new();
                                        tr.data = data;
                                            gen2drv.put(tr);
                                            endtask
    task run();
        uart_transaction tr; 
        repeat(num_packet) begin 
            tr = new(); // tao moi transaction
            // Randomize transaction, nếu thất bại thì dừng test
            if (!tr.randomize()) $fatal("Gen: Randomize failed");
            gen2drv.put(tr); // Gui transaction den Driver 
            // Logic gui transaction den Scoreboard chi khi rx_enable = 1, de tranh gui nhung transaction khong duoc xu ly
            if (tr.rx_enable) begin
                gen2scb.put(tr); // Gui transaction den Scoreboard
            end else begin 
                $display("[GEN] Generated: %s",tr.to_string());
        end
        end
    endtask
endclass


