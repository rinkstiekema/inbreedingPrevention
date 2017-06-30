#!/bin/bash

# Generate png plots for monee runs analysis

# frank: dir changed!
#SCRIPT_DIR=$HOME/monee/results/analyse
SCRIPT_DIR=$DIR


for i in $@
do
  (
	pushd $i
	# puck counts & ratio
	gnuplot ${SCRIPT_DIR}/plot-pucks-counts
	gnuplot ${SCRIPT_DIR}/plot-pucks-ratio

	#specialisation plots
  	gnuplot  -e "set terminal pngcairo enhanced font 'Helvetica,11' size 1024, 1024;set output 'greenratio-histogram.png'" $SCRIPT_DIR/plot-histograms.gpl

	awk '999000 < $1 {print $3,$4}' *.collected | gnuplot -e "set output 'hexbin-puckcounts.png'" ${SCRIPT_DIR}/plot-hexbin-puckcounts.gnuplot  -


  	popd
  )&
done

# selection pressure
# bash ${SCRIPT_DIR}/selective_pressure_fisher_log-Energy.sh $@
