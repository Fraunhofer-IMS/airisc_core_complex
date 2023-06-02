#!/usr/bin/env bash

set -e

cd $(dirname "$0")

TOP_DIR=${TOP_DIR:-../.}

cd "$TOP_DIR"/tb

# remove VHDL includes (they are not relevant for
# this minimal iverilog simulation)
patch -b "$TOP_DIR"/src/modules/airi5c_trng/src/airi5c_trng.v "$TOP_DIR"/.ci/airi5c_trng.v.patch

iverilog -v \
  -DCONFIG_IDEAL_SRAM_1 \
  -DSIM \
  -I "$TOP_DIR"/tb \
  -I "$TOP_DIR"/tb/tests \
  -I "$TOP_DIR"/src \
  -I "$TOP_DIR"/src/modules/airi5c_uart/src \
  -I "$TOP_DIR"/src/modules/airi5c_fpu \
  -o "$TOP_DIR"/.ci/airi5c-sim \
  -c "$TOP_DIR"/.ci/sim_file_list.txt

vvp "$TOP_DIR"/.ci/airi5c-sim
