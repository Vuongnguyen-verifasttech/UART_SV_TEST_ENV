class uart_coverage;
    uart_transaction tr;
    covergroup cg_uart;
        cp_data: coverpoint tr.data;
        cp_en:   coverpoint tr.rx_enable;
        cross_data_en: cross cp_data, cp_en;
    endgroup

    function new(); cg_uart = new(); endfunction
    function void sample(uart_transaction t);
        this.tr = t;
        cg_uart.sample();
    endfunction
endclass