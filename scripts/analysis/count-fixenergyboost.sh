#!/bin/bash

FULLCOMMAND="$0 $@"
. ${HOME}/lib/shflags

#define the flags
DEFINE_string 'iterations' '1000000' 'Number of iterations' 'i'

# Parse the flags
FLAGS "$@" || exit 1
eval set -- "${FLAGS_ARGV}"

BINSIZE=1000
ITERATIONS=${FLAGS_iterations}

RESULTS=count-fixenergyboost
DIR=`readlink -fn $0`
BASEDIR=`dirname $DIR`

# Generate timestep column 
seq 0 $BINSIZE $ITERATIONS > ${RESULTS}

#temp file for paste results
PASTE_BUFFER=`mktemp`
PUCK_BUFFER=`mktemp`

#PuckTaken: (1;0;226;514) == (iteration,colorid,x,y)

#EggHatched: (267; 199.091; 584.23); [[0, 0, 0.005, 135, 0.148372], [0, 0, 0.005, 141, 0.161274], [0, 0, 0.005, 130, 0.154823], [0, 0, 0.005, 151, 0.0709606], [0, 0, 0.005, 167, 0.0645097], [0, 0, 0.005, 194, 0.0580587]]; Winner: 194

# Collect  data
for f in output.*.log.bz2
do
	echo "Processing $f ..."
	
	#frank: evert parse code. moet in python om te werken! link iteration (1e tussen ronde haakjes) met fixenergyboost value (laatste in rechte haakjes)
	bzgrep EggHatched $f | tr -d '(' | awk -F';' '{print $4}' | awk -F] '{for (i=1;i<=NF;i++)print $i}' | awk -v iter=$iter '{print iter, $NF}' 
	
	bzgrep EggHatched $f | awk -F';' '{print $4}' | awk -F ']' | awk '{print $NF}'
	bzcat $f | awk -F';' '/EggHatched/{print $2}' | awk -F';' -v binsize=${BINSIZE} -v iterations=${ITERATIONS}	
	'BEGIN{for (i=0; i<=(iterations/binsize); i++)}
	{eggiteration=$1,xegg=$2,yegg=$3}
	END
	{for (i=0; i<=(iterations/binsize); i++) { print  1000*i, egghatch[i,eggiteration,xegg,yegg]}}
	' | sort -n -k 1 > ${PUCK_BUFFER}
	
	
	awk '{print $2}'  ${PUCK_BUFFER} | paste ${RESULTS} - > ${PASTE_BUFFER}
	mv ${PASTE_BUFFER} ${RESULTS}
done
