#!/bin/bash
valgrind --track-origins=yes  ./roborobo -l ./config/test.prop
#valgrind --tool=callgrind --dump-instr=yes --simulate-cache=yes --collect-jumps=yes ./roborobo -l ./config/SimpleShells.properties
