# DensityCalculator Version 20210830

#proc dc {file_1 file_2 type firstFrame lastFrame step \
         zl zh zr atomSelection} {

#if {[string equal $file_1 $file_2]} {
#	mol new $file_1 first $firstFrame last $lastFrame step $step waitfor all
#} else {
#	mol new $file_1
#	mol addfile $file_2 first $firstFrame last $lastFrame step $step waitfor all
#
#set framenum [lindex $::argv 0]


mol new prmtop.0.3.2.no.water.caprin.parm7
mol addfile  frag.CAP.N64.byatom.ns.nc first 0 last -1 step 1 waitfor all 



#mol addfile /home/ramesh/Phase_mol_2021/traj/Heterolinker_YF/YFcFY/T3/output/ctstep1.a.ns.nc first 2301 last 3300 step 1 waitfor all
#set dx [expr double($xh-$xl)/$xr]
#set dy [expr double($yh-$yl)/$yr]
#set dz [expr double($zh-$zl)/$zr]
set filename "density.z"
set writefile [open "$filename.dat" w]

# ------Mass density on Z plane (unit:g/cm^3)------
# making range from xmin and xmax and same for y min max

#set xlist {-13.24}
#
# set ylist {-13.24}
#
set x_min -47
set x_max 47

set y_min -47
set y_max 47

set z_min -47
set z_max 47

## bin 3 for 3by3 
set x_bin 1
set y_bin 1 
set z_bin 47

#set numberDensity [expr {double($sum_frame)/($frameNub)}]

set dx [expr {double($x_max-$x_min)/$x_bin}]
set dy [expr {double($y_max-$y_min)/$y_bin}]
set dz [expr {double($z_max-$z_min)/$z_bin}]


for {set i $z_min} {$i <= $z_max } {set i [expr {$i+$dz}]} {
	#puts "$i"
	set data {}
	for {set j $x_min} {$j < $x_max } {set j [expr {$j+$dx}]} {
		#puts "$j"
		for {set k $y_min} {$k < $y_max } {set k [expr {$k+$dy}]} {
			#puts "$k"
			set bin [format "x>%.3f and x<=%.3f and y>%.3f and y<=%.3f and z>%.3f and z<=%.3f" \
                                $j [expr {$j +$dx}]  $k [expr {$k +$dy}] $i [expr {$i +$dz}]]

			set selection [atomselect top "$bin and (resid 1 to 1152 and noh)"]
	                set sum_frame 0
                        set n [molinfo top get numframes]
                	for {set l 0} {$l < $n} {incr l} {
                        	$selection frame $l
                        	$selection update
                        	set atomNumber [$selection num]
                        	set sum_frame [expr {$sum_frame+$atomNumber}]
                	}
                	set numberDensity [expr {double($sum_frame)/($n)}]
                	lappend data $numberDensity
		#	puts " $j [expr {$j +$dx}]  $k [expr {$k +$dy}] $i [expr {$i +$dz}]"

		}	

	}
	puts $writefile "$i $data"
	#puts "$i $data"



}


close $writefile

