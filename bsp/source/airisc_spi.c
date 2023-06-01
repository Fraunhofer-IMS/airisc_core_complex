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


#include "airisc_spi.h"

void spi_init(volatile SPI_t* const spi, uint8_t master, uint8_t mode, uint8_t clkDiv, uint8_t activeSlave, uint8_t oe)
{
    spi->CTRL =
        (oe & 0x01)          << 24 | // output enable
        (master & 0x01)      << 16 | // 1 master, 0 slave
        0                    << 13 | // software ss enable
        1                    << 12 | // software ss
        (activeSlave & 0x03) << 8  | // active ss
        (mode & 0x03)        << 4  | // clk_polarity, clk phase
        (clkDiv & 0x0F);             // clk divider = 2^(x+1)
}

void spi_enableOutputs(volatile SPI_t* const spi)
{
    spi->CTRL_SET = 0x10000000;
}

void spi_disableOutputs(volatile SPI_t* const spi)
{
    spi->CTRL_CLR = 0x10000000;
}

void spi_setMaster(volatile SPI_t* const spi)
{
    spi->CTRL_SET = 0x00010000;
}

void spi_setSlave(volatile SPI_t* const spi)
{
    spi->CTRL_CLR = 0x00010000;
}

void spi_setMode(volatile SPI_t* const spi, uint8_t mode)
{
    spi->CTRL_CLR = 0x00000030;
    spi->CTRL_SET = (mode & 0x03) << 4;
}

void spi_setClkDiv(volatile SPI_t* const spi, uint8_t clkDiv)
{
    spi->CTRL_CLR = 0x0000000F;
    spi->CTRL_SET = clkDiv & 0x0F;
}

void spi_setActiveSlave(volatile SPI_t* const spi, uint8_t slave)
{
    spi->CTRL_CLR = 0x00000300;
    spi->CTRL_SET = ((uint32_t)(slave & 0x3)) << 8;
}

void spi_enableHardwareSS(volatile SPI_t* const spi)
{
    spi->CTRL_CLR = 0x00002000;
}

void spi_enableSoftwareSS(volatile SPI_t* const spi)
{
    spi->CTRL_SET = 0x00002000;
}

void spi_enablePulseMode(volatile SPI_t* const spi)
{
    spi->CTRL_SET = 0x00004000;
}

void spi_disablePulseMode(volatile SPI_t* const spi)
{
    spi->CTRL_CLR = 0x00004000;
}

void spi_assertSS(volatile SPI_t* const spi)
{
    spi->CTRL_CLR = 0x00001000;     // software_ss = 0
}

void spi_deassertSS(volatile SPI_t* const spi)
{
    spi->CTRL_SET = 0x00001000;     // software_ss = 1
}

void spi_beginTransaction(volatile SPI_t* const spi)
{
    while (!spi_isTxReady(spi));    // wait until previous transaction is finished
    spi_clrRxFIFO(spi);             // clear legacy data in rx FIFO
    spi_setTxEnable(spi);           // automatically transmit data that is pushed into the tx fifo
    spi_enableSoftwareSS(spi);
    spi_assertSS(spi);
}

void spi_endTransaction(volatile SPI_t* const spi)
{
    while (!spi_isTxReady(spi));    // wait until current transaction is finished
    spi_deassertSS(spi);
    spi_enableHardwareSS(spi);      // disable the software ss mode and re-enable hardware ss mode
}

int32_t spi_isMaster(volatile const SPI_t* const spi)
{
    uint32_t ctrl = spi->CTRL;

    if (ctrl & 0x00200000)
    {
        if (ctrl & 0x00100000)
            return -1;
    }
    else
    {
        if (ctrl & 0x00010000)
            return -1;
    }

    return 0;
}

int32_t spi_isSlave(volatile const SPI_t* const spi)
{
    return !spi_isMaster(spi);
}

int32_t spi_isConfigFixed(volatile const SPI_t* const spi)
{
    if (spi->CTRL & 0x00200000)
        return -1;
    
    return 0;
}
uint32_t spi_getResetConfig(volatile const SPI_t* const spi)
{
    return (spi->CTRL & 0x00100000) >> 20;
}

uint32_t spi_getMode(volatile const SPI_t* const spi)
{
    return (spi->CTRL & 0x00000030) >> 4;
}

uint32_t spi_getClkDiv(volatile const SPI_t* const spi)
{
    return spi->CTRL & 0x0000000F;
}

uint32_t spi_getActiveSlave(volatile const SPI_t* const spi)
{
    return (spi->CTRL & 0x00000300) >> 8;
}

int32_t spi_isSlaveEnabled(volatile const SPI_t* const spi)
{
    if (spi->CTRL & 0x00001000)
        return 0;

    return -1;
}

int32_t spi_isSlaveDisabled(volatile const SPI_t* const spi)
{
    return !spi_isSlaveEnabled(spi);
}

int32_t spi_isTxReady(volatile const SPI_t* const spi)
{
    if (spi->TX_STAT & 0x00100000)
        return -1;

    return 0;
}

