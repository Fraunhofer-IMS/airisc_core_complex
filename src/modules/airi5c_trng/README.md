# AIRISC True-Random Numbder Generator (TRNG)

The AIRISC TRNG is based on https://github.com/stnolting/neoTRNG, which uses
a technology-agnostic ring-oscillator architecture for generic entropy. The TRNG
also provides a simple post-processing logic to improve whitening. The hardware
sources are included as _git submodule_ in `external/neoTRNG`. For HAL / driver
files see `bsp/example/include/airisc_trng.h`.

The TRNG features an internal data buffer (FIFO, 64 entries by default) to provide
a certain _random data pool_ (i.e. the application can fetch several random bytes at once
without waiting for the entropy cell to generate new ones).

The hardware module provides a single interface register that is used for
configuration and data access:

| Bit(s) | r/w | Description |
|:-------|:---:|:------------|
| 7:0    | r/- | Random data byte; only valid if bit 31 is set - otherwise the data byte is forced to all-zero so the same random byte cannot be read twice |
| 28:8   | r/- | Reserved, read as zero |
| 29     | r/- | Simulation notifier: if this bit is set the AIRISC is being simulated (see note below) |
| 30     | r/w | TRNG enable; clearing this bit will reset the entropy source and will also clear the random pool (FIFO) |
| 31     | r/- | Valid bit, set when random data byte is valid, auto-clears when reading |

:warning: The ARISC TRNG provides a "simulation mode" that is automatically used when the
processor is being simulated. In this case the **true**-random number generator is replaced
by a simple **pseudo**-random number generator (LFSR).
