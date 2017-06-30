#!/opt/local/bin/gawk
#
# $Id: $
# 
# Bin data for a histogram
# Based on Tara Murphy's code
# usage: for data values between 0 and 10, with 5 bins
# gawk -f histogram.awk 0 10 5 data.in
# 

BEGIN { 
  m = ARGV[1]      # minimum value of x axis
  ARGV[1] = ""
  M = ARGV[2]      # maximum value of x axis
  ARGV[2] = ""
  b = ARGV[3]      # number of bins
  ARGV[3] = ""

  w = (M-m)/b      # width of each bin
  
  # set up arrays
  for (i = 1 ; i <= b; ++i) {
    n[i] = m+(i*w)        # upper bound of bin
    c[i] = n[i] - (w/2)   # centre of bin
    f[i] = 0              # frequency count
  }
}

{ 
   	for (i = 1; i <= b; ++i)
     {	
       if ($1 <= n[i]) {
            ++f[i]
            break
       }        
     }
}

END {
  # print results 
  for (i = 1; i <= b; ++i) {
    if (f[i] > 0) {
      print c[i], f[i]
    }
    else {

      print c[i], 0
    }
  }
}

