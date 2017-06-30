#!/bin/bash

BINSIZE=1000
ITERATIONS=`tail -n 1 collision.*.log | awk '{print $1}' | sort -n | tail -n 1`

RESULTS=collisions
DIR=`readlink -fn $0`
BASEDIR=`dirname $DIR`

# Generate timestep column 
seq 0 $BINSIZE $ITERATIONS > $RESULTS

#temp file for paste results
PASTE_BUFFER=`mktemp`

# Collect collision data
for f in collision.*.log
do
	echo "Processing $f "
	awk -v binsize=${BINSIZE} -v iterations=${ITERATIONS} 'BEGIN{for(i=0;i*binsize<iterations;i++){collisions[i]=0}} {collisions[int($1 / binsize)]++}END{for (i in collisions) print i*binsize, collisions[i]}' ${f} | sort -n -k 1 | awk '{print $2}' |  paste ${RESULTS} - > ${PASTE_BUFFER}
	mv ${PASTE_BUFFER} ${RESULTS}
done

# Summarise collision data
awk -f ${BASEDIR}/moments-per-line.awk $RESULTS > ${RESULTS}.stats