testjs: ## Clean and Make js tests
	yarn test

testpy: ## Clean and Make unit tests
	python3.7 -m pytest -v tests --cov=jupyterlab_autoversion

tests: lint ## run the tests
	python3.7 -m pytest -v tests --cov=jupyterlab_autoversion --junitxml=python_junit.xml --cov-report=xml --cov-branch
	yarn test

lint: ## run linter
	flake8 jupyterlab_autoversion 
	yarn lint

fix:  ## run autopep8/tslint fix
	autopep8 --in-place -r -a -a jupyterlab_celltests/
	./node_modules/.bin/tslint --fix src/*

annotate: ## MyPy type annotation check
	mypy -s jupyterlab_autoversion

annotate_l: ## MyPy type annotation check - count only
	mypy -s jupyterlab_autoversion | wc -l 

clean: ## clean the repository
	find . -name "__pycache__" | xargs  rm -rf 
	find . -name "*.pyc" | xargs rm -rf 
	find . -name ".ipynb_checkpoints" | xargs  rm -rf 
	rm -rf coverage lab-dist cover htmlcov logs build dist *.egg-info lib node_modules *.log
	git clean -fd

install:  ## install to site-packages
	pip3 install .

serverextension: install ## enable serverextension
	jupyter serverextension enable --py jupyterlab_autoversion

js:  ## build javascript
	yarn
	yarn build

fix:  ## run autopep8/tslint fix
	autopep8 --in-place -r -a -a jupyterlab_autoversion/
	./node_modules/.bin/tslint --fix src/ts/**/*.ts

labextension: js ## enable labextension
	jupyter labextension install .

dist:  js  ## dist to pypi
	rm -rf dist build
	python3.7 setup.py sdist
	python3.7 setup.py bdist_wheel
	twine check dist/* && twine upload dist/*

# Thanks to Francoise at marmelab.com for this
.DEFAULT_GOAL := help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

print-%:
	@echo '$*=$($*)'

.PHONY: clean install serverextension labextension test tests help docs dist
