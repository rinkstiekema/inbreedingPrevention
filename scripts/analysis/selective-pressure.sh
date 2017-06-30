#/bin/bash

foo=`mktemp`
inscount=`mktemp`
childcount=`mktemp`
stats=`mktemp`

#foo=foo
#inscount=inscount
#childcount=childcount
#stats=stats

results=children.per.insemination

seq 1 51452 > $results

for i in output*log.bz2
do
  bzcat $i | gawk -F ']' '/EggH/{for (i=1;i<=NF;i++) print $i}' > $foo
  awk '/\[/{a[$NF]++}END{for (i = 1; i<= 51452; i++) print(i,a[i] ? a[i] : 0)}' $foo | sort -n > $inscount
  awk '/Winner/{a[$3]++}END{for(i in a) print i, a[i] }' $foo | sort -n > $childcount
  awk 'FNR==NR{a[$1]=$2;next}{ print $0, a[$1] ? a[$1] : 0}' $childcount $inscount | sort  -n | join  $results - > $stats
  mv $stats $results
done

# End result is a file with columns: Id of genome, followed by two columns per run, 1st
# for insemination count, 2nd for offspring count

