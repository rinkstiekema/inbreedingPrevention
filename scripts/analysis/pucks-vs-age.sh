#/bin/bash

# remove ppn, less than 5 min time: test node
# Settings of PBS (do NOT uncomment these lines)
#--------------------------------------------------------------------------------------------------#
#PBS -lnodes=1
#PBS -lwalltime=00:04:59
#--------------------------------------------------------------------------------------------------#

FULLCOMMAND="$0 $@"
. ${HOME}/lib/shflags

BASEDIR=$HOME/monee/monee/scripts/analysis

for i in $@
do
  pushd $i
  (
    awk -v col=3 -f ${BASEDIR}/pucks-vs-age.awk *.pressure-stats | sort -n -k 1 | awk -v skip=1 -v prepend=true -f moments-per-line.awk > pucks-vs-age.0
    awk -v col=4 -f ${BASEDIR}/pucks-vs-age.awk *.pressure-stats | sort -n -k 1 | awk -v skip=1 -v prepend=true -f moments-per-line.awk > pucks-vs-age.1
  )&
 	
  popd
done

wait
