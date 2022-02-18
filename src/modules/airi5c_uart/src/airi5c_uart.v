//
// Copyright 2022 FRAUNHOFER INSTITUTE OF MICROELECTRONIC CIRCUITS AND SYSTEMS (IMS), DUISBURG, GERMANY.
// --- All rights reserved --- 
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
// Licensed under the Solderpad Hardware License v 2.1 (the “License”);
// you may not use this file except in compliance with the License, or, at your option, the Apache License version 2.0.
// You may obtain a copy of the License at
// https://solderpad.org/licenses/SHL-2.1/
// Unless required by applicable law or agreed to in writing, any work distributed under the License is distributed on an “AS IS” BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and limitations under the License.
//

`include "modules/airi5c_uart/src/airi5c_uart_constants.vh"
`include "airi5c_hasti_constants.vh"

module airi5c_uart
#(
    parameter   BASE_ADDR     = 'hC0000200,
    parameter   TX_ADDR_WIDTH = 5,
    parameter   RX_ADDR_WIDTH = 5,
    parameter   TX_MARK       = 8,
    parameter   RX_MARK       = 24
)
(
    input                                   n_reset,
    input                                   clk,

    output                                  tx,
    input                                   rx,
    input                                   cts,
    output                                  rts,

    output                                  int_any,
    output                                  int_tx_full,
    output                                  int_tx_empty,
    output                                  int_tx_mark_reached,
    output                                  int_tx_overflow_error,
    output                                  int_rx_full,
    output                                  int_rx_empty,
    output                                  int_rx_mark_reached,
    output                                  int_rx_overflow_error,
    output                                  int_rx_underflow_error,
    output                                  int_rx_noise_error,
    output                                  int_rx_parity_error,
    output                                  int_rx_frame_error,

    // AHB-Lite interface
    input       [`HASTI_ADDR_WIDTH-1:0]     haddr,      // address
    input                                   hwrite,     // write enable
//  input       [`HASTI_SIZE_WIDTH-1:0]     hsize,      // unused
//  input       [`HASTI_BURST_WIDTH-1:0]    hburst,     // unused
//  input                                   hmastlock,  // unused
//  input       [`HASTI_PROT_WIDTH-1:0]     hprot,      // unused
    input       [`HASTI_TRANS_WIDTH-1:0]    htrans,     // transfer type (IDLE or NONSEQUENTIAL)
    input       [`HASTI_BUS_WIDTH-1:0]      hwdata,     // data in
    output  reg [`HASTI_BUS_WIDTH-1:0]      hrdata,     // data out
    output                                  hready,     // transfer finished
    output      [`HASTI_RESP_WIDTH-1:0]     hresp       // transfer status (OKAY or ERROR)
);

    `define     STACK_ADDR                  BASE_ADDR + 0
    `define     CTRL_REG_ADDR               BASE_ADDR + 4
    `define     CTRL_SET_ADDR               BASE_ADDR + 8
    `define     CTRL_CLR_ADDR               BASE_ADDR + 12
    `define     TX_STAT_REG_ADDR            BASE_ADDR + 16
    `define     TX_STAT_SET_ADDR            BASE_ADDR + 20
    `define     TX_STAT_CLR_ADDR            BASE_ADDR + 24
    `define     RX_STAT_REG_ADDR            BASE_ADDR + 28
    `define     RX_STAT_SET_ADDR            BASE_ADDR + 32
    `define     RX_STAT_CLR_ADDR            BASE_ADDR + 36

    reg         [`HASTI_ADDR_WIDTH-1:0]     haddr_reg;
    reg                                     hwrite_reg;
    reg         [`HASTI_TRANS_WIDTH-1:0]    htrans_reg;

    assign                                  hready                  = 1'b1;
    assign                                  hresp                   = `HASTI_RESP_OKAY;

    wire                                    push                    = hwrite_reg && haddr_reg == `STACK_ADDR;
    reg         [8:0]                       data_in;                // read value in first clock cycle, pop vaue in second clock cycle
    wire                                    pop                     = !hwrite_reg && haddr_reg == `STACK_ADDR && |htrans_reg;
    wire        [8:0]                       data_out;

    // control signals
    reg         [2:0]                       data_bits;              // 5, 6, 7, 8, 9 (if parity is none)
    reg         [1:0]                       parity;                 // none, odd, even
    reg         [1:0]                       stop_bits;              // 1, 1.5, 2
    reg                                     flow_ctrl;              // off, on (RTS/CTS)
    reg         [23:0]                      baud_reg;               // = c_bit = clock_freq / baud rate (system clock cycles per bit)

    wire        [31:0]                      ctrl_reg                =
                                            {   // signal               // bits   // access
                                                data_bits,              // 31-29  // rw
                                                parity,                 // 28-27  // rw
                                                stop_bits,              // 26-25  // rw
                                                flow_ctrl,              // 24     // rw
                                                baud_reg                // 23-0   // rw
                                            };

    // tx status signals
    wire        [TX_ADDR_WIDTH:0]           tx_size;
    wire                                    tx_full;
    wire                                    tx_empty;
    wire                                    tx_mark_reached;
    reg                                     tx_overflow_error;
    reg                                     tx_full_IE;
    reg                                     tx_empty_IE;
    reg                                     tx_mark_reached_IE;
    reg                                     tx_overflow_error_IE;

    wire        [31:0]                      tx_stat_reg             =
                                            {   // signal               // bit    // access
                                                {12'b0000000000000},
                                                tx_overflow_error_IE,   // 19     // rw
                                                tx_mark_reached_IE,     // 18     // rw
                                                tx_empty_IE,            // 17     // rw
                                                tx_full_IE,             // 16     // rw
                                                {4'b0000},
                                                tx_overflow_error,      // 11     // rw
                                                tx_mark_reached,        // 10     // r
                                                tx_empty,               // 9      // r
                                                tx_full,                // 8      // r
                                                {(7-TX_ADDR_WIDTH){1'b0}},
                                                tx_size                 // 7-0    // r
                                            };

    // rx status signals
    wire        [RX_ADDR_WIDTH:0]           rx_size;
    wire                                    rx_full;
    wire                                    rx_empty;
    wire                                    rx_mark_reached;
    reg                                     rx_overflow_error;          wire overflow_error_w;
    reg                                     rx_underflow_error;
    reg                                     rx_noise_error;             wire noise_error_w;
    reg                                     rx_parity_error;            wire parity_error_w;
    reg                                     rx_frame_error;             wire frame_error_w;
    reg                                     rx_full_IE;
    reg                                     rx_empty_IE;
    reg                                     rx_mark_reached_IE;
    reg                                     rx_overflow_error_IE;
    reg                                     rx_underflow_error_IE;
    reg                                     rx_noise_error_IE;
    reg                                     rx_parity_error_IE;
    reg                                     rx_frame_error_IE;

    wire        [31:0]                      rx_stat_reg             =
                                            {   // signal               // bit    // access
                                                {8'b00000000},
                                                rx_frame_error_IE,      // 23     // rw
                                                rx_parity_error_IE,     // 22     // rw
                                                rx_noise_error_IE,      // 21     // rw
                                                rx_underflow_error_IE,  // 20     // rw
                                                rx_overflow_error_IE,   // 19     // rw
                                                rx_mark_reached_IE,     // 18     // rw
                                                rx_empty_IE,            // 17     // rw
                                                rx_full_IE,             // 16     // rw
                                                rx_frame_error,         // 15     // rw
                                                rx_parity_error,        // 14     // rw
                                                rx_noise_error,         // 13     // rw
                                                rx_underflow_error,     // 12     // rw
                                                rx_overflow_error,      // 11     // rw
                                                rx_mark_reached,        // 10     // r
                                                rx_empty,               // 9      // r
                                                rx_full,                // 8      // r
                                                {(7-RX_ADDR_WIDTH){1'b0}},
                                                rx_size                 // 7-0    // r
                                            };

    assign                                  rx_mark_reached         = rx_size >= RX_MARK;
    assign                                  tx_mark_reached         = tx_size <= TX_MARK;

    assign                                  int_tx_full             = tx_full             && tx_full_IE;
    assign                                  int_tx_empty            = tx_empty            && tx_empty_IE;
    assign                                  int_tx_mark_reached     = tx_mark_reached     && tx_mark_reached_IE;
    assign                                  int_tx_overflow_error   = tx_overflow_error   && tx_overflow_error_IE;
    assign                                  int_rx_full             = rx_full             && rx_full_IE;
    assign                                  int_rx_empty            = rx_empty            && rx_empty_IE;
    assign                                  int_rx_mark_reached     = rx_mark_reached     && rx_mark_reached_IE;
    assign                                  int_rx_overflow_error   = rx_overflow_error   && rx_overflow_error_IE;
    assign                                  int_rx_underflow_error  = rx_underflow_error  && rx_underflow_error_IE;
    assign                                  int_rx_noise_error      = rx_noise_error      && rx_noise_error_IE;
    assign                                  int_rx_parity_error     = rx_parity_error     && rx_parity_error_IE;
    assign                                  int_rx_frame_error      = rx_frame_error      && rx_frame_error_IE;

    assign                                  int_any                 =
                                                int_tx_full           || int_tx_empty           || int_tx_mark_reached    ||
                                                int_tx_overflow_error || int_rx_full            || int_rx_empty           ||
                                                int_rx_mark_reached   || int_rx_overflow_error  || int_rx_underflow_error ||
                                                int_rx_noise_error    || int_rx_parity_error    || int_rx_frame_error;

    always @(posedge clk, negedge n_reset) begin
        if (!n_reset) begin
            haddr_reg   <= `HASTI_ADDR_WIDTH'h0;
            hwrite_reg  <= 1'b0;
            htrans_reg  <= `HASTI_TRANS_WIDTH'h0;
        end

        else begin
            haddr_reg   <= haddr;
            hwrite_reg  <= hwrite;
            htrans_reg  <= htrans;
        end
    end

    always @(posedge clk, negedge n_reset) begin
        if (!n_reset) begin
            hrdata                <= `HASTI_BUS_WIDTH'h0;
            // default UART settings
            data_bits             <= `UART_DATA_BITS_8;
            parity                <= `UART_PARITY_NONE;
            stop_bits             <= `UART_STOP_BITS_1;
            flow_ctrl             <= `UART_FLOW_CTRL_OFF;
            baud_reg              <= 24'd3333;  // cycles_per_bit = clock_freq / baud = 9600 / 32 MHz
            // default status and interrupt settings
            tx_overflow_error_IE  <= 1'b0;
            tx_mark_reached_IE    <= 1'b0;
            tx_empty_IE           <= 1'b0;
            tx_full_IE            <= 1'b0;
            rx_frame_error_IE     <= 1'b0;
            rx_parity_error_IE    <= 1'b0;
            rx_noise_error_IE     <= 1'b0;
            rx_underflow_error_IE <= 1'b0;
            rx_overflow_error_IE  <= 1'b0;
            rx_mark_reached_IE    <= 1'b0;
            rx_empty_IE           <= 1'b0;
            rx_full_IE            <= 1'b0;
            tx_overflow_error     <= 1'b0;
            rx_frame_error        <= 1'b0;
            rx_parity_error       <= 1'b0;
            rx_noise_error        <= 1'b0;
            rx_underflow_error    <= 1'b0;
            rx_overflow_error     <= 1'b0;
        end

        else begin
            // refresh status signals
            tx_overflow_error     <= tx_overflow_error  || push && tx_full;
            rx_frame_error        <= rx_frame_error     || frame_error_w;
            rx_parity_error       <= rx_parity_error    || parity_error_w;
            rx_noise_error        <= rx_noise_error     || noise_error_w;
            rx_overflow_error     <= rx_overflow_error  || overflow_error_w;
            // write access
            if (hwrite_reg) begin
                case (haddr_reg)
                `CTRL_REG_ADDR:     begin
                                        // invalid number of data bits
                                        if (hwdata[31:29] >= `UART_DATA_BITS_9) begin
                                            data_bits         <= `UART_DATA_BITS_9; // set data bits to max valid value instead
                                            parity            <= `UART_PARITY_NONE; // if 9 data bits are set, parity is set to none!
                                            stop_bits         <= `UART_STOP_BITS_1; // if 9 data bits are set, number of stop are set to 1!
                                        end
                                        else begin
                                            data_bits         <= hwdata[31:29];
                                            // only set parity if the value is valid
                                            if (~&hwdata[28:27])
                                                parity        <= hwdata[28:27];
                                            // only set number of stop bits if the value is valid
                                            if (~&hwdata[26:25])
                                                stop_bits     <= hwdata[26:25];
                                        end
                                        flow_ctrl             <= hwdata[24];
                                        baud_reg              <= hwdata[23:0];
                                    end
                `CTRL_SET_ADDR:     begin
                                        // set results in invalid number of data bits
                                        if ((hwdata[31:29] | data_bits) >= `UART_DATA_BITS_9) begin
                                            data_bits         <= `UART_DATA_BITS_9; // set data bits to max valid value instead
                                            parity            <= `UART_PARITY_NONE; // if 9 data bits are set, parity is set to none!
                                            stop_bits         <= `UART_STOP_BITS_1; // if 9 data bits are set, number of stop are set to 1!
                                        end
                                        else begin
                                            data_bits         <= hwdata[31:29] | data_bits;
                                            // only set parity if resulting value is valid
                                            if (~&(hwdata[28:27] | parity))
                                                parity        <= hwdata[28:27] | parity;
                                            // only set number of stop bits if resulting value is valid
                                            if (~&(hwdata[26:25] | stop_bits))
                                                stop_bits     <= hwdata[26:25] | stop_bits;
                                        end

                                        flow_ctrl             <= hwdata[24]   || flow_ctrl;
                                        baud_reg              <= hwdata[23:0] |  baud_reg;
                                    end
                `CTRL_CLR_ADDR:     begin
                                        // while clearing, the value of each field always decreases, thus no invalids here
                                        data_bits             <= ~hwdata[31:29] &  data_bits;
                                        parity                <= ~hwdata[28:27] &  parity;
                                        stop_bits             <= ~hwdata[26:25] &  stop_bits;
                                        flow_ctrl             <= !hwdata[24]    && flow_ctrl;
                                        baud_reg              <= ~hwdata[23:0]  &  baud_reg;
                                    end
                `TX_STAT_REG_ADDR:  begin
                                        tx_overflow_error_IE  <= hwdata[19];
                                        tx_mark_reached_IE    <= hwdata[18];
                                        tx_empty_IE           <= hwdata[17];
                                        tx_full_IE            <= hwdata[16];
                                        tx_overflow_error     <= hwdata[11];
                                    end
                `TX_STAT_SET_ADDR:  begin
                                        tx_overflow_error_IE  <= hwdata[19] || tx_overflow_error_IE;
                                        tx_mark_reached_IE    <= hwdata[18] || tx_mark_reached_IE ;
                                        tx_empty_IE           <= hwdata[17] || tx_empty_IE;
                                        tx_full_IE            <= hwdata[16] || tx_full_IE ;
                                        tx_overflow_error     <= hwdata[11] || tx_overflow_error;
                                    end
                `TX_STAT_CLR_ADDR:  begin
                                        tx_overflow_error_IE  <= !hwdata[19] && tx_overflow_error_IE;
                                        tx_mark_reached_IE    <= !hwdata[18] && tx_mark_reached_IE ;
                                        tx_empty_IE           <= !hwdata[17] && tx_empty_IE;
                                        tx_full_IE            <= !hwdata[16] && tx_full_IE ;
                                        tx_overflow_error     <= !hwdata[11] && tx_overflow_error;
                                    end
                `RX_STAT_REG_ADDR:  begin
                                        rx_frame_error_IE     <= hwdata[23];
                                        rx_parity_error_IE    <= hwdata[22];
                                        rx_noise_error_IE     <= hwdata[21];
                                        rx_underflow_error_IE <= hwdata[20];
                                        rx_overflow_error_IE  <= hwdata[19];
                                        rx_mark_reached_IE    <= hwdata[18];
                                        rx_empty_IE           <= hwdata[17];
                                        rx_full_IE            <= hwdata[16];
                                        rx_frame_error        <= hwdata[15];
                                        rx_parity_error       <= hwdata[14];
                                        rx_noise_error        <= hwdata[13];
                                        rx_underflow_error    <= hwdata[12];
                                        rx_overflow_error     <= hwdata[11];
                                    end
                `RX_STAT_SET_ADDR:  begin
                                        rx_frame_error_IE     <= hwdata[23] || rx_frame_error_IE;
                                        rx_parity_error_IE    <= hwdata[22] || rx_parity_error_IE;
                                        rx_noise_error_IE     <= hwdata[21] || rx_noise_error_IE;
                                        rx_underflow_error_IE <= hwdata[20] || rx_underflow_error_IE;
                                        rx_overflow_error_IE  <= hwdata[19] || rx_overflow_error_IE;
                                        rx_mark_reached_IE    <= hwdata[18] || rx_mark_reached_IE;
                                        rx_empty_IE           <= hwdata[17] || rx_empty_IE;
                                        rx_full_IE            <= hwdata[16] || rx_full_IE;
                                        rx_frame_error        <= hwdata[15] || rx_frame_error;
                                        rx_parity_error       <= hwdata[14] || rx_parity_error;
                                        rx_noise_error        <= hwdata[13] || rx_noise_error;
                                        rx_underflow_error    <= hwdata[12] || rx_underflow_error;
                                        rx_overflow_error     <= hwdata[11] || rx_overflow_error;
                                    end
                `RX_STAT_CLR_ADDR:  begin
                                        rx_frame_error_IE     <= !hwdata[23] && rx_frame_error_IE;
                                        rx_parity_error_IE    <= !hwdata[22] && rx_parity_error_IE;
                                        rx_noise_error_IE     <= !hwdata[21] && rx_noise_error_IE;
                                        rx_underflow_error_IE <= !hwdata[20] && rx_underflow_error_IE;
                                        rx_overflow_error_IE  <= !hwdata[19] && rx_overflow_error_IE;
                                        rx_mark_reached_IE    <= !hwdata[18] && rx_mark_reached_IE;
                                        rx_empty_IE           <= !hwdata[17] && rx_empty_IE;
                                        rx_full_IE            <= !hwdata[16] && rx_full_IE;
                                        rx_frame_error        <= !hwdata[15] && rx_frame_error;
                                        rx_parity_error       <= !hwdata[14] && rx_parity_error;
                                        rx_noise_error        <= !hwdata[13] && rx_noise_error;
                                        rx_underflow_error    <= !hwdata[12] && rx_underflow_error;
                                        rx_overflow_error     <= !hwdata[11] && rx_overflow_error;
                                    end
                endcase
            end
            // read access
            if (|htrans) begin
                case (haddr)
                `STACK_ADDR:        begin
                                        rx_underflow_error  <= rx_underflow_error || rx_empty;
                                        hrdata              <= {23'h000000, data_out};
                                    end
                `CTRL_REG_ADDR:     hrdata <= ctrl_reg;
                `TX_STAT_REG_ADDR:  hrdata <= tx_stat_reg;
                `RX_STAT_REG_ADDR:  hrdata <= rx_stat_reg;
                default:            hrdata <= 32'h00000000;
                endcase
            end
        end
    end


    always @(*) begin
        case (data_bits)
        `UART_DATA_BITS_5:  data_in <= hwdata[4:0];
        `UART_DATA_BITS_6:  data_in <= hwdata[5:0];
        `UART_DATA_BITS_7:  data_in <= hwdata[6:0];
        `UART_DATA_BITS_8:  data_in <= hwdata[7:0];
        default:            data_in <= hwdata[8:0];
        endcase
    end

    airi5c_uart_tx #(TX_ADDR_WIDTH) transmitter
    (
        .clk(clk),
        .n_reset(n_reset),

        .tx(tx),
        .cts(cts),

        .ctrl_reg(ctrl_reg),

        .push(push),
        .data_in(data_in),
        .size(tx_size),
        .empty(tx_empty),
        .full(tx_full)
    );

    airi5c_uart_rx #(RX_ADDR_WIDTH) receiver
    (
        .clk(clk),
        .n_reset(n_reset),

        .rx(rx),
        .rts(rts),

        .ctrl_reg(ctrl_reg),

        .pop(pop),
        .data_out(data_out),
        .size(rx_size),
        .empty(rx_empty),
        .full(rx_full),

        .noise_error(noise_error_w),
        .parity_error(parity_error_w),
        .frame_error(frame_error_w),
        .overflow_error(overflow_error_w)
    );

endmodule