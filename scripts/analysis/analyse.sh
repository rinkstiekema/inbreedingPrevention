#/bin/bash

# remove ppn, less than 5 min time: test node
# Settings of PBS (do NOT uncomment these lines)
#--------------------------------------------------------------------------------------------------#
#PBS -lnodes=1
#PBS -lwalltime=00:04:59
#--------------------------------------------------------------------------------------------------#

FULLCOMMAND="$0 $@"
. ../lib/shflags

#define the flags
DEFINE_string 'iterations' '1000000' 'Number of iterations' 'i'

# Parse the flags
FLAGS "$@" || exit 1
eval set -- "${FLAGS_ARGV}"

DIR=`readlink -fn $0`
BASEDIR=`dirname $DIR`
#BASEDIR=$HOME/monee/results

for i in $@
do
  pushd $i
  (
   bash ${BASEDIR}/counts.sh --iterations ${FLAGS_iterations}
   bash ${BASEDIR}/pucks.sh
   bash ${BASEDIR}/count-inseminations.sh --iterations ${FLAGS_iterations}
   bash ${BASEDIR}/count-offspring.sh
   bash ${BASEDIR}/analyse-pressure.sh
   bash ${BASEDIR}/ages.sh
  )&
  popd
done

wait

bash ${BASEDIR}/make-plots.sh $@

# lines below specific to runs w. multiple premium settings
# bash ${BASEDIR}/calc_ratios.sh --iterations ${FLAGS_iterations}
# gnuplot ${BASEDIR}/plot-pucks-ratio
# gnuplot ${BASEDIR}/plot-pucks-counts
# gnuplot ${BASEDIR}/plot-inseminations
#
#
# for i in *png
# do
#   DEST=`readlink -f $i | sed 's|'${BASEDIR}'/||' | sed -e 's/\//./g'`
#   cp $i ${BASEDIR}/summary/${DEST}
# done
