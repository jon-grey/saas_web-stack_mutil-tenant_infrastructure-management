

setup-deployments:
	cd deployments-setup; \
	bash 00.main.sh

submit-deployments:
	cd deployments-submit; \
	bash 00.main.sh

all: setup-deployments submit-deployments