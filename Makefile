CONFIG = config.json
DATACHECK = data/data.complete
LOGS = agents.log.csv agents.log.json log.csv log.json
PLOT = plot.py
PLOTCHECK = plots/plots.complete
RUN = run.py
SCREENSHOTS = *.ps
TEST = test.py

DATASET = $(DATACHECK) \
		data/*[[:digit:]]*.config \
		data/*.csv \
		data/*.json \
		data/*.sh

PLOTS = $(PLOTCHECK) \
		plots/*.pdf

TESTS = tests/*.config \
        tests/*.log

CLEAN = $(DATASET) \
		$(LOGS) \
		$(PLOTS) \
		$(SCREENSHOTS) \
		$(TESTS)

# Python / Sugarscape
PYTHON = python3
SUGARSCAPE = sugarscape.py

# Experiment paths
CONFIG_DIR = configs
GENERATED_CONFIG_DIR = $(CONFIG_DIR)/generated
CONFIG_LIST = $(CONFIG_DIR)/config_list.txt
CONFIG_GENERATOR = scripts/generate_lending_configs.py
LOG_DIR = logs
RESULTS_DIR = results
SLURM_DIR = slurm

# Experiment setup: 8 configs x 10 random seeds = 80 jobs
RUNS_PER_CONDITION = 10
TIMESTEPS = 1000

# Check for local Python aliases
PYCHECK = $(shell which python > /dev/null; echo $$?)
PY3CHECK = $(shell which python3 > /dev/null; echo $$?)

$(DATACHECK):
	cd data && $(PYTHON) $(RUN) --conf ../$(CONFIG) --mode csv
	touch $(DATACHECK)

$(PLOTCHECK): $(DATACHECK)
	cd plots && $(PYTHON) $(PLOT) --path ../data/ --conf ../$(CONFIG)
	touch $(PLOTCHECK)

all: $(DATACHECK) $(PLOTCHECK)

data: $(DATACHECK)

plots: $(PLOTCHECK)

run:
	$(PYTHON) $(SUGARSCAPE) --conf $(CONFIG)

seeds:
	cd data && $(PYTHON) $(RUN) --conf ../$(CONFIG) --mode csv --seeds

setup:
	@echo "Checking for local Python installation."
ifeq ($(PY3CHECK), 0)
	@echo "Found alias for Python."
	sed -i 's/PYTHON = python$$/PYTHON = python3/g' Makefile
	sed -i 's/"python"/"python3"/g' $(CONFIG)
else ifneq ($(PYCHECK), 0)
	@echo "Could not find a local Python installation."
	@echo "Please update the Makefile and configuration file manually."
else
	@echo "This message should never be reached."
endif

test:
	cd tests && $(PYTHON) $(TEST) --conf ../$(CONFIG)

# Generate 80 configs: 8 lending conditions x seeds 1-10
configs:
	mkdir -p $(GENERATED_CONFIG_DIR) $(RESULTS_DIR)
	$(PYTHON) $(CONFIG_GENERATOR) \
		--base $(CONFIG) \
		--out $(GENERATED_CONFIG_DIR) \
		--list $(CONFIG_LIST) \
		--data-dir $(RESULTS_DIR) \
		--runs-per-condition $(RUNS_PER_CONDITION) \
		--timesteps $(TIMESTEPS)

# Test run
run-generated-test:
	mkdir -p $(RESULTS_DIR)
	$(PYTHON) $(SUGARSCAPE) --conf $$(head -n 1 $(CONFIG_LIST))

# Submit configs using SLURM job array
submit-array:
	mkdir -p $(LOG_DIR) $(RESULTS_DIR)
	sbatch $(SLURM_DIR)/run_array.sbatch

# Full experiment workflow: generate configs + submit SLURM array
experiment: configs submit-array

# Clean config files
clean-configs:
	rm -rf $(GENERATED_CONFIG_DIR)/*.json $(CONFIG_LIST)
	rm -rf $(CONFIG_DIR)

# Clean outputs and logs
clean-experiment:
	rm -rf data/*.json $(LOG_DIR)/*.out $(LOG_DIR)/*.err $(RESULTS_DIR)/*.csv

clean:
	rm -rf $(CLEAN) || true

lean:
	rm -rf $(PLOTS) || true

.PHONY: all clean data lean plots run seeds setup test configs run-generated-test submit-array experiment clean-configs clean-experiment
# vim: set noexpandtab tabstop=4: