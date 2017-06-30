#!/opt/local/bin/gnuplot
# $Id: plot-hexbin-puckcounts.gnuplot $
#set term aqua title system("pwd") size 512 512

set terminal pngcairo enhanced font "Helvetica,11" size 1024, 1024

set title system('pwd')

set yrange [0:35]
set ylabel 'nr. red pucks'
set xrange [0:35]
set xlabel 'nr. green pucks'
set style circle radius graph 0.012
set style fill transparent solid 0.05 noborder
set size square
set grid noxtics noytics
plot "<cat" w circles notitle lc rgb("navy")