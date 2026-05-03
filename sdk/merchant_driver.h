// ═══════════════════════════════════════════════════════
//  MERCHANT CHIP — Hardware Driver
//  merchant_driver.h
//
//  The complete API for controlling the MERCHANT chip
//  Works in simulation on laptop AND on real hardware
//
//  USAGE EXAMPLE:
//
//  merchant_chip_t* chip = merchant_open();
//  merchant_load_weights(chip, weights, 256);
//  merchant_load_activations(chip, inputs, 16);
//  merchant_start_inference(chip);
//  merchant_wait_done(chip);
//  merchant_read_outputs(chip, outputs, 16);
//  merchant_close(chip);
// ═══════════════════════════════════════════════════════

#ifndef MERCHANT_DRIVER_H
#define MERCHANT_DRIVER_H

#include <stdint.h>
#include <stddef.h>
#include "merchant_registers.h"

// ── Error codes ───────────────────────────────────────
#define MERCHANT_OK             0
#define MERCHANT_ERR_NULL      -1   // null pointer passed
#define MERCHANT_ERR_TIMEOUT   -2   // chip did not respond
#define MERCHANT_ERR_RANGE     -3   // address out of range
#define MERCHANT_ERR_OPEN      -4   // could not open chip

// ── Chip handle ───────────────────────────────────────
// This struct represents one connected MERCHANT chip
// Always use merchant_open() to create it
// Always use merchant_close() when done
typedef struct {
    uint32_t* base;         // pointer to chip memory
    uint32_t  sim_regs[256]; // simulation register bank
    int       is_sim;       // 1 = simulation, 0 = real hardware
    int       is_open;      // 1 = connected, 0 = closed
} merchant_chip_t;

// ── Connection functions ──────────────────────────────

// Open connection to MERCHANT chip
// Returns pointer to chip handle on success
// Returns NULL on failure
// In simulation mode creates a virtual chip in memory
merchant_chip_t* merchant_open(void);

// Close connection and free all resources
// Always call this when you are done with the chip
void merchant_close(merchant_chip_t* chip);

// ── Weight loading ────────────────────────────────────

// Load all 256 weights into chip SRAM
// weights: array of 256 signed 8-bit values
// count:   must be 256
// Weight at position [R*16 + C] goes to row R, col C
// Returns MERCHANT_OK on success
int merchant_load_weights(merchant_chip_t* chip,
                          const int8_t* weights,
                          size_t count);

// Load a single weight value
// addr: 0-255 (row R col C = R*16 + C)
// value: signed 8-bit weight
int merchant_load_weight_single(merchant_chip_t* chip,
                                uint8_t addr,
                                int8_t value);

// ── Activation loading ────────────────────────────────

// Load all 16 activation inputs
// activations: array of 16 signed 8-bit values
// count: must be 16
int merchant_load_activations(merchant_chip_t* chip,
                              const int8_t* activations,
                              size_t count);

// Load a single activation value
// row: 0-15
// value: signed 8-bit activation
int merchant_load_activation_single(merchant_chip_t* chip,
                                    uint8_t row,
                                    int8_t value);

// ── Bias loading ──────────────────────────────────────

// Load all 16 bias values
// biases: array of 16 signed 32-bit values
int merchant_load_biases(merchant_chip_t* chip,
                         const int32_t* biases,
                         size_t count);

// ── Configuration ─────────────────────────────────────

// Enable or disable batch normalisation
// scale: 8-bit scale factor
// enable: 1 to enable, 0 to bypass
int merchant_set_batchnorm(merchant_chip_t* chip,
                           uint8_t scale,
                           int enable);

// Configure pooling
// enable: 1 to enable pooling
// mode: 0 = max pooling, 1 = average pooling
int merchant_set_pooling(merchant_chip_t* chip,
                         int enable,
                         int mode);

// Enable specific rows only
// row_mask: 16-bit mask, bit N = row N
// Use 0xFFFF to enable all rows
int merchant_set_row_enable(merchant_chip_t* chip,
                            uint16_t row_mask);

// ── Inference control ─────────────────────────────────

// Clear all accumulators to zero
// Call this before starting a new inference
int merchant_clear(merchant_chip_t* chip);

// Start inference — all 256 MACs begin computing
int merchant_start_inference(merchant_chip_t* chip);

// Stop inference
int merchant_stop_inference(merchant_chip_t* chip);

// Wait until inference is complete
// timeout_ms: how long to wait in milliseconds
// Returns MERCHANT_OK when done
// Returns MERCHANT_ERR_TIMEOUT if chip does not respond
int merchant_wait_done(merchant_chip_t* chip,
                       uint32_t timeout_ms);

// ── Output reading ────────────────────────────────────

// Read all 16 output values
// outputs: array to fill with 16 signed 8-bit results
int merchant_read_outputs(merchant_chip_t* chip,
                          int8_t* outputs,
                          size_t count);

// Read a single output value
// channel: 0-15
int8_t merchant_read_output_single(merchant_chip_t* chip,
                                   uint8_t channel);

// ── Status functions ──────────────────────────────────

// Returns 1 if inference is done, 0 if still running
int merchant_is_done(merchant_chip_t* chip);

// Returns number of zero-skipped MAC operations
// Higher number = more sparsity = more efficiency
uint16_t merchant_get_skip_count(merchant_chip_t* chip);

// ── UART functions ────────────────────────────────────

// Send one byte over UART
int merchant_uart_send(merchant_chip_t* chip,
                       uint8_t data);

// Send array of bytes over UART
int merchant_uart_send_bytes(merchant_chip_t* chip,
                             const uint8_t* data,
                             size_t len);

// Check if a byte has been received
// Returns 1 if data available, 0 if not
int merchant_uart_data_ready(merchant_chip_t* chip);

// Read received UART byte
uint8_t merchant_uart_read(merchant_chip_t* chip);

// ── Utility functions ─────────────────────────────────

// Print chip status to console — useful for debugging
void merchant_print_status(merchant_chip_t* chip);

// Print all 16 output values to console
void merchant_print_outputs(merchant_chip_t* chip);

// Low level register read — for advanced use
uint32_t merchant_reg_read(merchant_chip_t* chip,
                           uint32_t addr);

// Low level register write — for advanced use
void merchant_reg_write(merchant_chip_t* chip,
                        uint32_t addr,
                        uint32_t value);

#endif // MERCHANT_DRIVER_H
