//==============================================================================
// File          : uart_env.sv
// Author        : [vnguyen]
// Company       : [Verifast]
// Project       : UART Verification Environment
// Description   : UART Environment class
//                 - Contains generator, driver, monitor, scoreboard and coverage
//                 - Manages mailboxes and semaphore for synchronization
//                 - Connects all components and interfaces with DUT
//
// Version       : 1.0
// Date          : 21-Apr-2026
//==============================================================================
/*

Tai sao can environment?
- Environment la 1 class chua toan bo testbench, gom generator, driver, monitor, scoreboard va coverage.
- Environment giup ket noi cac component voi nhau va voi DUT, qua do tao ra 1 testbench hoan chinh va de quan ly.
- Thay vi khai bao hang chuc doi tuong va ket noi mailboxes trong testbench, ta chi can lam 1 lan trong environment, qua do giam thieu loi va tang tinh module hoa.

*/
class uart_env;
    
    // Components of the environment
    uart_generator gen;
    uart_driver drv;
    uart_monitor mon;
    uart_scoreboard scb;
    uart_coverage cov;
    // Mailboxes for communication
    mailbox #(uart_transaction) gen2drv; // Generator to Driver
    mailbox #(uart_transaction) gen2scb; // Generator to Scoreboard
    mailbox #(uart_transaction) mon2scb; // Monitor to Scoreboard

    // Semaphore for bus access synchronization between driver and monitor
    semaphore bus_sem;

    // connnect with DUT through interface
    virtual uart_if vif; 

    // Constructor: initialize components and connect mailboxes
    function new(virtual uart_if vif);
        this.vif = vif;

        // Initialize mailboxes
        gen2drv = new();
        gen2scb = new();
        mon2scb = new();
        bus_sem = new(1); // Initialize semaphore with 1 token

        // Initialize components and connect mailboxes
        gen = new();
        gen.gen2drv = gen2drv;
        gen.gen2scb = gen2scb;
        
        drv = new();
        drv.gen2drv = gen2drv;
        drv.vif = vif;
        drv.bus_sem = bus_sem;

        mon = new();
        mon.vif = vif;
        mon.mon2scb = mon2scb;
        mon.bus_sem = bus_sem;

        cov = new();
        scb = new();
        scb.mon2scb = mon2scb;
        scb.gen2scb = gen2scb;
        scb.cov = cov; // Ket noi scoreboard voi coverage
    endfunction
    // Task to run the environment: start generator, driver, monitor, and scoreboard
    task run();
        fork
            gen.run();
            drv.run();
            mon.run();
            scb.run();

        join_none // Chay cac component cung luc, khong doi
    endtask
endclass


