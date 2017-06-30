#!/opt/local/bin/gawk
#
# $Id: $
#
# Output for R's Fischer Exact Test as follows:
#
# 				High Offspring	Low Offspring
# Lo Fitness	A 				B
# Hi Fitness	C 				D
#
# Matrix per time slice
# Analogously for Puck Count
#
# Input: generation Id offspring fitness
# Output: generation A B C D
#

!/^\#/{
	i = $1

	generations[maxGen++]=i
	sizes[i]++
	Ids[i][sizes[i]] = $2
	offspring[i][sizes[i]] = $3;
	fitnesses[i][sizes[i]] = $4;
}
# Note: 0-based basic arrays, but subarrays 1-based (for asort compatibility)

END {
	# calculate median values per generation and fill matrices for FET
	for (i in generations) {

		n = sizes[i];

		if (!(i in fitnesses)) continue

		# Calculate threshold values
    	asort(fitnesses[i], fit);
    	asort(offspring[i], children);

		percentile = 2  # 2: median, 4: quartile, etc.
		tIndex = int(n/percentile) + 1;
 		thresholdFitness = (n % percentile) ? fit[tIndex] : (fit[tIndex] + fit[tIndex-1])/2;
 		 offspringCutoff = (n % percentile) ? children[tIndex] : (children[tIndex] + pucks[tIndex-1])/2;

		a[i] = 0;
		b[i] = 0;
		c[i] = 0;
		d[i] = 0;

		for (j=1; j<=n; j++)
		{
#			print Ids[i][j], offspring[i][j], fitnesses[i][j] > "/dev/stderr"
			if (offspring[i][j] < offspringCutoff)  # Low offspring
			{
				if (fitnesses[i][j] > thresholdFitness)
					a[i]++;	# high fitness, low offspring
				else
					c[i]++;	# low fitness, low offspring

			} else {	# High offspring
				if (fitnesses[i][j] > thresholdFitness)
					b[i]++;	# high fitness, high offspring
				else
					d[i]++;	# low fitness, high offspring

			}
		}

		print i, a[i], b[i], c[i], d[i]
	}
}