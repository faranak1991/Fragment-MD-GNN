#!/bin/bash
#SBATCH --job-name=cpptraj
#SBATCH --nodes=1
#SBATCH --ntasks=1               
#SBATCH --cpus-per-task=1
#SBATCH --time=1:00:00
#SBATCH --mem=4G
#SBATCH -p chem_hzhou43
#SBATCH -o ana.out
#SBATCH -e ana.err

module purge
module unuse /software/EasyBuild/INTEL_XEON_GOLD_6548Y_GPU_8.9/modules/all
module use /software/EasyBuild/Intel_Xeon_Platinum_8358_CPU__2.60GHz_GPU_8.9/modules/all
module load AmberTools/24.3-foss-2025a


cd $SLURM_SUBMIT_DIR

#mpirun -np 1 cpptraj.MPI -i Contactmask.set1.sim1.in
cpptraj -i 05_pdb_maker.in

