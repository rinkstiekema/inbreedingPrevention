{
   if (NR == 1 + skip) min=max=$column;
   min = (min < $column ? min : $column)
   max = (max > $column ? max : $column)
}

END { print "max: ", max, "; min: ", min }
