#!/bin/sh
#
# Compile and run

iverilog -o cpu_tb -c program_file.txt
./cpu_tb
