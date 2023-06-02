//
// Copyright 2022 FRAUNHOFER INSTITUTE OF MICROELECTRONIC CIRCUITS AND SYSTEMS (IMS), DUISBURG, GERMANY.
// --- All rights reserved --- 
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
// Licensed under the Solderpad Hardware License v 2.1 (the "License");
// you may not use this file except in compliance with the License, or, at your option, the Apache License version 2.0.
// You may obtain a copy of the License at
// https://solderpad.org/licenses/SHL-2.1/
// Unless required by applicable law or agreed to in writing, any work distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and limitations under the License.
//

#include "airisc_uart.h"

void uart_init(volatile UART_t* const uart, uint8_t dataBits, uint8_t parity, uint8_t stopBits, uint8_t flowCtrl, uint32_t cyclesPerBit)
{
    uart->CTRL =
        ((dataBits - 5) & 0x07)    << 29 | // data bits (0: 5 ... 4: 9)
        (parity & 0x03)            << 27 | // parity (0: none, 1: even, 2: odd)
        (stopBits & 0x03)          << 25 | // stop bits (0: 1, 1: 1.5, 2: 2)
        (flowCtrl & 0x01)          << 24 | // flow control (0: none, 1: rts/cts)
        (cyclesPerBit & 0x00FFFFFF);       // baud reg (clock frequency / baud rate)
}

void uart_setDataBits(volatile UART_t* const uart, uint8_t dataBits)
{
    uart->CTRL_CLR = 0xE0000000;
    uart->CTRL_SET = ((uint32_t)((dataBits - 5) & 0x3)) << 29;
}

void uart_setParity(volatile UART_t* const uart, uint8_t parity)
{
    uart->CTRL_CLR = 0x18000000;
    uart->CTRL_SET = ((uint32_t)(parity & 0x03)) << 27;
}

void uart_setStopBits(volatile UART_t* const uart, uint8_t stopBits)
{
    uart->CTRL_CLR = 0x06000000;
    uart->CTRL_SET = ((uint32_t)(stopBits & 0x03)) << 25;
}

void uart_enableFlowCtrl(volatile UART_t* const uart)
{
    uart->CTRL_SET = 0x01000000;
}

void uart_disableFlowCtrl(volatile UART_t* const uart)
{
    uart->CTRL_CLR = 0x01000000;
}

void uart_setCyclesPerBit(volatile UART_t* const uart, uint32_t cyclesPerBit)
{
    uart->CTRL_CLR = 0x00FFFFFF;
    uart->CTRL_SET = (uint32_t)(cyclesPerBit & 0x00FFFFFF);
}

uint32_t uart_getDataBits(volatile UART_t* const uart)
{
    return ((uart->CTRL & 0xE0000000) >> 29) + 5;
}

uint32_t uart_getParity(volatile UART_t* const uart)
{
    return (uart->CTRL & 0x18000000) >> 27;
}

uint32_t uart_getStopBits(volatile UART_t* const uart)
{
    return (uart->CTRL & 0x06000000) >> 25;
}

int32_t uart_isFlowCtrlEnabled(volatile UART_t* const uart)
{
    if (uart->CTRL & 0x01000000)
        return -1;

    return 0;
}

uint32_t uart_getCyclesPerBit(volatile UART_t* const uart)
{
    return uart->CTRL & 0x00FFFFFF;
}

void uart_clrTxFIFO(volatile UART_t* const uart)
{
    uart->TX_STAT_SET = 0x80000000;
}

void uart_clrTxOverflowError(volatile UART_t* const uart)
{
    uart->TX_STAT_CLR = 0x00080000;
}

void uart_setTxWatermark(volatile UART_t* const uart, uint8_t watermark)
{
    uart->TX_STAT_CLR = 0x0000FF00;
    uart->TX_STAT_SET = ((uint32_t)watermark) << 8;
}

uint32_t uart_getTxOverflowError(volatile UART_t* const uart)
{
    return (uart->TX_STAT & 0x00080000) >> 19;
}

int32_t uart_isTxWatermarkReached(volatile UART_t* const uart)
{
    if (uart->TX_STAT & 0x00040000)
        return -1;

    return 0;
}

int32_t uart_isTxEmpty(volatile UART_t* const uart)
{
    if (uart->TX_STAT & 0x00020000)
        return -1;

    return 0;
}

