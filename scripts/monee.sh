#!/bin/bash

SCRIPT=`realpath -s $0`

SCRIPTPATH=`dirname $SCRIPT`

FULLCOMMAND="$0 $@"
. $SCRIPTPATH/lib/shflags 

#define the flags
DEFINE_integer 'seed' '0' 'Seed' 's'
DEFINE_string 'iterations' '1000000' 'Number of iterations' 'i'
DEFINE_string 'basedir' './' 'Base dir of experiment' 'b'
DEFINE_string 'templatedir' 'template' 'Directory with template properties file'
DEFINE_string 'logdir' 'logs' 'Directory to store the output'
DEFINE_string 'template' 'TwoColours' 'Template file name'
DEFINE_float 'task1premium' '1.0' 'Premium (multiplication factor) for the 1st task'
DEFINE_boolean 'market' true 'Enable currency exchange mechanism'
DEFINE_float 'specialisation' 0.0 'Penalise generalists (by limiting their speed). Higher values: stricter penalty. 0.0: no penalty, 1.0: standard penalty.' 
DEFINE_boolean 'randomSelection' false 'Random parent selection'
DEFINE_float 'commDistance' '27' 'Maximum communication distance'
DEFINE_float 'maxLifeTime' '2000' 'Maximum duration of active gathering phase'
DEFINE_float 'maxEggTime' '200' 'Maximum time spent as egg'
DEFINE_integer 'energyPuckId' '-1' 'Which pucktype is used as energy point instead of task'
DEFINE_float 'energyBoost' '0.25' 'Lifetime boost from energy punk (ratio)'
DEFINE_integer 'tournamentSize' '2' 'Size of tournament for parent selection. Values smaller than 2 imply rank-based roulettewheel selection (which was default before 18 Jun 2014)'
DEFINE_boolean 'excludeEnergyPucks' true 'Exclude energy pucks from task and fitness calculations'
DEFINE_boolean 'fixedBoost' false 'If true, energy boost is a percentage of original lifetime, otherwise (the default) a percentage of remaining lifetime'
DEFINE_boolean 'logCollisions' false 'If true, collision info is logged in (large) separate log file. No collision logging otherwise'
DEFINE_boolean 'gBatchMode' false 'If true, show gui'

# Parse the flags
FLAGS "$@" || exit 1
eval set -- "${FLAGS_ARGV}"

BASEDIR=${FLAGS_basedir}
TEMPLATEDIR=${FLAGS_templatedir}
CONFNAME=${FLAGS_template}
TASK1PREMIUM=${FLAGS_task1premium}

cd ${BASEDIR} #enables this script to be run from wherever.

# echo "running " `basename $0` " --seed ${FLAGS_seed} --basedir ${BASEDIR} --templatedir ${TEMPLATEDIR} --iterations ${FLAGS_iterations} --logdir ${FLAGS_logdir} --template ${CONFNAME} --task1premium ${FLAGS_task1premium}"

RUNID=`date "+%Y%m%d.%Hh%Mm%Ss"`.${RANDOM}

### copy the template configuration to the config dir, making the neccesary adjustments

# Determine where the configuration file will be placed
CONFDIR=${BASEDIR}/config
CONFFILE=${CONFDIR}/${RUNID}.properties
LOGFILE=${BASEDIR}/logs/${RUNID}.cout
ERRORLOGFILE=${BASEDIR}/logs/${RUNID}.cerr

OUTPUTLOGFILE=logs\\/${RUNID}.output.log
COLLISIONLOGFILE=logs\\/${RUNID}.collision.log

GENOMELOGFILE=logs\\/${RUNID}.genomes.log
ORGANISMSIZESLOGFILE=logs\\/${RUNID}.organism-sizes.log
ORGANISMSLOGFILE=logs\\/${RUNID}.organisms.log
LOCATIONLOGFILE=logs\\/${RUNID}.locations.log

# Generate a random seed if the value 0 was passed.
if [ ${FLAGS_seed} -eq '0' ]; then
  FLAGS_seed=${RANDOM}
fi

