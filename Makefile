# Makefile
dev:        ## create / update the venv
	uv pip sync

prepare:    ## export, test, clean
	nbdev_export
	nbdev_clean
	nbdev_test
	pytest -q