{
  i = ($col > 150) ? 150 : $col 
  if (i in lifetimes) 
    lifetimes[i] = lifetimes[i] " " $6 
  else 
    lifetimes[i] = $6
} 

END {
  for (i in lifetimes) 
    print i, lifetimes[i]i
}
