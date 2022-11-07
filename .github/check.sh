#!/usr/bin/env bash

set -e

cd $(dirname "$0")

TOP_DIR=${TOP_DIR:-..}

# create empty log file
touch sim_log
> sim_log

# run simulation script
sh "$TOP_DIR"/.ci/iverilog_sim.sh | tee -a sim_log

# check for success pattern
grep 'TB PASSED' sim_log
