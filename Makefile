#!/bin/bash

APP = pasaia_pdf
VERSION := $(shell cat ./VERSION)
DOCKER_REPO_APP = ikerib/${APP}
DOCKER_REPO_NGINX = ikerib/${APP}_nginx
USER_ID = $(shell id -u)
GROUP_ID= $(shell id -g)
user==www-data

help:
	@echo 'usage: make [target]'
	@echo
	@echo 'targets'
	@egrep '^(.+)\:\ ##\ (.+)' ${MAKEFILE_LIST} | column -t -c 2 -s ":#"

build: ## build
	docker compose --env-file .env.local build

build-force:## build-force
	docker compose --env-file .env.local build --force-rm --no-cache

restart:##restart
	$(MAKE) stop && $(MAKE) run

run:
	docker compose --env-file .env.local up -d

stop:
	docker compose down

ssh:
	docker compose exec app zsh

deploy:
	docker build -f docker/php-prod/Dockerfile -t ${DOCKER_REPO_APP} .
	docker tag ${DOCKER_REPO_APP} ${DOCKER_REPO_APP}:${VERSION}
	docker push ${DOCKER_REPO_APP}:${VERSION}
	docker build -f docker/nginx/Dockerfile -t ${DOCKER_REPO_NGINX} .
	docker tag ${DOCKER_REPO_NGINX} ${DOCKER_REPO_NGINX}:${VERSION}
	docker push ${DOCKER_REPO_NGINX}:${VERSION}
