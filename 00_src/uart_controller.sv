module uart_controller (
    // -- Serial Interface --
    input  logic       clk,
    input  logic       rst_n,
    input  logic       RXD,

    // -- Host Parallel Interface --
    input  logic       UREG_RDWR,  
    input  logic [7:0] UREG_ADDR, 
    input  logic [7:0] UREG_WRDAT, 
    input  logic       UREG_REQ, 
    output logic       UREG_GNT, 
    output logic [7:0] UREG_RDDAT, 

    // -- Interrupt --
    output logic       UART_INTR 
);

    // --- Định nghĩa các trạng thái ---
    typedef enum logic [2:0] {
        IDLE      = 3'b000,
        START_BIT = 3'b001,
        DATA_BITS = 3'b010,
        STOP_BITS = 3'b011,
        RX_DONE   = 3'b100
    } state_t;

    state_t curr_state, next_state;

    // --- Các thanh ghi nội bộ ---
    logic [7:0] core_ctrl; // Addr: 8'h00
    logic [7:0] rx_data;   // Addr: 8'h01
    logic [7:0] shift_reg; // Thanh ghi dịch
    logic [2:0] bit_cnt;   // Bộ đếm bit (0-7)
    logic       stop_cnt;  // Bộ đếm stop bit

    // --- Logic Host Interface ---
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            core_ctrl <= 8'h02; 
            UREG_GNT  <= 1'b0;
            UART_INTR <= 1'b0;
            rx_data   <= 8'h00;
        end else begin
            UREG_GNT <= 1'b0;
            if (UREG_REQ && !UREG_GNT) begin
                UREG_GNT <= 1'b1;
                if (!UREG_RDWR) begin // Read
                    if (UREG_ADDR == 8'h01) UART_INTR <= 1'b0; 
                end else if (UREG_ADDR == 8'h00) begin
                    core_ctrl <= UREG_WRDAT;
                end
            end

            if (curr_state == RX_DONE) begin
                rx_data   <= shift_reg; // Chốt dữ liệu cuối cùng
                UART_INTR <= 1'b1;
            end
        end
    end

    assign UREG_RDDAT = (UREG_ADDR == 8'h00) ? core_ctrl : 
                        (UREG_ADDR == 8'h01) ? rx_data   : 8'h00;
    
    // --- FSM Next State Logic ---
    always_comb begin
        next_state = curr_state;
        case (curr_state)
            IDLE:      if (core_ctrl[1] && !RXD) next_state = START_BIT;
            START_BIT: next_state = DATA_BITS;
            DATA_BITS: if (bit_cnt == 3'd7) next_state = STOP_BITS;
            STOP_BITS: if (stop_cnt == 1'b1) next_state = RX_DONE;
            //RX_DONE:   next_state = IDLE;
            // Thay vì luôn về IDLE, hãy kiểm tra Start bit ngay tại đây
            RX_DONE:   begin
            if (core_ctrl[1] && !RXD) 
                next_state = START_BIT; // Nhảy thẳng sang gói mới[cite: 10]
            else 
                next_state = IDLE;
        end
            default:   next_state = IDLE;
        endcase
    end

    // --- FSM Sequential Logic (Cách 1: Dịch bit thực thụ) ---
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            curr_state <= IDLE;
            bit_cnt    <= 3'd0;
            stop_cnt   <= 1'b0;
            shift_reg  <= 8'h00;
        end else begin
            curr_state <= next_state;
            case (next_state)
                IDLE: begin
                    bit_cnt  <= 3'd0;
                    stop_cnt <= 1'b0;
                end
                DATA_BITS: begin
                    // Dịch phải: Đẩy RXD vào MSB (bit 7), dịch các bit cũ về phía LSB
                    // Vì UART truyền LSB trước, sau 8 lần dịch, bit đầu tiên sẽ nằm ở vị trí [0]
                    shift_reg <= {RXD, shift_reg[7:1]}; 
                    
                    if (curr_state == DATA_BITS)
                        bit_cnt <= bit_cnt + 1;
                    else
                        bit_cnt <= 3'd0; // Bắt đầu đếm từ 0 khi vừa vào state
                end
                STOP_BITS: begin
                    if (curr_state == STOP_BITS) stop_cnt <= stop_cnt + 1;
                    else stop_cnt <= 1'b0;
                end
            endcase
        end
    end
endmodule