#!/bin/bash
#SBATCH -p RM-shared
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -t 02:00:00
#SBATCH --mem=4G
#SBATCH -o logs/run_%A_%a.out
#SBATCH -e logs/run_%A_%a.err

cd /jet/home/qtruong1/sugarscape-project

rates=(0 5 10 20 50)

rate_index=$(( (SLURM_ARRAY_TASK_ID - 1) / 10 ))
run_num=$(( (SLURM_ARRAY_TASK_ID - 1) % 10 + 1 ))

rate=${rates[$rate_index]}

base_config="configs/config_${rate}.json"
temp_config="configs/temp_rate${rate}_run${run_num}.json"
output_file="results/rate${rate}_run${run_num}.json"

cp "$base_config" "$temp_config"

sed -i "s|\"seed\": .*|\"seed\": -1,|" "$temp_config"
sed -i "s|\"logfile\": .*|\"logfile\": \"$output_file\",|" "$temp_config"

python3 sugarscape.py --conf "$temp_config"