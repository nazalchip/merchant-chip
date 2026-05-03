// ═══════════════════════════════════════════════════════
//  MERCHANT CHIP — Hardware Driver Implementation
//  merchant_driver.c
//
//  Complete implementation of the MERCHANT chip driver
//  Runs in simulation mode on any laptop
//  Same code runs on real hardware unchanged
// ═══════════════════════════════════════════════════════

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include "merchant_driver.h"
#include "merchant_registers.h"

// ── Internal helper — write to register ──────────────
void merchant_reg_write(merchant_chip_t* chip,
                        uint32_t addr,
                        uint32_t value) {
    if (!chip || !chip->is_open) return;

    if (chip->is_sim) {
        // simulation — write to virtual register bank
        if (addr < 256) {
            chip->sim_regs[addr] = value;
        }
    } else {
        // real hardware — write to physical memory address
        volatile uint32_t* reg = (volatile uint32_t*)
                                  (chip->base + addr);
        *reg = value;
    }
}

// ── Internal helper — read from register ─────────────
uint32_t merchant_reg_read(merchant_chip_t* chip,
                           uint32_t addr) {
    if (!chip || !chip->is_open) return 0;

    if (chip->is_sim) {
        // simulation — read from virtual register bank
        if (addr < 256) {
            return chip->sim_regs[addr];
        }
        return 0;
    } else {
        // real hardware — read from physical memory address
        volatile uint32_t* reg = (volatile uint32_t*)
                                  (chip->base + addr);
        return *reg;
    }
}

// ── Open connection ───────────────────────────────────
merchant_chip_t* merchant_open(void) {
    // allocate chip handle
    merchant_chip_t* chip = (merchant_chip_t*)
                             malloc(sizeof(merchant_chip_t));
    if (!chip) {
        fprintf(stderr, "[MERCHANT] ERROR: out of memory\n");
        return NULL;
    }

    // clear everything
    memset(chip, 0, sizeof(merchant_chip_t));

    // detect if real hardware is available
    // for now always use simulation
    // when real chip arrives change is_sim to 0
    chip->is_sim  = 1;
    chip->is_open = 1;
    chip->base    = NULL;

    if (chip->is_sim) {
        printf("[MERCHANT] Opened in simulation mode\n");
        printf("[MERCHANT] 256 MACs | 16x16 systolic array\n");
        printf("[MERCHANT] MERCHANT chip v5 — TITAN architecture\n");
    } else {
        printf("[MERCHANT] Opened on real hardware\n");
    }

    return chip;
}

// ── Close connection ──────────────────────────────────
void merchant_close(merchant_chip_t* chip) {
    if (!chip) return;
    chip->is_open = 0;
    free(chip);
    printf("[MERCHANT] Chip connection closed\n");
}

// ── Load all weights ──────────────────────────────────
int merchant_load_weights(merchant_chip_t* chip,
                          const int8_t* weights,
                          size_t count) {
    if (!chip || !weights) return MERCHANT_ERR_NULL;
    if (count != MERCHANT_NUM_WEIGHTS) return MERCHANT_ERR_RANGE;

    printf("[MERCHANT] Loading %zu weights...\n", count);

    for (size_t i = 0; i < count; i++) {
        // write weight address
        merchant_reg_write(chip, REG_W_ADDR, (uint32_t)i);
        // write weight value
        merchant_reg_write(chip, REG_W_DATA_IN,
                           (uint32_t)(uint8_t)weights[i]);
        // pulse write enable
        merchant_reg_write(chip, REG_W_WE, 1);
        merchant_reg_write(chip, REG_W_WE, 0);
    }

    printf("[MERCHANT] Weights loaded successfully\n");
    return MERCHANT_OK;
}

// ── Load single weight ────────────────────────────────
int merchant_load_weight_single(merchant_chip_t* chip,
                                uint8_t addr,
                                int8_t value) {
    if (!chip) return MERCHANT_ERR_NULL;

    merchant_reg_write(chip, REG_W_ADDR, addr);
    merchant_reg_write(chip, REG_W_DATA_IN, (uint8_t)value);
    merchant_reg_write(chip, REG_W_WE, 1);
    merchant_reg_write(chip, REG_W_WE, 0);
    return MERCHANT_OK;
}

