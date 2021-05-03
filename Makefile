

setup-deployments:
	cd deployments-setup; \
	bash 00.main.sh

submit-deployments:
	cd deployments-submit; \
	bash 00.main.sh

commit:
	git add --all
	git commit -m "Lazy update at $(date)."
	git push --set-upstream origin $(git rev-parse --abbrev-ref HEAD)

all: setup-deployments submit-deployments