int32_t uart_isTxFull(volatile UART_t* const uart)
{
    if (uart->TX_STAT & 0x00010000)
        return -1;

    return 0;
}

uint32_t uart_getTxWatermark(volatile UART_t* const uart)
{
    return (uart->TX_STAT & 0x0000FF00) >> 8;
}

uint32_t uart_getTxSize(volatile UART_t* const uart)
{
    return uart->TX_STAT & 0x000000FF;
}

void uart_clrRxFIFO(volatile UART_t* const uart)
{
    uart->RX_STAT_SET = 0x8000000;
}

void uart_clrRxFrameError(volatile UART_t* const uart)
{
    uart->RX_STAT_CLR = 0x00800000;
}

void uart_clrRxParityError(volatile UART_t* const uart)
{
    uart->RX_STAT_CLR = 0x00400000;
}

void uart_clrRxNoiseError(volatile UART_t* const uart)
{
    uart->RX_STAT_CLR = 0x00200000;
}

void uart_clrRxUnderflowError(volatile UART_t* const uart)
{
    uart->RX_STAT_CLR = 0x00100000;
}

void uart_clrRxOverflowError(volatile UART_t* const uart)
{
    uart->RX_STAT_CLR = 0x00080000;
}

void uart_setRxWatermark(volatile UART_t* const uart, uint8_t watermark)
{
    uart->RX_STAT_CLR = 0x0000FF00;
    uart->RX_STAT_SET = (uint32_t)watermark << 8;
}

uint32_t uart_getRxFrameError(volatile UART_t* const uart)
{
    return (uart->RX_STAT & 0x00800000) >> 23;
}

uint32_t uart_getRxParityError(volatile UART_t* const uart)
{
    return (uart->RX_STAT & 0x00400000) >> 22;
}

uint32_t uart_getRxNoiseError(volatile UART_t* const uart)
{
    return (uart->RX_STAT & 0x00200000) >> 21;
}

uint32_t uart_getRxUnderflowError(volatile UART_t* const uart)
{
    return (uart->RX_STAT & 0x00100000) >> 20;
}

uint32_t uart_getRxOverflowError(volatile UART_t* const uart)
{
    return (uart->RX_STAT & 0x00080000) >> 19;
}

int32_t uart_isRxWatermarkReached(volatile UART_t* const uart)
{
    if (uart->RX_STAT & 0x00040000)
        return -1;

    return 0;
}

int32_t uart_isRxEmpty(volatile UART_t* const uart)
{
    if (uart->RX_STAT & 0x00020000)
        return -1;

    return 0;
}

int32_t uart_isRxFull(volatile UART_t* const uart)
{
    if (uart->RX_STAT & 0x00010000)
        return -1;

    return 0;
}

uint32_t uart_getRxWatermark(volatile UART_t* const uart)
{
    return (uart->RX_STAT & 0x0000FF00) >> 8;
}

uint32_t uart_getRxSize(volatile UART_t* const uart)
{
    return uart->RX_STAT & 0x000000FF;
}

void uart_writeByte(volatile UART_t* const uart, uint8_t data)
{
    while (uart_isTxFull(uart));
    uart->DATA = data;
}

uint8_t uart_readByte(volatile UART_t* const uart)
{
    while (uart_isRxEmpty(uart));
    return uart->DATA;
}

void uart_writeData(volatile UART_t* const uart, const uint8_t* data, uint32_t size)
{
    for (uint32_t i = 0; i < size; i++)
        uart_writeByte(uart, data[i]);
}

void uart_readData(volatile UART_t* const uart, uint8_t* data, uint32_t size)
{
    for (uint32_t i = 0; i < size; i++)
        data[i] = uart_readByte(uart);
}

void uart_writeStr(volatile UART_t* const uart, const char* str)
{
    for (uint32_t i = 0; str[i] != '\0'; i++)
        uart_writeByte(uart, str[i]);

    uart_writeByte(uart, '\0');
}

uint32_t uart_readStr(volatile UART_t* const uart, char* str, uint32_t size)
{
    for (uint32_t i = 0; i < size; i++)
    {
        str[i] = uart_readByte(uart);
        if (str[i] == '\r')
        {
            str[i] = '\0';
            return i + 1;
        }
    }

    return size;
}
