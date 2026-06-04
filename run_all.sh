#!/bin/bash
#SBATCH -p RM-shared
#SBATCH -N 1
#SBATCH -n 5
#SBATCH -t 02:00:00
#SBATCH --mem=8G
#SBATCH -o logs/run_all_%j.out
#SBATCH -e logs/run_all_%j.err

cd /jet/home/qtruong1/sugarscape-project

python3 sugarscape.py --conf configs/config_0.json &
python3 sugarscape.py --conf configs/config_5.json &
python3 sugarscape.py --conf configs/config_10.json &
python3 sugarscape.py --conf configs/config_20.json &
python3 sugarscape.py --conf configs/config_50.json &

wait
