-include .env
export

API_HOST ?= 0.0.0.0
API_PORT ?= 8081
DATABASE ?= coco.yaml

.PHONY: install
install: ## Install the virtual environment and install the pre-commit hooks
	@echo "🚀 Creating virtual environment using uv"
	@uv venv --system-site-packages
	@uv sync
	@uv run pre-commit install

.PHONY: check
check: ## Run code quality tools.
	@echo "🚀 Checking lock file consistency with 'pyproject.toml'"
	@uv lock --locked
	@echo "🚀 Linting code: Running pre-commit"
	@uv run pre-commit run -a
	@echo "🚀 Static type checking: Running mypy"
	@uv run mypy

.PHONY: test
test: ## Test the code with pytest
	@echo "🚀 Testing code: Running pytest"
	@uv run python -m pytest --doctest-modules

.PHONY: run
run: ## Run the taubenturret backend application in the background
	@[ -d .venv ] || uv venv --system-site-packages
	@bash -c 'uv run uvicorn taubenturret_backend.api:create_app --host $${API_HOST} --port $${API_PORT} --factory > .taubenturret_backend.log 2>&1 & echo $$! > .taubenturret_backend.pid'
	@echo "Started taubenturret backend in background (PID $$(cat .taubenturret_backend.pid))"

.PHONY: stop
stop: ## Stop the backend process using the saved PID
	@if [ -f .taubenturret_backend.pid ]; then \
		PID="$$(cat .taubenturret_backend.pid)"; \
		if kill -0 "$$PID" 2>/dev/null; then \
			kill "$$PID"; \
			echo "Stopped taubenturret backend (PID $$PID)"; \
		else \
			echo "Process $$PID is not running"; \
		fi; \
		rm -f .taubenturret_backend.pid; \
	else \
		echo "No PID file found"; \
	fi

.PHONY: status
status: ## Print the PID of the running backend process
	@if [ -f .taubenturret_backend.pid ]; then \
		PID="$$(cat .taubenturret_backend.pid)"; \
		if kill -0 "$$PID" 2>/dev/null; then \
			echo "$$PID"; \
		else \
			echo "not running"; \
			exit 1; \
		fi; \
	else \
		echo "not running"; \
		exit 1; \
	fi

.PHONY: model
model: ## Export the YOLO model to OpenVINO format
	@echo "🚀 Exporting YOLO model to OpenVINO format using the $(DATABASE) dataset"
	@uv run yolo export model=yolov8n.pt format=openvino int8=True data=$(DATABASE) imgsz=640
	@uv run python -c "import shutil, os; \
	shutil.rmtree('yolo_openvino_model', ignore_errors=True); \
shutil.move('yolov8n_int8_openvino_model', 'yolo_openvino_model') if os.path.exists('yolov8n_int8_openvino_model') else None"

.PHONY: docker
docker: ## Build the Docker image for the backend
	@echo "🚀 Building Docker image 'taubenturret-backend'"
	@docker build -t taubenturret-backend:latest .

.PHONY: build
build: clean-build ## Build wheel file
	@echo "🚀 Creating wheel file"
	@uvx --from build pyproject-build --installer uv

.PHONY: clean-build
clean-build: ## Clean build artifacts
	@echo "🚀 Removing build artifacts"
	@uv run python -c "import shutil; import os; shutil.rmtree('dist') if os.path.exists('dist') else None"

.PHONY: clean
clean: clean-build
	@echo "🚀 Cleaning project and environment"
	@uv run python -c "import shutil, os, glob; \
[shutil.rmtree(d, ignore_errors=True) for d in ['.venv', '.mypy_cache', '.ruff_cache', 'yolo_openvino_model']]; \
[os.remove(f) for p in ['*.pyc'] for f in glob.glob(p)]; \
[shutil.rmtree(os.path.join(r, d), ignore_errors=True) for r, ds, fs in os.walk('.') for d in ds if d == '__pycache__']"

.PHONY: help
help:
	@uv run python -c "import re; \
	[[print(f'\033[36m{m[0]:<20}\033[0m {m[1]}') for m in re.findall(r'^([a-zA-Z_-]+):.*?## (.*)$$', open(makefile).read(), re.M)] for makefile in ('$(MAKEFILE_LIST)').strip().split()]"

.DEFAULT_GOAL := help
