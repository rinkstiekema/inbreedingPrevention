#!/bin/bash

RESULTS=pucks-collected
DIR=`readlink -fn $0`
BASEDIR=`dirname $DIR`

echo "Summarising..."

# Summarise puck counts
awk -v skip=1 -v prepend=true -f moments-per-line.awk $RESULTS.0 > ${RESULTS}.0.stats
awk -v skip=1 -v prepend=true -f moments-per-line.awk $RESULTS.1 > ${RESULTS}.1.stats

paste ${RESULTS}.0 ${RESULTS}.1 > ${RESULTS}

# Calculate and summarise puck ratios
NR_RUNS=`head -n 1 $RESULTS | wc -w`
let NR_RUNS=$NR_RUNS/2
let NR_RUNS=$NR_RUNS-1

awk -v nrRuns=${NR_RUNS} '{printf("%d ", $1); for (i=2; i <= (nrRuns+1); i++){ tot = $i + $(i+(nrRuns+1)); printf("%f ",  tot==0?0:$i/tot)} print ""}' ${RESULTS} > ${RESULTS}-ratio.0
awk -v nrRuns=${NR_RUNS} '{printf("%d ", $1); for (i=2; i <= (nrRuns+1); i++){ tot = $i + $(i+(nrRuns+1)); printf("%f ",  tot==0?0:$(i+(nrRuns+1))/tot)} print ""}' ${RESULTS} > ${RESULTS}-ratio.1
awk -v skip=1 -v prepend=true -f moments-per-line.awk $RESULTS-ratio.0 > ${RESULTS}-ratio.0.stats
awk -v skip=1 -v prepend=true -f moments-per-line.awk $RESULTS-ratio.1 > ${RESULTS}-ratio.1.stats

awk -v nrRuns=${NR_RUNS} '{printf("%d ", $1); for (i=2; i <= (nrRuns+1); i++){ tot = $i + $(i+(nrRuns+1)); printf("%f ",  tot)} print ""}' ${RESULTS} > ${RESULTS}.counts
awk -v skip=1 -v prepend=true -f moments-per-line.awk ${RESULTS}.counts > ${RESULTS}.counts.stats

echo Done.
