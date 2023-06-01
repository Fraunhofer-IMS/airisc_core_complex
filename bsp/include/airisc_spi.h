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

#ifndef AIRISC_SPI_H_
#define AIRISC_SPI_H_

#include "airisc_defines.h"

#define SPI_MASTER          0x01
#define SPI_SLAVE           0x00
#define SPI_MODE_0          0x00
#define SPI_MODE_1          0x01
#define SPI_MODE_2          0x02
#define SPI_MODE_3          0x03
#define SPI_CLK_DIV_2       0x00
#define SPI_CLK_DIV_4       0x01
#define SPI_CLK_DIV_8       0x02
#define SPI_CLK_DIV_16      0x03
#define SPI_CLK_DIV_32      0x04
#define SPI_CLK_DIV_64      0x05
#define SPI_CLK_DIV_128     0x06
#define SPI_CLK_DIV_256     0x07
#define SPI_SS_0            0x00
#define SPI_SS_1            0x01
#define SPI_SS_2            0x02
#define SPI_SS_3            0x03
#define SPI_ENABLE_OUTPUTS  0x01
#define SPI_DISABLE_OUTPUTS 0x00

// control reg
void spi_init(volatile SPI_t* const spi, uint8_t master, uint8_t mode, uint8_t clkDiv, uint8_t activeSlave, uint8_t oe);
void spi_enableOutputs(volatile SPI_t* const spi);
void spi_disableOutputs(volatile SPI_t* const spi);
void spi_setMaster(volatile SPI_t* const spi);
void spi_setSlave(volatile SPI_t* const spi);
void spi_setMode(volatile SPI_t* const spi, uint8_t mode);
void spi_setClkDiv(volatile SPI_t* const spi, uint8_t clkDiv);
void spi_setActiveSlave(volatile SPI_t* const spi, uint8_t slave);
void spi_enableHardwareSS(volatile SPI_t* const spi);
void spi_enableSoftwareSS(volatile SPI_t* const spi);
void spi_enablePulseMode(volatile SPI_t* const spi);
void spi_disablePulseMode(volatile SPI_t* const spi);
void spi_assertSS(volatile SPI_t* const spi);
void spi_deassertSS(volatile SPI_t* const spi);
void spi_beginTransaction(volatile SPI_t* const spi);
void spi_endTransaction(volatile SPI_t* const spi);

int32_t spi_isMaster(volatile const SPI_t* const spi);
int32_t spi_isSlave(volatile const SPI_t* const spi);
int32_t spi_isConfigFixed(volatile const SPI_t* const spi);
uint32_t spi_getResetConfig(volatile const SPI_t* const spi);
uint32_t spi_getMode(volatile const SPI_t* const spi);
uint32_t spi_getClkDiv(volatile const SPI_t* const spi);
uint32_t spi_getActiveSlave(volatile const SPI_t* const spi);
int32_t spi_isSlaveEnabled(volatile const SPI_t* const spi);
int32_t spi_isSlaveDisabled(volatile const SPI_t* const spi);

// tx stat reg
int32_t spi_isTxReady(volatile const SPI_t* const spi);
uint32_t spi_getTxOverflowError(volatile const SPI_t* const spi);
int32_t spi_isTxWatermarkReached(volatile const SPI_t* const spi);
int32_t spi_isTxEmpty(volatile const SPI_t* const spi);
int32_t spi_isTxFull(volatile const SPI_t* const spi);
uint32_t spi_getTxWatermark(volatile const SPI_t* const spi);
uint32_t spi_getTxSize(volatile const SPI_t* const spi);

void spi_setTxEnable(volatile SPI_t* const spi);
void spi_clrTxEnable(volatile SPI_t* const spi); // data pushed into the tx fifo does not transmit automatically anymore
void spi_clrTxOverflowError(volatile SPI_t* const spi);
void spi_setTxWatermark(volatile SPI_t* const spi, uint8_t watermark);

// rx stat reg
uint32_t spi_getRxUnderflowError(volatile const SPI_t* const spi);
uint32_t spi_getRxOverflowError(volatile const SPI_t* const spi);
int32_t spi_isRxWatermarkReached(volatile const SPI_t* const spi);
int32_t spi_isRxEmpty(volatile const SPI_t* const spi);
int32_t spi_isRxFull(volatile const SPI_t* const spi);
uint32_t spi_getRxWatermark(volatile const SPI_t* const spi);
uint32_t spi_getRxSize(volatile const SPI_t* const spi);

void spi_setRxEnable(volatile SPI_t* const spi);
void spi_clrRxEnable(volatile SPI_t* const spi); // incoming data doesn't get pushed into the rx fifo anymore
void spi_clrRxUnderflowError(volatile SPI_t* const spi);
void spi_clrRxOverflowError(volatile SPI_t* const spi);
void spi_setRxWatermark(volatile SPI_t* const spi, uint8_t watermark);
void spi_clrRxFIFO(volatile SPI_t* const spi);

// write/read
/* if the data of one frame does not exceed the FIFO capacity, these functions ca be used standalone. After you have once
 * called spi_enableHardwareSS(), you can call for example spi_writeByte() three times in a row, in order to transfer a 24-bit
 * frame. The ss pin is managed automatically by hardware in this case, allowing the processor to continue without the need
 * of waiting for the transaction to be finished. But make sure to check if the transaction is finished by calling spi_isTxReady()
 * before you send the next frame! Otherwise the new data is appended to the previos frame. If spi_enablePulseMode() is called before
 * the transaction, the ss pin is deasserted after each byte transmitted.
 *
 * A more flexible way is to use spi_beginTransaction() before and spi_endTransaction() after each transaction. In this case
 * the ss pin is managed by software, allowing transactions of any length. All necessary flags such as as software ss enable and the
 * ss pin itself are managed by these functions. To prevent transaction conflicts, the spi_beginTransaction() function waits for previous
 * transactions to be finished before asserting the ss pin and the spi_endTransaction() function waits for the ongoing transaction to be
 * finished before deasserting the ss pin.
 *
 * In both cases the outputs have to be enabled! Call spi_enableOutputs() to be sure or set the oe parameter in the
 * spi_init() function. Outputs are disabled by default (after reset).
 */

void spi_writeByte(volatile SPI_t* const spi, uint8_t data);
uint8_t spi_readByte(volatile const SPI_t* const spi);
uint8_t spi_transferByte(volatile SPI_t* const spi, uint8_t data);

void spi_writeData(volatile SPI_t* const spi, const uint8_t* data, uint32_t size);
void spi_readData(volatile SPI_t* const spi, uint8_t* data, uint32_t size);

#endif

