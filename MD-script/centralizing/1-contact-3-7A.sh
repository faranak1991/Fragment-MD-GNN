#!/bin/bash
#SBATCH --job-name=1_cpptraj
#SBATCH --partition=chem_hzhou43
#SBATCH --account=chem_hzhou43
#SBATCH --nodes=1
#SBATCH --tasks-per-node=2
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=1
#SBATCH --time=122:00:00
#SBATCH --mem=16G
#SBATCH --output=run_cpptraj1.out
#SBATCH --error=run_cpptraj1.err

set -e

cd $SLURM_SUBMIT_DIR

module load GROMACS/2023.1-foss-2022a
module load Amber/22.0-foss-2021b-AmberTools-22.3-CUDA-11.5.2

NCHAINS=64
CUTOFFS="3 4 5 6 7"
CAP_BEFORE=1
CAP_AFTER=1

# ── Run only fragment 1 ───────────────────────────────────────────────────────
FRAG=1
RES_PER_CHAIN=16
RES_PER_COPY=$((RES_PER_CHAIN + CAP_BEFORE + CAP_AFTER))

FRAGDIR="traj/${FRAG}"
CENTERDIR="${FRAGDIR}/centerizing/out_remove_center"

PARM=$(ls ${FRAGDIR}/*.parm7 ${FRAGDIR}/*.prmtop 2>/dev/null | head -n 1)
if [ -z "$PARM" ]; then
    echo "ERROR: no parm7/prmtop found in ${FRAGDIR}"
    exit 1
fi

echo "======================================"
echo "Fragment ${FRAG}"
echo "Topology: $PARM"
echo "Residues per chain: $RES_PER_CHAIN"
echo "======================================"

for CUTOFF in $CUTOFFS; do

    OUTDIR="${CENTERDIR}/out_Res_Res_${CUTOFF}A"
    mkdir -p "$OUTDIR"

    for CH in $(seq 1 $NCHAINS); do

        NCFILE="${CENTERDIR}/ct.ch${CH}.nc"
        if [ ! -f "$NCFILE" ]; then
            echo "Missing $NCFILE"
            continue
        fi

        CH_START=$(( (CH - 1) * RES_PER_COPY + CAP_BEFORE + 1 ))
        CH_END=$(( CH_START + RES_PER_CHAIN - 1 ))

        OTHER_MASK=""
        for CH2 in $(seq 1 $NCHAINS); do
            if [ "$CH2" -eq "$CH" ]; then
                continue
            fi
            S=$(( (CH2 - 1) * RES_PER_COPY + CAP_BEFORE + 1 ))
            E=$(( S + RES_PER_CHAIN - 1 ))
            if [ -z "$OTHER_MASK" ]; then
                OTHER_MASK=":${S}-${E}"
            else
                OTHER_MASK="${OTHER_MASK},:${S}-${E}"
            fi
        done

        CPPIN="${OUTDIR}/cpptraj_ch${CH}_${CUTOFF}A.in"

        cat > "$CPPIN" << EOF
parm $PARM
trajin $NCFILE

nativecontacts name PROT${CH}_${CUTOFF}A \\
    :${CH_START}-${CH_END}&!@H= \\
    ${OTHER_MASK}&!@H= \\
    distance ${CUTOFF}.0 \\
    byresidue \\
    writecontacts ${OUTDIR}/PROT${CH}_contacts.dat

run
quit
EOF

        echo "Running fragment ${FRAG}, cutoff ${CUTOFF}A, chain ${CH}"
        cpptraj -i "$CPPIN" > "${OUTDIR}/cpptraj_ch${CH}_${CUTOFF}A.log" 2>&1

    done
done

echo "Done."