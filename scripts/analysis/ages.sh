#!/bin/bash

for run in  *.pressure-stats
do
	base=`basename $run .pressure-stats`
	awk 'BEGIN{stepsize=5000} \
		{i = int($1/stepsize); \
		 if (i in ages) \
			ages[i] = ages[i] " " $5 ;\
		 else\
			ages[i] = $5; \
		}\
		END {for (i in ages) \
		{print i*stepsize, ages[i]}}' $run | \
	awk '{if (NF > 3) print $0}' | \
	sort -n -k 1 | \
	gawk -f moments-per-line.awk -v skip=1 -v prepend=true > ${base}.ages.stats

done

awk 'BEGIN{stepsize=5000} \
	{i = int($1/stepsize); \
	 if (i in ages) \
		ages[i] = ages[i] " " $5 ;\
	 else\
	    ages[i] = $5; \
	}\
	END {for (i in ages) \
	{print i*stepsize, ages[i]}}' *.pressure-stats | \
awk '{if (NF > 3) print $0}' | \
sort -n -k 1 | \
gawk -f moments-per-line.awk -v skip=1 -v prepend=true > ages.stats
