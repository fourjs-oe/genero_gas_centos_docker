#!/usr/bin/env bash

export HOST_APACHE_PORT=${HOST_APACHE_PORT:-8080}
export GENERO_DOCKER_IMAGE=${GENERO_DOCKER_IMAGE:-genero}


docker run --rm -it --publish ${HOST_APACHE_PORT}:80 --name ${GENERO_DOCKER_IMAGE} ${GENERO_DOCKER_IMAGE}
