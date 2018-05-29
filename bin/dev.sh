#!/usr/bin/env bash
export IMAGE_NAME="${REPO_NAME}:${REPO_TAG:-latest}"
export COMPOSE_HTTP_TIMEOUT=120

docker-compose -f 'docker-compose.dev.yml' -p dev up --build --abort-on-container-exit