for i in *.cout.bz2 
do
	bzgrep descendant $i | sed -e 's/\[descendant\]//' > `basename $i .cout.bz2`.descendants
         bzgrep gathered $i | sed -e 's/\[gathered\]//' > `basename $i .cout.bz2`.collected
done
