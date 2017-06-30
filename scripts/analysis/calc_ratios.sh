#!/bin/bash

FULLCOMMAND="$0 $@"
. ../lib/shflags

#define the flags
DEFINE_string 'iterations' '1000000' 'Number of iterations' 'i'

# Parse the flags
FLAGS "$@" || exit 1
eval set -- "${FLAGS_ARGV}"

let ITERATIONS=${FLAGS_iterations}-1000

foo=`mktemp`
for i in premium.*;
do
  echo $i > $foo;
  grep ^${ITERATIONS} $i/pucks-collected-ratio.0.stats | paste $foo - | sed -e 's/^premium\.//' >> ratios.0
done

rm $foo
