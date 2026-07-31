#!/bin/bash
#SBATCH --job-name=cpptraj
#SBATCH --nodes=1
#SBATCH --ntasks=1               
#SBATCH --cpus-per-task=1
#SBATCH --time=2:00:00
#SBATCH --mem=14G
#SBATCH -p chem_hzhou43
#SBATCH -o ana.out
#SBATCH -e ana.err

module purge
module unuse /software/EasyBuild/INTEL_XEON_GOLD_6548Y_GPU_8.9/modules/all
module use /software/EasyBuild/Intel_Xeon_Platinum_8358_CPU__2.60GHz_GPU_8.9/modules/all
module load AmberTools/24.3-foss-2025a


cd $SLURM_SUBMIT_DIR

tleap -f step1.water.remove.in

sed '/Na+/d' amber_n_na.pdb > amber_n_na.strip.pdb

awk '!(($4=="NME") && ($3=="CH3" || $3=="HH31" || $3=="HH32" || $3=="HH33"))' amber_n_na.strip.pdb > amber_n_na.fixed.pdb

tleap -f step2.tleap.setup.in





# tleap -f step1.water.remove.in
# sed '/Na+/d' amber_n_na.pdb > amber_n_na.strip.pdb
# tleap -f step2.tleap.setup.in


# #sed '/Na+/{N;d;}' amber_n_na.pdb > amber_n_na.strip.pdb
