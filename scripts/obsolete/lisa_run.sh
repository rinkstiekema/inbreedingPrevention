#!/bin/bash
#
# RoboRobo experiment script
#
#
# remove ppn, less than 5 min time: test node#bbPBS -lnodes=1:ppn=16#bbPBS -lwalltime=10:00:00
# Settings of PBS (do NOT uncomment these lines)
#--------------------------------------------------------------------------------------------------#
#PBS -lnodes=1:ppn=16
#PBS -lwalltime=03:00:00
#--------------------------------------------------------------------------------------------------#

### Set the simulation-specific parameters

# Edit the following directory/file settings
#--------------------------------------------------------------------------------------------------#
workdir=${HOME}/monee/
roborobodir=${HOME}/monee/RoboRobo
mytmpdir=monee #Subdirectory used in nodes' scratch space
resultsbase=${workdir}/results
#--------------------------------------------------------------------------------------------------#

repeats=16
iterations=2000000

echo "$(date)"
echo "Script running on `hostname`" 

echo "Nodes reserved:" 
NODES="$(sort $PBS_NODEFILE | uniq)"
echo "$NODES" 

#Start master process on this host
echo "Re-creating tempdir..." 
cd $TMPDIR;
rm -rf $mytmpdir
mkdir $mytmpdir

echo "Copying roborobo to scratch dir..." 
cp -rf ${roborobodir} $mytmpdir/

echo "Starting runs..." 
cd ${mytmpdir}/RoboRobo

#for PREMIUM in -1.0 0.0 1.0 10.0 100.0 1000.0
for PREMIUM in -1.0 0.0 1.0 10.0 20.0 50.0
do 
    resultsdir=${resultsbase}.premium.${PREMIUM}
    echo "Creating results dir: $resultsdir" 
    mkdir -pv $resultsdir

    bash scripts/run_monee.sh --repeats $repeats --iterations $iterations  --task1premium ${PREMIUM}

    #Wait until local process (master) is done
    wait

    #Copy results from this host's scratch space to home directory
    echo "Copying results to ${resultsdir}..." 
    mv -f  $TMPDIR/$mytmpdir/RoboRobo/logs/* ${resultsdir}
done
