#!/opt/local/bin/gawk
#
# $Id: moments.gawk,v 1.1 2001/05/13 07:09:06 doug Exp $
# Based on code from: http://www.bagley.org/~doug/shootout/
#
# -v cells = <n> determines size of (square) heatmap. Defaults to 256
#

BEGIN {
    # default to 1st column
    if (cells == 0) cells = 256;
}

! /^#/{
	x = int($2);
	y = int($3);
	heatmap[x,y] += 1;
}

END {
	max = 0;
	for (x = 0; x <= cells-1; x++) {
          for (y = 0; y <= cells-1; ++y) {

          	#print (x/cells) - 0.5, (y/cells) - 0.5, heatmap[x,y]
          	printf("%d ", heatmap[x, y]);

            if (heatmap[x, y] > max)
            	max = heatmap[x, y];
          }
          printf("\n");
     }

     printf("# Maximum count: %d\n", max);
}