# $Id: moments.gawk,v 1.1 2001/05/13 07:09:06 doug Exp $
# Based on code from http://www.bagley.org/~doug/shootout/
#
# Called with '-v skip=<nr>' will skip column <nr>, otherwise all columns
# are included.
# If -v prepend=true is also specified, prepends the skipped column to the output. The
# setting of prepend is ignored if skip is undefined
#

BEGIN{
	if (skip > 0 && prepend)
	    print "#skipped n median low_quartile hi_quartile mean avg_dev std_dev vari skew kurt conf_lo conf_hi";
	else
	    print "#n median low_quartile hi_quartile mean avg_dev std_dev vari skew kurt conf_lo conf_hi";
}
{
    sum = 0;
    n = 0;
    avg_dev = 0;
    vari = 0;
    skew = 0;
    kurt = 0;
    delete nums;

    for (i=1; i <= NF; i++)
    {
    	if (i != skip)
    	{
        	nums[n++] = $(i);
        	sum += $(i);
        }
    }

    mean = sum/n;

    for (num in nums) {
		dev = nums[num] - mean;
		avg_dev += (dev > 0) ? dev : -dev;
		vari += dev^2;
		skew += dev^3;
		kurt += dev^4;
    }
    avg_dev /= n;
    vari /= (n - 1);
    std_dev = sqrt(vari);

    if (vari != 0) {
		skew /= (n * vari * std_dev);
		kurt = kurt/(n * vari * vari) - 3.0;
    }

    asort(nums);

    mid = int(n/2)+1;
    median = (n % 2) ? nums[mid] : (nums[mid] + nums[mid-1])/2;
    quart = int(mid/2)+1;
    lowquartile = (n % 4) ? nums[quart] : (nums[quart] + nums[quart-1])/2;
    hiquartile = (n % 4) ? nums[mid+quart] : (nums[mid+quart] + nums[mid+quart-1])/2;

    median_ci_lower = int(n * 0.5 - 1.96 * sqrt(n * 0.5 * (1-0.5))) + 1
    median_ci_upper = int(n * 0.5 + 1.96 * sqrt(n * 0.5 * (1-0.5))) + 1

	if (skip > 0 && prepend)
	    print $(skip), n, median, lowquartile, hiquartile, mean, avg_dev, std_dev, vari, skew, kurt, nums[median_ci_lower], nums[median_ci_upper];
	else
	    print n, median, lowquartile, hiquartile, mean, avg_dev, std_dev, vari, skew, kurt, nums[median_ci_lower], nums[median_ci_upper];
}
