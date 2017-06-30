#!/opt/local/bin/gnuplot

#set term aqua title system("pwd") size 512 512

unset multiplot
set key off
set term aqua 0 size 2048 512 font "Helvetica,22" dashed title 'premium-impacts'

set style circle radius graph 0.018
set style fill transparent solid 0.01 noborder
set size square
set grid noxtics noytics

set multiplot layout 1,4

set xlabel "green puck ratio"
set ylabel ""

set label 1 "count" at -0.25,7.5 center rotate by 90

set yrange [0:15]
set xrange [0:1]
set xtics 0.25
set ytics 5
#set title 'premium -1'
#plot "< awk '$1==998000{print $0}' premium.-1.0/pucks-collected-ratio.0 | gawk -f ~/projects/awk/transpose.awk | tail -n 64 | gawk -f ~/projects/awk/histogram.awk 0 1 50" w impulse lw 4 lc rgb("#242485") notitle


set title 'premium 1'
plot "< awk '$1==998000{print $0}' premium.1.0/pucks-collected-ratio.0 | gawk -f ~/projects/awk/transpose.awk | tail -n 64 | gawk -f ~/projects/awk/histogram.awk 0 1 50" w impulse lw 4 lc rgb("#242485") notitle

unset label 1

set title 'premium 10'
plot "< awk '$1==998000{print $0}' premium.10.0/pucks-collected-ratio.0 | gawk -f ~/projects/awk/transpose.awk | tail -n 64 | gawk -f ~/projects/awk/histogram.awk 0 1 50" w impulse lw 4 lc rgb("#242485") notitle

set title 'premium 50'
plot "< awk '$1==998000{print $0}' premium.50.0/pucks-collected-ratio.0 | gawk -f ~/projects/awk/transpose.awk | tail -n 64 | gawk -f ~/projects/awk/histogram.awk 0 1 50" w impulse lw 4 lc rgb("#242485") notitle

set title 'premium 100'
plot "< awk '$1==998000{print $0}' premium.100.0/pucks-collected-ratio.0 | gawk -f ~/projects/awk/transpose.awk | tail -n 64 | gawk -f ~/projects/awk/histogram.awk 0 1 50" w impulse lw 4 lc rgb("#242485") notitle