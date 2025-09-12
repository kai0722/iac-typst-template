reset

set pm3d
set pm3d map
set ticslevel 0
set size ratio -1
set palette defined (0 "black", 0.95 "white", 1 "white")
#set palette defined ( 0 '#000000', 1 '#000090', 2 '#000fff', 3 '#0090ff', 4 '#0fffee', 5 '#90ff70', 6 '#ffee00', 7 '#ff7000', 8 '#ee0000', 9 '#7f0000')
#set palette defined ( 3.2 '#000000', 3.25 '#000090', 3.35 '#000fff', 3.7 '#0090ff', 4 '#0fffee', 5 '#90ff70', 6 '#ffee00', 7 '#ff7000', 8 '#ee0000', 9 '#7f0000')
#set palette defined(1.7"#000000",1.9"#5b13b8",2.2"#1c60ff",3"#00b7d8",4"#01eb75",5"#55f02e",6"#ccd73b",7"#ffc68c",8"#ffd5e2",9.5"#ffffff")
set ylabel "[mm]"
set xlabel "[mm]"
set format cb "%.2f"


IDEAL_MAX_PSF_P2 = +1.6362611e-05
IDEAL_MAX_PSF_P3 = +3.6279696e-05
IDEAL_MAX_PSF_P6 = +1.4259132e-04


ratio = 1000

r = 2e-4 * 1 * ratio
set xtics format "%.0tx10^{%T}"
set ytics format "%.0tx10^{%T}"
set format x "%.1f"
set format y "%10.1f"
set cbtics format "%.1tx10^{%T}"
set xrange[-r:r]
set yrange[-r:r]
set xtics r/2
set ytics r/2
set zrange[0:]
set cbrange[0:]

set tics font "Consolas,26"
set key font "Consolas,26"
set title font "Consolas,26"
set xlabel font "Consolas,26"
set ylabel font "Consolas,26"
set zlabel font "Consolas,26"
set y2label font "Consolas,26"
set cblabel font "Consolas,26"

unset colorbox



splot "./P2/psf_0000-1-0.dat" u ($2*ratio):($1*ratio):($3/IDEAL_MAX_PSF_P2) with pm3d ti ""
set term pngcairo enhanced size 1000,900
set output "./P2/psf1.png"
replot
set output
set terminal wxt

splot "./P3/psf_0000-1-0.dat" u ($2*ratio):($1*ratio):($3/IDEAL_MAX_PSF_P3) with pm3d ti ""
set term pngcairo enhanced size 1000,900
set output "./P3/psf1.png"
replot
set output
set terminal wxt

splot "./P6/psf_0000-1-0.dat" u ($2*ratio):($1*ratio):($3/IDEAL_MAX_PSF_P6) with pm3d ti ""
set term pngcairo enhanced size 1000,900
set output "./P6/psf1.png"
replot
set output
set terminal wxt


ratio = 1000000

r = 4e-5 * 1 * ratio
set xrange[-r:r]
set yrange[-r:r]
set xtics r/2
set ytics r/2

set format x "%.0f"
set format y "%10.0f"

set ylabel "[µm]"
set xlabel "[µm]"


splot "./P2/psf_0000-1-0.dat" u ($2*ratio):($1*ratio):($3/IDEAL_MAX_PSF_P2) with pm3d ti ""
set term pngcairo enhanced size 1000,900
set output "./P2/psf2.png"
replot
set output
set terminal wxt

splot "./P3/psf_0000-1-0.dat" u ($2*ratio):($1*ratio):($3/IDEAL_MAX_PSF_P3) with pm3d ti ""
set term pngcairo enhanced size 1000,900
set output "./P3/psf2.png"
replot
set output
set terminal wxt

splot "./P6/psf_0000-1-0.dat" u ($2*ratio):($1*ratio):($3/IDEAL_MAX_PSF_P6) with pm3d ti ""
set term pngcairo enhanced size 1000,900
set output "./P6/psf2.png"
replot
set output
set terminal wxt





