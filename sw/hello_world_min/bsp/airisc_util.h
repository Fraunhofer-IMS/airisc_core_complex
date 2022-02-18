/*
 * airi5c_util.h
 *
 *  Created on: 07.12.2021
 *      Author: alex
 */

#ifndef AIRI5C_UTIL_H_
#define AIRI5C_UTIL_H_

#include <stdint.h>

/** @brief Read a CSR register
 *
 * @details Read a register from the CSR file
 * 			Causes an exception if the privilege level is insufficient.
 *
 * @param csr_num CSR register number/address
 * @return CSR register content
 */
int read_csr(int csr_num);

/** @brief Write a CSR register
 *
 * @details Write a value into a register of the CSR file.
 * 			Causes an exception if the privilege level is insufficient.
 * 			Doesn't check if the value is legal.
 *
 * @param csr_num CSR register number/address
 * @param val 32-Bit value to write
 */
void write_csr(int csr_num, int val);

/** @brief Set UART configuration
 *
 * @details Write the UART configuration register
 * 			with values for a specific baudrate,
 * 			parity and stop-bit configuration.
 *
 * @param baudrate baudrate in baud per second
 * @param parity parity, 0 - none, 1 - odd, 2 - even
 * @param stopbits number of stopbits. Default: 1
 */
void uart_config(int baudrate, int parity, int stopbits);

/** @brief Get uptime in milliseconds
 *
 * @details Reads the timer to determine the
 * 			time since last reset
 *
 * @return time since last reset in milliseconds.
 */
uint32_t get_time_ms(void);

/** @brief Boot FPGA from QSPI flash
 *
 * @details Send IPROG command to ICAP.
 * 			The FPGA will reboot, loading
 * 			its configuration from the configured
 *          default source.
 *
 */
void icap_iprog();

#endif /* AIRI5C_UTIL_H_ */
