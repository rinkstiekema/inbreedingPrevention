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

    	for (x = 1; x <= cells; x++) {
          for (y = 1; y <= cells; ++y) {
				heatmap[x,y] = 0;
			}
		}
}

! /^#/{
	x = int($2);
	y = int($3);
	heatmap[x,y] += 1;
}

END {
	max = 0;
	for (x = 1; x <= cells; x++) {
          for (y = 1; y <= cells; ++y) {
          	print x, y, heatmap[x,y]
          }
     }
}