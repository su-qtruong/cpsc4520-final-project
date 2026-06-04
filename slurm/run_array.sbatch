#!/bin/bash
#SBATCH -p RM-shared
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -t 02:00:00
#SBATCH --mem=4G
#SBATCH --array=1-80
#SBATCH --job-name=sugar-loans
#SBATCH -o logs/run_%A_%a.out
#SBATCH -e logs/run_%A_%a.err

set -x

cd "$SLURM_SUBMIT_DIR"

mkdir -p logs results

CONFIG_FILE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" configs/config_list.txt)

echo "Running config: $CONFIG_FILE"

python3 sugarscape.py --conf "$CONFIG_FILE"