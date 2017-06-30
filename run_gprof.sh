#!/bin/bash
gprof ./roborobo | ~/gprof2dot.py | dot -Tpng -o output.png