// ── Load all activations ──────────────────────────────
int merchant_load_activations(merchant_chip_t* chip,
                              const int8_t* activations,
                              size_t count) {
    if (!chip || !activations) return MERCHANT_ERR_NULL;
    if (count != MERCHANT_NUM_ROWS) return MERCHANT_ERR_RANGE;

    printf("[MERCHANT] Loading %zu activations...\n", count);

    for (size_t i = 0; i < count; i++) {
        merchant_reg_write(chip, REG_ACT_ADDR, (uint32_t)i);
        merchant_reg_write(chip, REG_ACT_IN,
                           (uint32_t)(uint8_t)activations[i]);
        merchant_reg_write(chip, REG_ACT_WE, 1);
        merchant_reg_write(chip, REG_ACT_WE, 0);
    }

    printf("[MERCHANT] Activations loaded successfully\n");
    return MERCHANT_OK;
}

// ── Load single activation ────────────────────────────
int merchant_load_activation_single(merchant_chip_t* chip,
                                    uint8_t row,
                                    int8_t value) {
    if (!chip) return MERCHANT_ERR_NULL;
    if (row >= MERCHANT_NUM_ROWS) return MERCHANT_ERR_RANGE;

    merchant_reg_write(chip, REG_ACT_ADDR, row);
    merchant_reg_write(chip, REG_ACT_IN, (uint8_t)value);
    merchant_reg_write(chip, REG_ACT_WE, 1);
    merchant_reg_write(chip, REG_ACT_WE, 0);
    return MERCHANT_OK;
}

// ── Load biases ───────────────────────────────────────
int merchant_load_biases(merchant_chip_t* chip,
                         const int32_t* biases,
                         size_t count) {
    if (!chip || !biases) return MERCHANT_ERR_NULL;
    if (count != MERCHANT_NUM_OUTPUTS) return MERCHANT_ERR_RANGE;

    for (size_t i = 0; i < count; i++) {
        merchant_reg_write(chip, REG_BIAS_ADDR, (uint32_t)i);
        merchant_reg_write(chip, REG_BIAS_IN,
                           (uint32_t)biases[i]);
        merchant_reg_write(chip, REG_BIAS_WE, 1);
        merchant_reg_write(chip, REG_BIAS_WE, 0);
    }
    return MERCHANT_OK;
}

// ── Set batch normalisation ───────────────────────────
int merchant_set_batchnorm(merchant_chip_t* chip,
                           uint8_t scale,
                           int enable) {
    if (!chip) return MERCHANT_ERR_NULL;
    merchant_reg_write(chip, REG_BN_SCALE, scale);
    merchant_reg_write(chip, REG_BN_EN, enable ? 1 : 0);
    return MERCHANT_OK;
}

// ── Set pooling ───────────────────────────────────────
int merchant_set_pooling(merchant_chip_t* chip,
                         int enable,
                         int mode) {
    if (!chip) return MERCHANT_ERR_NULL;
    merchant_reg_write(chip, REG_POOL_EN,   enable ? 1 : 0);
    merchant_reg_write(chip, REG_POOL_MODE, mode   ? 1 : 0);
    return MERCHANT_OK;
}

// ── Set row enable mask ───────────────────────────────
int merchant_set_row_enable(merchant_chip_t* chip,
                            uint16_t row_mask) {
    if (!chip) return MERCHANT_ERR_NULL;
    merchant_reg_write(chip, REG_ROW_EN, row_mask);
    return MERCHANT_OK;
}

// ── Clear accumulators ────────────────────────────────
int merchant_clear(merchant_chip_t* chip) {
    if (!chip) return MERCHANT_ERR_NULL;
    merchant_reg_write(chip, REG_ACC_CLEAR, 1);
    merchant_reg_write(chip, REG_ACC_CLEAR, 0);
    merchant_reg_write(chip, REG_POOL_CLEAR, 1);
    merchant_reg_write(chip, REG_POOL_CLEAR, 0);
    return MERCHANT_OK;
}

// ── Start inference ───────────────────────────────────
int merchant_start_inference(merchant_chip_t* chip) {
    if (!chip) return MERCHANT_ERR_NULL;

    // enable all rows
    merchant_reg_write(chip, REG_ROW_EN, 0xFFFF);
    // start accumulation
    merchant_reg_write(chip, REG_ACC_EN, 1);

    if (chip->is_sim) {
        // in simulation mark as done immediately
        // real hardware sets REG_DONE when complete
        chip->sim_regs[REG_DONE] = 1;
        printf("[MERCHANT] Inference started (simulation)\n");
    }

    return MERCHANT_OK;
}

// ── Stop inference ────────────────────────────────────
int merchant_stop_inference(merchant_chip_t* chip) {
    if (!chip) return MERCHANT_ERR_NULL;
    merchant_reg_write(chip, REG_ACC_EN, 0);
    return MERCHANT_OK;
}

