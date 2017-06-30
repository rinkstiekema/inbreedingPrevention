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

RESULTS=inseminations
DIR=`readlink -fn $0`
BASEDIR=`dirname $DIR`

# Generate timestep column
seq 0 $BINSIZE $ITERATIONS > $RESULTS

#temp file for paste results
EGG_BUFFER=`mktemp`
PASTE_BUFFER=`mktemp`

# Collect  data
for f in output*.bz2
do
	echo "Processing $f ..."
	bzcat $f | grep Iteration | awk '{print $2, $4}' | tr -d ';' | awk -v binsize=${BINSIZE} -v iterations=${ITERATIONS} 'BEGIN{for(i=0;i*binsize<iterations;i++){eggs[i]=0}} {eggs[int($1 / binsize)]++}END{for (i in eggs) print i*binsize, eggs[i]}' | sort -n -k 1 | awk '{print $2}' |  paste ${RESULTS} - > ${PASTE_BUFFER}
	mv ${PASTE_BUFFER} ${RESULTS}
done

awk -v skip=1 -v prepend=true -f moments-per-line.awk $RESULTS > ${RESULTS}.stats
