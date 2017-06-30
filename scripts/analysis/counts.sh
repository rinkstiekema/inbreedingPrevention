#!/bin/bash

FULLCOMMAND="$0 $@"
. ../lib/shflags

#define the flags
DEFINE_string 'iterations' '1000000' 'Number of iterations' 'i'

# Parse the flags
FLAGS "$@" || exit 1
eval set -- "${FLAGS_ARGV}"

BINSIZE=1000
ITERATIONS=${FLAGS_iterations}

RESULTS=pucks-collected
DIR=`readlink -fn $0`
BASEDIR=`dirname $DIR`

# Generate timestep column
seq 0 $BINSIZE $ITERATIONS > ${RESULTS}.0
seq 0 $BINSIZE $ITERATIONS > ${RESULTS}.1

#temp file for paste results
PASTE_BUFFER=`mktemp`
PUCK_BUFFER=`mktemp`

# Collect  data
for f in output.*.log.bz2
do
	echo "Processing $f ..."
	bzcat $f | awk '/PuckTaken/{print $2}' | tr -d '(' | tr -d ')' | awk -F';' -v binsize=${BINSIZE} -v iterations=${ITERATIONS} 'BEGIN{for (i=0; i<=(iterations/binsize); i++){pucks[i,0]=0;pucks[i,1]=0}}{pucks[int($1/binsize),$2]+=1}END{for (i=0; i<=(iterations/binsize); i++) { print  1000*i, pucks[i,0], pucks[i,1]}}' | sort -n -k 1 > ${PUCK_BUFFER}
	awk '{print $2}'  ${PUCK_BUFFER} | paste ${RESULTS}.0 - > ${PASTE_BUFFER}
	mv ${PASTE_BUFFER} ${RESULTS}.0
	awk '{print $3}'  ${PUCK_BUFFER} | paste ${RESULTS}.1 - > ${PASTE_BUFFER}
	mv ${PASTE_BUFFER} ${RESULTS}.1
done
