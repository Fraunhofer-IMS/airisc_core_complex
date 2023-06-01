//
// Copyright 2023 FRAUNHOFER INSTITUTE OF MICROELECTRONIC CIRCUITS AND SYSTEMS (IMS), DUISBURG, GERMANY.
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
//
// File          : main.c
// Author        : S. Nolting
// Last Modified : 11.04.2023
// Abstract      : Default AIRISC demo program.
//

#include <stdint.h>
#include <airisc.h>
#include <ee_printf.h> // use "embedded" ee_printf (much smaller!) instead of stdio's printf

#define CLOCK_HZ   (32000000) // processor clock frequency
#define UART0_BAUD (9600)     // default Baud rate
#define TICK_TIME  (CLOCK_HZ) // timer tick every 1s

volatile uint32_t uptime;
volatile char hello_string[] = {"Hello World!"};


/**********************************************************************//**
 * Main program. Standard arguments (argc, argv) are not used as they are
 * all-zero anyway (cleared by crt0 start-up code).
 **************************************************************************/
int main(void) {

  int i, j, cnt, wait;


  // configure all GPIO pins (1 = pin is output; 0 = pin is input)
  gpio0->EN   = -1; // all configured as outputs
  gpio0->DATA =  0; // all LEDs off (assuming high-active LEDs)


  // say hi!
  // setup UART0: ee_printf, STDOUT, STDERR and STDIN are mapped to UART0
  uart_init(uart0, UART_DATA_BITS_8, UART_PARITY_EVEN, UART_STOP_BITS_1, UART_FLOW_CTRL_NONE, (uint32_t)(CLOCK_HZ/UART0_BAUD));
  ee_printf("\r\n%s This is the Fraunhofer IMS AIRISC! :)\r\n", hello_string);
  ee_printf("Build: "__DATE__" "__TIME__"\r\n\r\n");


  // show RISC-V ISA configuration
  char misa[64];
  get_misa_string(&misa[0]);
  ee_printf("ISA:      %s\r\n", misa);


  // show core IDs
  ee_printf("VENDORID: 0x%08x\r\n", cpu_csr_read(CSR_MVENDORID)); // vendor ID
  ee_printf("ARCHID:   0x%0   8x\r\n", cpu_csr_read(CSR_MARCHID)); // architecture ID
  ee_printf("IMPID:    0x%08x\r\n", cpu_csr_read(CSR_MIMPID)); // implemantation ID
  ee_printf("HARTID:   0x%08x\r\n", cpu_csr_read(CSR_MHARTID)); // hart ID
  ee_printf("\r\n\r\n");


  // setup CPU counters
  ee_printf("Initializing CPU counters...\r\n");
  cpu_csr_write(CSR_MCOUNTINHIBIT, -1); // stop all counters
  cpu_csr_write(CSR_MCYCLE, 0);
  cpu_csr_write(CSR_MCYCLEH, 0);
  cpu_csr_write(CSR_MINSTRET, 0);
  cpu_csr_write(CSR_MINSTRETH, 0);
  cpu_csr_write(CSR_MCOUNTINHIBIT, 0); // enable all counters


  // start true random number generator and print some data
  ee_printf("Starting TRNG... ");
  trng_enable(trng);
  if (trng_is_enabled(trng)) { // check if TRNG is really enabled
    ee_printf("ok\r\n");
    if (trng_is_sim(trng)) { // check if TRNG is in simulation mode
      ee_printf("[WARNING] TRNG is in SIMULATION mode!\r\n");
    }

    ee_printf("TRNG data demo:\r\n");
    for (i=0; i<8; i++) {
      for (j=0; j<16; j++) {
        ee_printf("0x%02x ", trng_get(trng));
      }
      ee_printf("\r\n");
    }
    trng_disable(trng); // shutdown TRNG
  }
  else {
    ee_printf("FAILED\r\n");
  }


  // configure and enable MTIME timer interrupt
  ee_printf("Configuring system tick timer...\r\n");
  uptime = 0;
  timer_set_time(timer0, 0); // reset time counter
  timer_set_timecmp(timer0, (uint64_t)(TICK_TIME)); // set timeout for first tick


  // print number of implemented/available externl interrupt channels
  ee_printf("Checking available external interrupt lines... %u\r\n", get_num_xirq());


  // enable CPU interrupts
  ee_printf("Configuring interrupts...\r\n");
  uint32_t tmp = 0;
  tmp |= (1 << IRQ_MTI); // machine timer interrupt
  tmp |= (1 << IRQ_XIRQ0) | (1 << IRQ_XIRQ1); // AIRISC-specific external interrupt channel 0 and 1
  tmp |= (1 << IRQ_XIRQ2) | (1 << IRQ_XIRQ3); // AIRISC-specific external interrupt channel 2 and 3
  tmp |= (1 << IRQ_XIRQ4) | (1 << IRQ_XIRQ5); // AIRISC-specific external interrupt channel 4 and 5
  tmp |= (1 << IRQ_XIRQ6) | (1 << IRQ_XIRQ7); // AIRISC-specific external interrupt channel 6 and 7
  cpu_csr_write(CSR_MIE, tmp); // enable interrupt sources


  // endless counter loop using busy-wait
  ee_printf("Starting busy loop and enabling IRQs...\r\n\r\n");
  cpu_csr_set(CSR_MSTATUS, 1 << MSTATUS_MIE); // enable machine-mode interrupts

  cnt  = 0;
  wait = 0;
  while(1) {
    gpio0->DATA = (cnt++) & 0xff;
    for (wait=0; wait<(CLOCK_HZ/32); wait++) {
      asm volatile("nop");
    }
  }

  return 0;
}