uint32_t spi_getTxOverflowError(volatile const SPI_t* const spi)
{
    return (spi->TX_STAT & 0x00080000) >> 19;
}

int32_t spi_isTxWatermarkReached(volatile const SPI_t* const spi)
{
    if (spi->TX_STAT & 0x00040000)
        return -1;

    return 0;
}

int32_t spi_isTxEmpty(volatile const SPI_t* const spi)
{
    if (spi->TX_STAT & 0x00020000)
        return -1;

    return 0;
}

int32_t spi_isTxFull(volatile const SPI_t* const spi)
{
    if (spi->TX_STAT & 0x00010000)
        return -1;

    return 0;
}

uint32_t spi_getTxWatermark(volatile const SPI_t* const spi)
{
    return (spi->TX_STAT & 0x0000FF00) >> 8;
}

uint32_t spi_getTxSize(volatile const SPI_t* const spi)
{
    return spi->TX_STAT & 0x000000FF;
}

void spi_setTxEnable(volatile SPI_t* const spi)
{
    spi->TX_STAT_SET = 0x80000000;
}

void spi_clrTxEnable(volatile SPI_t* const spi)
{
    spi->TX_STAT_CLR = 0x80000000;
}

void spi_clrTxOverflowError(volatile SPI_t* const spi)
{
    spi->TX_STAT_CLR = 0x00080000;
}

void spi_setTxWatermark(volatile SPI_t* const spi, uint8_t watermark)
{
    spi->TX_STAT_CLR = 0x0000FF00;
    spi->TX_STAT_SET = ((uint32_t)watermark) << 8;
}

uint32_t spi_getRxUnderflowError(volatile const SPI_t* const spi)
{
    return (spi->RX_STAT & 0x00100000) >> 20;
}

uint32_t spi_getRxOverflowError(volatile const SPI_t* const spi)
{
    return (spi->RX_STAT & 0x00080000) >> 19;
}

int32_t spi_isRxWatermarkReached(volatile const SPI_t* const spi)
{
    if (spi->TX_STAT & 0x00040000)
        return -1;

    return 0;
}

int32_t spi_isRxEmpty(volatile const SPI_t* const spi)
{
    if (spi->RX_STAT & 0x00020000)
        return -1;

    return 0;
}

int32_t spi_isRxFull(volatile const SPI_t* const spi)
{
    if (spi->RX_STAT & 0x00010000)
        return -1;

    return 0;
}

uint32_t spi_getRxWatermark(volatile const SPI_t* const spi)
{
    return (spi->RX_STAT & 0x0000FF00) >> 8;
}

uint32_t spi_getRxSize(volatile const SPI_t* const spi)
{
    return spi->RX_STAT & 0x000000FF;
}

void spi_setRxEnable(volatile SPI_t* const spi)
{
    spi->RX_STAT_SET = 0x80000000;
}

void spi_clrRxEnable(volatile SPI_t* const spi)
{
    spi->RX_STAT_CLR = 0x80000000;
}

void spi_clrRxUnderflowError(volatile SPI_t* const spi)
{
    spi->RX_STAT_CLR = 0x00100000;
}

void spi_clrRxOverflowError(volatile SPI_t* const spi)
{
    spi->RX_STAT_CLR = 0x00080000;
}

void spi_setRxWatermark(volatile SPI_t* const spi, uint8_t watermark)
{
    spi->RX_STAT_CLR = 0x0000FF00;
    spi->RX_STAT_SET = ((uint32_t)watermark) << 8;
}

void spi_clrRxFIFO(volatile SPI_t* const spi)
{
    while (!spi_isRxEmpty(spi))
        spi->DATA;
}

void spi_writeByte(volatile SPI_t* const spi, uint8_t data)
{
    while (spi_isTxFull(spi));
    spi->DATA = data;
}

uint8_t spi_readByte(volatile const SPI_t* const spi)
{
    while (spi_isRxEmpty(spi));
    return spi->DATA;
}

uint8_t spi_transferByte(volatile SPI_t* const spi, uint8_t data)
{
    spi_writeByte(spi, data);
    return spi_readByte(spi);
}

void spi_writeData(volatile SPI_t* const spi, const uint8_t* data, uint32_t size)
{
    uint32_t ctrlReg = spi->CTRL;

    if (spi_isMaster(spi))
    {
        spi_beginTransaction(spi);
        spi_clrRxEnable(spi);

        for (uint32_t i = 0; i < size; i++)
            spi_writeByte(spi, data[i]);

        spi_endTransaction(spi);
        spi_setRxEnable(spi);
    }
    else
    {
        // slave write not implemented yet!
    }

    spi->CTRL = ctrlReg;
}

void spi_readData(volatile SPI_t* const spi, uint8_t* data, uint32_t size)
{
    uint32_t ctrlReg = spi->CTRL;

    if (spi_isMaster(spi))
    {
        spi_beginTransaction(spi);
        spi_setRxEnable(spi);

        for (uint32_t i = 0; i < size; i++)
            data[i] = spi_transferByte(spi, 0x00);

        spi_endTransaction(spi);
    }
    else
    {
        // slave read not implemented yet!
    }

    spi->CTRL = ctrlReg;
}