// ── Wait for done ─────────────────────────────────────
int merchant_wait_done(merchant_chip_t* chip,
                       uint32_t timeout_ms) {
    if (!chip) return MERCHANT_ERR_NULL;

    uint32_t waited = 0;
    while (!merchant_is_done(chip)) {
        // in real code add a small sleep here
        waited++;
        if (waited > timeout_ms * 1000) {
            fprintf(stderr,
                    "[MERCHANT] ERROR: timeout waiting for done\n");
            return MERCHANT_ERR_TIMEOUT;
        }
    }

    printf("[MERCHANT] Inference complete\n");
    return MERCHANT_OK;
}

// ── Check if done ─────────────────────────────────────
int merchant_is_done(merchant_chip_t* chip) {
    if (!chip) return 0;
    return (merchant_reg_read(chip, REG_DONE) == 1) ? 1 : 0;
}

// ── Read all outputs ──────────────────────────────────
int merchant_read_outputs(merchant_chip_t* chip,
                          int8_t* outputs,
                          size_t count) {
    if (!chip || !outputs) return MERCHANT_ERR_NULL;
    if (count != MERCHANT_NUM_OUTPUTS) return MERCHANT_ERR_RANGE;

    for (size_t i = 0; i < count; i++) {
        merchant_reg_write(chip, REG_OUT_ADDR, (uint32_t)i);
        outputs[i] = (int8_t)merchant_reg_read(chip, REG_ACT_OUT);
    }

    return MERCHANT_OK;
}

// ── Read single output ────────────────────────────────
int8_t merchant_read_output_single(merchant_chip_t* chip,
                                   uint8_t channel) {
    if (!chip || channel >= MERCHANT_NUM_OUTPUTS) return 0;
    merchant_reg_write(chip, REG_OUT_ADDR, channel);
    return (int8_t)merchant_reg_read(chip, REG_ACT_OUT);
}

// ── Get skip count ────────────────────────────────────
uint16_t merchant_get_skip_count(merchant_chip_t* chip) {
    if (!chip) return 0;
    return (uint16_t)merchant_reg_read(chip, REG_SKIP_COUNT);
}

// ── UART send byte ────────────────────────────────────
int merchant_uart_send(merchant_chip_t* chip, uint8_t data) {
    if (!chip) return MERCHANT_ERR_NULL;

    // wait until not busy
    uint32_t timeout = 100000;
    while (merchant_reg_read(chip, REG_UART_TX_BUSY) && timeout--)
        ;

    merchant_reg_write(chip, REG_UART_TX_DATA, data);
    merchant_reg_write(chip, REG_UART_TX_START, 1);
    merchant_reg_write(chip, REG_UART_TX_START, 0);
    return MERCHANT_OK;
}

// ── UART send multiple bytes ──────────────────────────
int merchant_uart_send_bytes(merchant_chip_t* chip,
                             const uint8_t* data,
                             size_t len) {
    if (!chip || !data) return MERCHANT_ERR_NULL;
    for (size_t i = 0; i < len; i++) {
        int ret = merchant_uart_send(chip, data[i]);
        if (ret != MERCHANT_OK) return ret;
    }
    return MERCHANT_OK;
}

// ── UART check data ready ─────────────────────────────
int merchant_uart_data_ready(merchant_chip_t* chip) {
    if (!chip) return 0;
    return merchant_reg_read(chip, REG_UART_RX_READY) ? 1 : 0;
}

// ── UART read byte ────────────────────────────────────
uint8_t merchant_uart_read(merchant_chip_t* chip) {
    if (!chip) return 0;
    return (uint8_t)merchant_reg_read(chip, REG_UART_RX_DATA);
}

// ── Print status ──────────────────────────────────────
void merchant_print_status(merchant_chip_t* chip) {
    if (!chip) return;
    printf("\n══════════════════════════════\n");
    printf("  MERCHANT CHIP STATUS\n");
    printf("══════════════════════════════\n");
    printf("  Mode:       %s\n",
           chip->is_sim ? "simulation" : "real hardware");
    printf("  Connected:  %s\n",
           chip->is_open ? "yes" : "no");
    printf("  Done:       %s\n",
           merchant_is_done(chip) ? "yes" : "no");
    printf("  Skip count: %u\n",
           merchant_get_skip_count(chip));
    printf("══════════════════════════════\n\n");
}

// ── Print all outputs ─────────────────────────────────
void merchant_print_outputs(merchant_chip_t* chip) {
    if (!chip) return;
    printf("\n  MERCHANT outputs:\n");
    for (int i = 0; i < MERCHANT_NUM_OUTPUTS; i++) {
        printf("  channel[%2d] = %4d\n",
               i, merchant_read_output_single(chip, i));
    }
    printf("\n");
}