# Prepare the replacement commands that will fill out the configuration template
SEEDREP=s/--RANDOMSEED/${FLAGS_seed:0:9}/g # extract only the first 9 decimals, because Roborobo can't handle int overflows
ITERATIONREP=s/--ITERATIONS/${FLAGS_iterations}/g
OUTPUTLOGREP=s/--OUTPUTLOG/${OUTPUTLOGFILE}/g
COLLISIONLOGREP=s/--COLLISIONLOG/${COLLISIONLOGFILE}/g
TASKPREMIUMREP=s/--TASK1PREMIUM/${TASK1PREMIUM}/g
COMMDISTREP=s/--COMMDISTANCE/${FLAGS_commDistance}/g
USESPECREP=s/--USE_SPECIALISATION/${FLAGS_specialisation}/g
LIFETIMEREP=s/--MAXLIFETIME/${FLAGS_maxLifeTime}/g
EGGTIMEREP=s/--MAXEGGTIME/${FLAGS_maxEggTime}/g
ENERGYIDREP=s/--ENERGYPUCKID/${FLAGS_energyPuckId}/g
ENERGYBOOSTREP=s/--ENERGYBOOST/${FLAGS_energyBoost}/g
TOURNAMENTSIZEREP=s/--TOURNAMENT_SIZE/${FLAGS_tournamentSize}/g
LOGCOLLISIONSREP=s/--LOG_COLLISIONS/${FLAGS_logCollisions}/g


if [ ${FLAGS_market} -eq ${FLAGS_TRUE} ]; then
  USEMARKETREP=s/--USE_MARKET/true/g
else
  USEMARKETREP=s/--USE_MARKET/false/g
fi

if [ ${FLAGS_randomSelection} -eq ${FLAGS_TRUE} ]; then
  USERANDSELREP=s/--USE_RANDOMSELECTION/true/g
else
  USERANDSELREP=s/--USE_RANDOMSELECTION/false/g
fi

if [ ${FLAGS_excludeEnergyPucks} -eq ${FLAGS_TRUE} ]; then
  EXCLUDEENERGYREP=s/--EXCLUDE_ENERGY_PUCKS/true/g
else
  EXCLUDEENERGYREP=s/--EXCLUDE_ENERGY_PUCKS/false/g
fi

if [ ${FLAGS_fixedBoost} -eq ${FLAGS_TRUE} ]; then
  FIXEDENERGYREP=s/--FIXED_ENERGYBOOST/true/g
else
  FIXEDENERGYREP=s/--FIXED_ENERGYBOOST/false/g
fi

if [ ${FLAGS_logCollisions} -eq ${FLAGS_TRUE} ]; then
  LOGCOLLISIONSREP=s/--LOG_COLLISIONS/true/g
else
  LOGCOLLISIONSREP=s/--LOG_COLLISIONS/false/g
fi

# Fill out and place the configuration file
sed -e $USERANDSELREP \
    -e $USEMARKETREP  \
    -e $USESPECREP  \
    -e $TASKPREMIUMREP  \
    -e $COLLISIONLOGREP \
    -e $SEEDREP \
    -e $OUTPUTLOGREP \
    -e $ITERATIONREP \
    -e $COMMDISTREP \
    -e $LIFETIMEREP \
    -e $ENERGYIDREP \
    -e $EXCLUDEENERGYREP \
    -e $ENERGYBOOSTREP \
    -e $TOURNAMENTSIZEREP \
    -e $FIXEDENERGYREP \
    -e $LOGCOLLISIONSREP \
    -e $EGGTIMEREP ${TEMPLATEDIR}${CONFNAME}.properties > ${CONFFILE}

if [ $? -ne 0 ]
then
    exit $?
fi

 
### Run RoboRobo!
cp ${CONFFILE} "${BASEDIR}"/logs
BINFILE="${BASEDIR}"/roborobo

$BINFILE -l $CONFFILE > $LOGFILE 2> $ERRORLOGFILE 

for log in "${BASEDIR}"/logs/*${RUNID}*.log; do
   bzip2 $log
done

bzip2 "${LOGFILE}"

rm ${CONFFILE}

find ${BASEDIR}/logs -name "properties_`echo $RUNID| tr '.' '-' | cut -d "-" -f 1-2`*ms_${FLAGS_seed}.txt" -exec mv '{}' ${BASEDIR}/logs/${RUNID}.properties.dump \;

if [ ${FLAGS_useSpecialiser} -eq ${FLAGS_TRUE} ]; then
  mkdir -p ${BASEDIR}/logs/specialised_sm${FLAGS_stealMargin}_sa${FLAGS_stealAmount}_lc${FLAGS_specialiserLifeCap}
  mv ${BASEDIR}/logs/${RUNID}* ${BASEDIR}/logs/specialised_sm${FLAGS_stealMargin}_sa${FLAGS_stealAmount}_lc${FLAGS_specialiserLifeCap}
else
  mkdir -p ${BASEDIR}/logs/standard
  mv ${BASEDIR}/logs/${RUNID}* ${BASEDIR}/logs/standard
fi