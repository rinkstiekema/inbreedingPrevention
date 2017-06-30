# $Id: moments.gawk,v 1.1 2001/05/13 07:09:06 doug Exp $
# http://www.bagley.org/~doug/shootout/

BEGIN{
    print "#time n median loQ hiQ mean avg_dev std_dev";
}
{
    sum = 0;
    n = 0;

    for (i=2; i <= NF; i++)
    {
        nums[n++] = $(i);
        sum += $(i);
    } 

	if (n > 1)
	{
		mean = sum/n;
		for (num in nums) {
		dev = nums[num] - mean;
		if (dev > 0) { avg_dev += dev; } else { avg_dev -= dev; }
		vari += dev^2;
		skew += dev^3;
		kurt += dev^4;
		}
		
		avg_dev /= n;
		vari /= (n - 1);
		std_dev = sqrt(vari);
	
		nums[n] = nums[0];
		heapsort(n, nums);
	
		mid = int(n/2)+1;
		median = (n % 2) ? nums[mid] : (nums[mid] + nums[mid-1])/2;
		
		q1 = int(mid/2)+1;
		loQ = (mid % 2) ? nums[q1] : (nums[q1] + nums[q1-1])/2;
		hiQ = (mid % 2) ? nums[mid+q1] : (nums[mid+q1] + nums[mid+q1-1])/2;
	} else {
		median = loQ = hiQ = mean = sum;
		avg_dev = std_dev = vari = 0;
	}

	print $1,n,median,loQ,hiQ,mean,avg_dev,std_dev;
}

function heapsort (n, ra) {
    l = int(0.5+n/2) + 1
    ir = n;
    for (;;) {
        if (l > 1) {
            rra = ra[--l];
        } else {
            rra = ra[ir];
            ra[ir] = ra[1];
            if (--ir == 1) {
                ra[1] = rra;
                return;
            }
        }
        i = l;
        j = l * 2;
        while (j <= ir) {
            if (j < ir && ra[j] < ra[j+1]) { ++j; }
            if (rra < ra[j]) {
                ra[i] = ra[j];
                j += (i = j);
            } else {
                j = ir + 1;
            }
        }
        ra[i] = rra;
    }
}
