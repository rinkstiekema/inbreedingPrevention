#!/bin/bash

## Process .descendants and .collected logs from MONEE run
for log in *.descendants 
do
	run=`basename $log .descendants`

	awk '
		## Process first file of arguments. 
		## GROUP BY to sum descendants per individual Save 'id' as key and # offspring as value
		## in a hash.
		FNR == NR {
		#	if !($3 in hash) hash[$3] = 0;
			if ($2!=0) hash[$2]++
			next
		}

		## JOIN: Process second file of arguments. If first field is found in the hash, print offspring, 
		## otherwise 0
		FNR < NR {
			if ( $1 > 1 ) {
				if ($2 in hash ) print $0, hash[$2]
				else print $0, 0
			}
		}	
	' ${run}.descendants ${run}.collected > $run.pressure-stats

	# Now, we have a single file with columns Time, Id, green puck count, red puck count, offspring
done
