#!/bin/bash

RESULTS=pucks-collected
DIR=`readlink -fn $0`
BASEDIR=`dirname $DIR`

echo "Totalling..."

rm -f ${RESULTS}-total

for premium in premium.*
do

  # Calculate and summarise puck ratios
  NR_RUNS=`head -n 1 ${premium}/${RESULTS} | wc -w`
  let NR_RUNS=$NR_RUNS/2
  let NR_RUNS=$NR_RUNS-1

  (
  echo -n $premium  ' '  | sed -e 's/premium\.//'
  head -n 1000 ${premium}/${RESULTS} | awk -v nrRuns=${NR_RUNS} '{for (i=2; i <= (nrRuns+1); i++){totals[i]+=$i+$i+nrRuns}}END{for (i in totals) printf("%d ", totals[i]); printf("\n")}'
  )  >> ${RESULTS}-total
done

sort -n $RESULTS-total | awk  -v skip=1 -v prepend=true -f moments-per-line.awk > ${RESULTS}-total.stats

#echo Done.
