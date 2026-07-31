# ===================== LOAD SYSTEM =====================
mol new prmtop.0.3.2.no.water.caprin.parm7
mol addfile  frag.CAP.N64.byatom.ns.nc  first 0 last -1 step 1 waitfor all 


# ===================== OUTPUT =====================
set filename "density_x"
set writefile [open "$filename.dat" w]

# ===================== BOX LIMITS =====================
set x_min -47
set x_max  47

set y_min -47
set y_max  47

set z_min -47
set z_max  47

# ===================== BINNING =====================
# Bin only in X
set x_bin 47
set y_bin 1
set z_bin 1

set dx [expr {double($x_max-$x_min)/$x_bin}]

# ===================== MAIN LOOP =====================
for {set i $x_min} {$i <= $x_max} {set i [expr {$i+$dx}]} {

    set bin [format "x>%.3f and x<=%.3f and y>%.3f and y<=%.3f and z>%.3f and z<=%.3f" \
              $i [expr {$i+$dx}] \
              $y_min $y_max \
              $z_min $z_max]

    set selection [atomselect top "$bin and (resid 1 to 1152 and noh)"]

    set sum_frame 0
    set n [molinfo top get numframes]

    for {set l 0} {$l < $n} {incr l} {
        $selection frame $l
        $selection update
        set atomNumber [$selection num]
        set sum_frame [expr {$sum_frame + $atomNumber}]
    }

    set numberDensity [expr {double($sum_frame)/$n}]

    puts $writefile "$i $numberDensity"
}

close $writefile

