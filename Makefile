.ONESHELL:
.PHONY: install run test conda-install conda-run conda-test conda-clean

# Override on the command line if needed, e.g. `make PYTHON=python3 run`
PYTHON ?= python

# Name of the conda environment
ENV_NAME = eddy
PROFILE = example
FIELD = quick_run
QUERY = example_meshgrid
DIM = 20

# `conda run` works identically on Windows/macOS/Linux — no need to
# source conda.sh or branch on OS to activate an environment.
CONDA_RUN = conda run --no-capture-output -n $(ENV_NAME)

## Using default python and pip
install:
	$(PYTHON) -m pip install -r requirements.txt

run:
	$(PYTHON) ./src/main.py new -p $(PROFILE) -n $(FIELD) -d $(DIM) $(DIM) $(DIM) && $(PYTHON) ./src/main.py query -n $(FIELD) -q $(QUERY)

test:
	$(PYTHON) -m pytest --cov=src --cov-fail-under=95 -m "(unit or system) and not slow"

## Using Conda

# Create the conda environment with Python 3.11 and install dependencies
conda-install:
	conda create --name $(ENV_NAME) python=3.11 -y && $(CONDA_RUN) python -m pip install -r requirements.txt

# Create new field and query
conda-run:
	$(CONDA_RUN) python ./src/main.py new -p $(PROFILE) -n $(FIELD) -d $(DIM) $(DIM) $(DIM) && $(CONDA_RUN) python ./src/main.py query -n $(FIELD) -q $(QUERY)

conda-test:
	$(CONDA_RUN) python -m pytest --cov=src --cov-fail-under=95 -m "(unit or system) and not slow"

# Delete the conda environment
conda-clean:
	conda env remove --name $(ENV_NAME) -y