/**********************************************************************//**
 * Custom interrupt handler (overriding the default DUMMY handler from "airisc.c").
 *
 * @note This is a "normal" function - so NO 'interrupt' attribute!
 *
 * @param[in] cause Exception identifier from mcause CSR.
 * @param[in] epc Exception program counter from mepc CSR.
 **************************************************************************/
void interrupt_handler(uint32_t cause, uint32_t epc) {

  switch(cause) {

    // -------------------------------------------------------
    // Machine timer interrupt (RISC-V-specific)
    // -------------------------------------------------------
    case MCAUSE_TIMER_INT_M:

      // adjust timer compare register for next interrupt
      // this also clears/acknowledges the current machine timer interrupt
      timer_set_timecmp(timer0, timer_get_time(timer0) + (uint64_t)TICK_TIME);

      ee_printf("Uptime: %is\r\n", ++uptime);

      break;

    // -------------------------------------------------------
    // External interrupt (AIRISC-specific)
    // -------------------------------------------------------
    case MCAUSE_XIRQ0_INT:
    case MCAUSE_XIRQ1_INT:
    case MCAUSE_XIRQ2_INT:
    case MCAUSE_XIRQ3_INT:
    case MCAUSE_XIRQ4_INT:
    case MCAUSE_XIRQ5_INT:
    case MCAUSE_XIRQ6_INT:
    case MCAUSE_XIRQ7_INT:
    case MCAUSE_XIRQ8_INT:
    case MCAUSE_XIRQ9_INT:
    case MCAUSE_XIRQ10_INT:
    case MCAUSE_XIRQ11_INT:
    case MCAUSE_XIRQ12_INT:
    case MCAUSE_XIRQ13_INT:
    case MCAUSE_XIRQ14_INT:
    case MCAUSE_XIRQ15_INT:

      // the lowest 4-bit of MCAUSE identify the actual XIRQ channel when MCAUSE == MCAUSE_XIRQ*_INT
      ee_printf("External interrupt from channel %u\r\n", (cause & 0xf));

      // clear/acknowledge the current interrupt by clearing the according MIP bit
      cpu_csr_write(CSR_MIP, cpu_csr_read(CSR_MIP) & (~(1 << ((cause & 0xf) + IRQ_XIRQ0))));

      break;

    // -------------------------------------------------------
    // Invalid (not implemented) interrupt source
    // -------------------------------------------------------
    default:

      // invalid/unhandled interrupt - give debug information and halt
      ee_printf("Unknown interrupt source! mcause=0x%08x epc=0x%08x\r\n", cause, epc);

      cpu_csr_write(CSR_MIE, 0); // disable all interrupt sources
      while(1); // halt and catch fire
  }

}


/**********************************************************************//**
 * Custom exception handler (overriding the default DUMMY handler from "airisc.c").
 *
 * @note This is a "normal" function - so NO 'interrupt' attribute!
 *
 * @param[in] cause Exception identifier from mcause CSR.
 * @param[in] epc Exception program counter from mepc CSR.
 * @param[in] tval Trap value from mtval CSR.
 **************************************************************************/
void exception_handler(uint32_t cause, uint32_t epc, uint32_t tval) {

  ee_printf("\r\n!! UNHANDLED EXCEPTION cause=0x%08x, epc=0x%08x, tval=0x%08x !!%x\r\n", cause, epc, tval);

  cpu_csr_write(CSR_MIE, 0); // disable all interrupt sources
  while(1); // halt and catch fire!

}

