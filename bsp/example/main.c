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

// <<< Simple example program >>>
// Show an incrementing counter on the lowest 4 bits of the processor's GPIO output port.
// Also prints the runtime in seconds via UART0 every 1s using the MTIME timer interrupt (airisc.c).

#include <stdint.h>
#include <airisc.h>
#include <ee_printf.h> // use "embedded" ee_printf (much smaller) instead of stdio's printf

#define CLOCK_HZ   (32000000)
#define UART0_BAUD (9600)


/**********************************************************************//**
 * Main program. Arguments (argc, argv) are not used at all as they are
 * all-zero anyway.
 **************************************************************************/
int main(void) {

    // configure all GPIO pins
    // 1: pin is output
    // 0: pin is input
    gpio0->EN   = -1; // all configured as outputs
    gpio0->DATA =  0; // all LEDs off

    // setup UART0
    uart_init(uart0, UART_DATA_BITS_8, UART_PARITY_EVEN, UART_STOP_BITS_1, UART_FLOW_CTRL_NONE, (uint32_t)(CLOCK_HZ/UART0_BAUD));

    // say hi!
    // stdout (ee_printf), stderr and stdin are mapped to uart0
    ee_printf("Hello world! This is AIRISC!!! :)\n\n");

    // endless counter loop using busy-wait
    uint32_t cnt = 0;
    uint32_t wait = 0;
    while(1) {
        uart_writeByte(uart0, '.');
        cnt = (cnt + 1) & 0xf;
        gpio0->DATA = cnt;
        for (wait=0; wait<(CLOCK_HZ/32); wait++) {
            asm volatile("nop");
        }
    }

    return 0;
}
