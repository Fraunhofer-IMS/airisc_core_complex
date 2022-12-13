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

#ifndef AIRISC_UART_H_
#define AIRISC_UART_H_

#include "airisc_defines.h"

#define UART_DATA_BITS_5	0x05
#define UART_DATA_BITS_6	0x06
#define UART_DATA_BITS_7	0x07
#define UART_DATA_BITS_8	0x08
#define UART_DATA_BITS_9	0x09

#define UART_PARITY_NONE	0x00
#define UART_PARITY_EVEN	0x01
#define UART_PARITY_ODD		0x02

#define UART_STOP_BITS_1	0x00
#define UART_STOP_BITS_15	0x01
#define UART_STOP_BITS_2	0x02

#define UART_FLOW_CTRL_NONE	0x00
#define UART_FLOW_CTRL_RTS_CTS 	0x01

// control reg
void uart_init(volatile UART_t* const uart, uint8_t dataBits, uint8_t parity, uint8_t stopBits, uint8_t flowCtrl, uint32_t cyclesPerBit);
void uart_setDataBits(volatile UART_t* const uart, uint8_t dataBits);
void uart_setParity(volatile UART_t* const uart, uint8_t parity);
void uart_setStopBits(volatile UART_t* const uart, uint8_t stopBits);
void uart_enableFlowCtrl(volatile UART_t* const uart);
void uart_disableFlowCtrl(volatile UART_t* const uart);
void uart_setCyclesPerBit(volatile UART_t* const uart, uint32_t cyclesPerBit /* = baudRate / clock frequency */);

uint32_t uart_getDataBits(volatile UART_t* const uart);
uint32_t uart_getParity(volatile UART_t* const uart);
uint32_t uart_getStopBits(volatile UART_t* const uart);
int32_t uart_isFlowCtrlEnabled(volatile UART_t* const uart);
uint32_t uart_getCyclesPerBit(volatile UART_t* const uart);

// tx stat reg
void uart_clrTxFIFO(volatile UART_t* const uart);
void uart_clrTxOverflowError(volatile UART_t* const uart);
void uart_setTxWatermark(volatile UART_t* const uart, uint8_t watermark);

uint32_t uart_getTxOverflowError(volatile UART_t* const uart);
int32_t uart_isTxWatermarkReached(volatile UART_t* const uart);
int32_t uart_isTxEmpty(volatile UART_t* const uart);
int32_t uart_isTxFull(volatile UART_t* const uart);
uint32_t uart_getTxWatermark(volatile UART_t* const uart);
uint32_t uart_getTxSize(volatile UART_t* const uart);

// rx stat reg
void uart_clrRxFIFO(volatile UART_t* const uart);
void uart_clrRxFrameError(volatile UART_t* const uart);
void uart_clrRxParityError(volatile UART_t* const uart);
void uart_clrRxNoiseError(volatile UART_t* const uart);
void uart_clrRxUnderflowError(volatile UART_t* const uart);
void uart_clrRxOverflowError(volatile UART_t* const uart);
void uart_setRxWatermark(volatile UART_t* const uart, uint8_t watermark);

uint32_t uart_getRxFrameError(volatile UART_t* const uart);
uint32_t uart_getRxParityError(volatile UART_t* const uart);
uint32_t uart_getRxNoiseError(volatile UART_t* const uart);
uint32_t uart_getRxUnderflowError(volatile UART_t* const uart);
uint32_t uart_getRxOverflowError(volatile UART_t* const uart);
int32_t uart_isRxWatermarkReached(volatile UART_t* const uart);
int32_t uart_isRxEmpty(volatile UART_t* const uart);
int32_t uart_isRxFull(volatile UART_t* const uart);
uint32_t uart_getRxWatermark(volatile UART_t* const uart);
uint32_t uart_getRxSize(volatile UART_t* const uart);

// write/read
void uart_writeByte(volatile UART_t* const uart, uint8_t data);
uint8_t uart_readByte(volatile UART_t* const uart);

void uart_writeData(volatile UART_t* const uart, const uint8_t* data, uint32_t size);
void uart_readData(volatile UART_t* const uart, uint8_t* data, uint32_t size);

void uart_writeStr(volatile UART_t* const uart, const char* str);
uint32_t uart_readStr(volatile UART_t* const uart, char* str, uint32_t size);

#endif

