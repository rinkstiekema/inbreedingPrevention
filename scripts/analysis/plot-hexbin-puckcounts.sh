#/bin/bash

# $Id: plot-hexbin-puckcounts.sh $

#BASEDIR=$HOME/monee/results
BASEDIR=$HOME/monee/monee/scripts/analysis

sliceSize=5000

for experiment in $@
do
 	pushd ${experiment}
	(
	for slice in `seq  $sliceSize $sliceSize 399000`
	do
		let index=$slice/$sliceSize
		awk -v slice=$slice -v sliceSize=$sliceSize 'slice < $1 && $1 < slice + sliceSize{print $3,$4}' *.collected | \
		gnuplot -e "set label 't: $slice' at 0,-1" -e "set output 'hexbinslice${index}.png'" ${BASEDIR}/plot-hexbin-puckcounts.gnuplot  -
	done

	ffmpeg  -r 4 -y -i hexbinslice%d.png -pix_fmt yuv420p puck-hexbin.avi

	rm hexbinslice*

	)&
 	popd
done

