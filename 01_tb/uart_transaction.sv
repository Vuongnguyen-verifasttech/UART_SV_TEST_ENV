class uart_transaction;
    rand bit [7:0] data;
    rand bit       rx_enable; 

    constraint c_data { data inside {[8'h00 : 8'hFF]}; }
    constraint c_enable { rx_enable dist {1 := 90, 0 := 10}; }

    function string to_string();
        return $sformatf("Data: 0x%h, EN: %b", data, rx_enable);
    endfunction
endclass