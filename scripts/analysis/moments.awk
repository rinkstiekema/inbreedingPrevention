#!/opt/local/bin/gawk
#
# $Id: moments.gawk,v 1.1 2001/05/13 07:09:06 doug Exp $
# Based on code from: http://www.bagley.org/~doug/shootout/
#
# -v column = <n> will cause column nr n to be used as input. Defaults to column 1
#

BEGIN {
    sum = 0;
    n = 0;
    sumReciprocal = 0;
    product = 1;

    # default to 1st column
    if (column == 0) column = 1;

}

!/^#/{
    nums[n++] = $column;
    sum += $column;
    if ($column != 0 && $column != "")
	    sumReciprocal += 1/$column;
    product *= $column;
}

END {
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

    if (vari > 0) {
		skew /= (n * vari * std_dev);
		kurt = kurt/(n * vari * vari) - 3.0;
    }

    asort(nums);

    mid = int(n/2)+1;
    quart = int(n/4)+1;
    median = (n % 2) ? nums[mid] : (nums[mid] + nums[mid-1])/2;
    lowquartile = (n % 4) ? nums[quart] : (nums[quart] + nums[quart-1])/2;
    hiquartile = (n % 4) ? nums[mid+quart-1] : (nums[mid+quart-1] + nums[mid+quart-2])/2;

    median_ci_lower = int(n * 0.5 - 1.96 * sqrt(n * 0.5 * (1-0.5))) + 1
    median_ci_upper = int(n * 0.5 + 1.96 * sqrt(n * 0.5 * (1-0.5))) + 1

    printf("n:                  %d\n", n);
    printf("min:                %f\n", nums[1]);
    printf("max:                %f\n", nums[n]);
    printf("median:             %f\n", median);
    printf("lowquartile:        %f\n", lowquartile);
    printf("hiquartile:         %f\n", hiquartile);
    printf("arithmetic_mean:    %f\n", mean);
    printf("average_deviation:  %f\n", avg_dev);
    printf("standard_deviation: %f\n", std_dev);
    printf("variance:           %f\n", vari);
    printf("skew:               %f\n", skew);
    printf("kurtosis:           %f\n", kurt);
    printf("harmonic_mean:      %f\n", n/sumReciprocal);
    printf("geometric_mean:     %f\n", product ^ (1/n));
    printf("median conf. int.:  <%f, %f>\n", nums[median_ci_lower], nums[median_ci_upper]);
}
