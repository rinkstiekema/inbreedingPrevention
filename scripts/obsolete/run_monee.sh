#!/bin/bash

# run_dynamic.sh
# roborobo
#
# Created by B.P.M. Weel on 3/20/12.
# Copyright 2012 VU. All rights reserved.

### Set the simulation-specific parameters
SCRIPTDIR=$(cd "$(dirname "$0")"; pwd -P)
BASEDIR="$(dirname ${SCRIPTDIR})/"
TEMPLATEDIR=${BASEDIR}template/

FULLCOMMAND="$0 $@"
. ${HOME}/lib/shflags

#define the flags
DEFINE_integer 'repeats' '16' 'The number of times the simulation should be run'
DEFINE_string 'iterations' '10000' 'Number of iterations' 
DEFINE_boolean 'noMarket' false 'Disable currency exchange mechanism'
DEFINE_float 'task1premium' 1.0 'premium for task 1'

# Parse the flags
FLAGS "$@" || exit 1
eval set -- "${FlAGS_ARGV}"

### Run the simulation
COUNTER=${FLAGS_repeats}

echo "*********************** starting simulations, repeating $COUNTER times"

if [ ${FLAGS_noMarket} -eq ${FLAGS_FALSE} ]; then
  template=TwoColours
else
  template=TwoColours-NoMarket
fi

cd $BASEDIR

MIN=1
cpu=16
until [ "$COUNTER" -lt "$MIN" ];  do
    count=$(jobs | wc -l)
    if [ $(($count-$cpu)) -lt 0 ]; then
        SEED=$RANDOM
        let COUNTER-=1
        let EXPERIMENT=${FLAGS_repeats}-$COUNTER
        echo "Running experiment #${EXPERIMENT} with parameters: --seed ${SEED} --basedir ${BASEDIR} --templatedir ${TEMPLATEDIR} --iterations ${FLAGS_iterations} --confname ${template} --task1premium ${FLAGS_task1premium}"
        bash ${BASEDIR}scripts/monee.sh --seed ${SEED} --basedir ${BASEDIR} --templatedir ${TEMPLATEDIR} --iterations ${FLAGS_iterations} --confname ${template}  --task1premium ${FLAGS_task1premium} &
    fi
    sleep 2s
done

wait
