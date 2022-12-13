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

#ifndef AIRISC_SPI_H_
#define AIRISC_SPI_H_

#include "airisc_defines.h"

// control reg
void spi_init(volatile SPI_t* const spi, uint8_t master, uint8_t mode, uint8_t clkDiv, uint8_t activeSlave, uint8_t autoSS);
void spi_setMaster(volatile SPI_t* const spi);
void spi_setSlave(volatile SPI_t* const spi);
void spi_setMode(volatile SPI_t* const spi, uint8_t mode);
void spi_setClkDiv(volatile SPI_t* const spi, uint8_t clkDiv);
void spi_setActiveSlave(volatile SPI_t* const spi, uint8_t slave);
void spi_enableAutoSS(volatile SPI_t* const spi);
void spi_disableAutoSS(volatile SPI_t* const spi);
void spi_beginTransaction(volatile SPI_t* const spi);
void spi_endTransaction(volatile SPI_t* const spi);

int32_t spi_isMaster(volatile const SPI_t* const spi);
int32_t spi_isSlave(volatile const SPI_t* const spi);
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

void spi_setRxIgnore(volatile SPI_t* const spi);
void spi_clrRxIgnore(volatile SPI_t* const spi);
void spi_clrRxUnderflowError(volatile SPI_t* const spi);
void spi_clrRxOverflowError(volatile SPI_t* const spi);
void spi_setRxWatermark(volatile SPI_t* const spi, uint8_t watermark);

// write/read
void spi_writeByte(volatile SPI_t* const spi, uint8_t data);
uint8_t spi_readByte(volatile const SPI_t* const spi);
uint8_t spi_transferByte(volatile SPI_t* const spi, uint8_t data);

void spi_writeData(volatile SPI_t* const spi, const uint8_t* data, uint32_t size);
void spi_readData(volatile SPI_t* const spi, uint8_t* data, uint32_t size);

#endif

