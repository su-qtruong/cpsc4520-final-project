import argparse
import copy
import json
from pathlib import Path


CONDITIONS = {
    "baseline_no_lending": {
        "agentBaseInterestRate": [0.0, 0.0],
        "agentLendingFactor": [0, 0],
        "agentLoanDuration": [0, 0],
    },
    "standard_lending": {
        "agentBaseInterestRate": [0.05, 0.10],
        "agentLendingFactor": [1, 1],
        "agentLoanDuration": [5, 5],
    },
    "low_interest": {
        "agentBaseInterestRate": [0.01, 0.03],
        "agentLendingFactor": [1, 1],
        "agentLoanDuration": [5, 5],
    },
    "high_interest": {
        "agentBaseInterestRate": [0.25, 0.35],
        "agentLendingFactor": [1, 1],
        "agentLoanDuration": [5, 5],
    },
    "low_lending_factor": {
        "agentBaseInterestRate": [0.05, 0.10],
        "agentLendingFactor": [0.25, 0.25],
        "agentLoanDuration": [5, 5],
    },
    "high_lending_factor": {
        "agentBaseInterestRate": [0.05, 0.10],
        "agentLendingFactor": [2, 2],
        "agentLoanDuration": [5, 5],
    },
    "short_duration": {
        "agentBaseInterestRate": [0.05, 0.10],
        "agentLendingFactor": [1, 1],
        "agentLoanDuration": [2, 2],
    },
    "long_duration": {
        "agentBaseInterestRate": [0.05, 0.10],
        "agentLendingFactor": [1, 1],
        "agentLoanDuration": [20, 20],
    },
}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--base", default="config.json")
    parser.add_argument("--out", default="configs/generated")
    parser.add_argument("--list", default="configs/config_list.txt")
    parser.add_argument("--data-dir", default="data")
    parser.add_argument("--runs-per-condition", type=int, default=10) # 10 seeds
    parser.add_argument("--timesteps", type=int, default=1000)
    args = parser.parse_args()

    base_path = Path(args.base)
    output_dir = Path(args.out)
    config_list_path = Path(args.list)
    data_dir = Path(args.data_dir)

    output_dir.mkdir(parents=True, exist_ok=True)
    config_list_path.parent.mkdir(parents=True, exist_ok=True)
    data_dir.mkdir(parents=True, exist_ok=True)

    with open(base_path, "r") as f:
        base_config = json.load(f)

    generated_paths = []

    for condition_name, values in CONDITIONS.items():
        for run_num in range(1, args.runs_per_condition + 1):
            config = copy.deepcopy(base_config)
            options = config["sugarscapeOptions"]

            options["headlessMode"] = True
            options["screenshots"] = False
            options["keepAliveAtEnd"] = False
            options["keepAlivePostExtinction"] = False
            options["logfileFormat"] = "json"
            options["timesteps"] = args.timesteps
            options["seed"] = -1
            options["startingDiseases"] = 0
            options["startingDiseasesPerAgent"] = [0, 0]
            options["diseaseList"] = []
            options["agentInheritancePolicy"] = "none"

            options["agentBaseInterestRate"] = values["agentBaseInterestRate"]
            options["agentLendingFactor"] = values["agentLendingFactor"]
            options["agentLoanDuration"] = values["agentLoanDuration"]

            output_file = data_dir / f"{condition_name}_seed{run_num}.json"
            options["logfile"] = str(output_file)

            config_file = output_dir / f"{condition_name}_seed{run_num}.json"

            with open(config_file, "w") as f:
                json.dump(config, f, indent=4)

            generated_paths.append(str(config_file))

    with open(config_list_path, "w") as f:
        for path in generated_paths:
            f.write(path + "\n")

    print(f"Generated {len(generated_paths)} configs files and config_list.txt.")


if __name__ == "__main__":
    main()