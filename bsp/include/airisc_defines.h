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

#ifndef AIRISC_DEFINES_H_
#define AIRISC_DEFINES_H_

#include <stdint.h>

typedef struct
{
  uint32_t TIMEL;          // timer register LSB
  uint32_t TIMEH;          // timer register MSB
  uint32_t TIMECMPL;       // timer compare register LSB
  uint32_t TIMECMPH;       // timer compare register MSB
} TIMER_t __attribute__((aligned(4)));

typedef struct
{
  uint32_t DATA;           // data i/o
  uint32_t EN;             // output enable
} GPIO_t __attribute__((aligned(4)));

typedef struct
{
  uint32_t DATA;           // SPI tx/rx FIFO
  uint32_t CTRL;           // SPI control register
  uint32_t CTRL_SET;       // set specified bits in SPI control register
  uint32_t CTRL_CLR;       // clear specified bits in SPI control register
  uint32_t TX_STAT;        // tx status register
  uint32_t TX_STAT_SET;    // set specified bits in tx status register
  uint32_t TX_STAT_CLR;    // clear specified bits in tx status register
  uint32_t RX_STAT;        // tx status register
  uint32_t RX_STAT_SET;    // set specified bits in tx status register
  uint32_t RX_STAT_CLR;    // clear specified bits in tx status register
} SPI_t __attribute__((aligned(4)));

typedef struct
{
  uint32_t DATA;           // UART tx/rx FIFO stack
  uint32_t CTRL;           // UART control register
  uint32_t CTRL_SET;       // set specified bits in UART control register
  uint32_t CTRL_CLR;       // clear specified bits in UART control register
  uint32_t TX_STAT;        // tx status register
  uint32_t TX_STAT_SET;    // set specified bits in tx status register
  uint32_t TX_STAT_CLR;    // clear specified bits in tx status register
  uint32_t RX_STAT;        // tx status register
  uint32_t RX_STAT_SET;    // set specified bits in tx status register
  uint32_t RX_STAT_CLR;    // clear specified bits in tx status register
} UART_t __attribute__((aligned(4)));

typedef struct
{
  uint32_t CTRL;           // control and data register
} TRNG_t __attribute__((aligned(4)));


/**********************************************************************//**
 * Peripheral map (DEFAULT configuration, see src/airi5c_arch_options.vh)
 **************************************************************************/
#define timer0  (((volatile TIMER_t*) (0xC0000100)))
#define uart0   (((volatile UART_t*)  (0xC0000200)))
//#define uart1 (((volatile UART_t*)  (0xC0000300)))
#define spi0    (((volatile SPI_t*)   (0xC0000400)))
#define spi1    (((volatile SPI_t*)   (0xC0000500)))
#define gpio0   (((volatile GPIO_t*)  (0xC0000600)))
#define trng    (((volatile TRNG_t*)  (0xC0000800)))

#endif

