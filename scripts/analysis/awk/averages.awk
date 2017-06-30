#! /bin/awk -f
BEGIN { 
  run = 0 
  N=100
} 

{
  run = run + 1

  if (run == 1) {
    print("#rank offspring sdev")
    print ("#" "neighbourhood_size", $2, "noise level", $4)
    for (x = 1; x <= N; x++) {
      sums[x] = 0
      sumsquares[x] = 0
    }
  }

  for (x = 1; x <= N; x++) {
    #count = $(x+10)
    count = $(x+12)
    sums[x] = sums[x] + count
    sumsquares[x] = sumsquares[x] + count^2
  }

  if (run == N) {
    for (x = 1; x <= N; x++) {
      squaredsum = sums[x]^2
      average = sums[x] / N
      sdev = sqrt(((sumsquares[x] - N) * average^2) / ( N - 1.0))
      print (x, sums[x]/N, sdev)
    }

    print ("#EOS")
    run = 0 
  }
}
