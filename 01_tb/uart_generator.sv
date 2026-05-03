class uart_generator;
    mailbox #(uart_transaction) gen2drv;
    mailbox #(uart_transaction) gen2scb;
    int num_packets = 20;

    task run();
        uart_transaction tr;
        repeat(num_packets) begin
            tr = new();
            if (!tr.randomize()) $fatal("Gen: Randomization failed");
            gen2drv.put(tr);
            gen2scb.put(tr); // Gửi bản sao sang Scoreboard
        end
    endtask
endclass