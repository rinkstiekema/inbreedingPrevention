#/bin/bash

FULLCOMMAND="$0 $@"
. ${HOME}/lib/shflags

#define the flags
DEFINE_string 'iterations' '1000000' 'Number of iterations' 'i'

# Parse the flags
FLAGS "$@" || exit 1
eval set -- "${FLAGS_ARGV}"

DIR=`readlink -fn $0`
BASEDIR=`dirname $DIR`

echo "  counts start"
bash ${BASEDIR}/counts.sh --iterations ${FLAGS_iterations}
echo "  pucks start"
bash ${BASEDIR}/pucks.sh
echo "  counts inseminations start"
bash ${BASEDIR}/count-inseminations.sh --iterations ${FLAGS_iterations}
echo "  calculate ratios start"
bash ${BASEDIR}/calc_ratios.sh --iterations ${FLAGS_iterations}
echo "  run count offspring"
bash ${BASEDIR}/count-offspring.sh
echo "  analyse pressure"
bash ${BASEDIR}/analyse-pressure.sh
echo "  ages stats"
bash ${BASEDIR}/ages.sh

echo "  plot pucks ratio start"
gnuplot ${BASEDIR}/plot-pucks-ratio
echo "  plot pucks counts start"
gnuplot ${BASEDIR}/plot-pucks-counts
#echo "  plot inseminations start"
#gnuplot ${BASEDIR}/plot-inseminations

for i in *png
do 
  DEST=`readlink -f $i | sed 's|'${BASEDIR}'/||' | sed -e 's/\//./g'`
  cp $i ${BASEDIR}/summary/${DEST}
done
