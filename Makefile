bootstrap:
	# install Nikola
	pipx install --force Nikola[extras]
	# add extra dependencies
	pipx inject Nikola[extras] pypandoc
	pipx inject Nikola[extras] pydevto
	# ghp-import as a standalone tool
	pipx install --force ghp-import
	# install plugins
	nikola plugin -i devto
.PHONY: bootstrap

build:
	nikola build
.PHONY: build

dev:
	nikola auto
.PHONY: dev

check: build
	nikola check -lf
.PHONY: check

deploy:
	nikola github_deploy
.PHONY: deploy

clean:
	nikola clean
.PHONY: clean
