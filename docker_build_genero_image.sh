#!/usr/bin/env bash

fail()
{
  echo "$@"
  exit 1
}

# Docker image name
GENERO_DOCKER_IMAGE=${GENERO_DOCKER_IMAGE:-genero}

# Defaults
HOST_APACHE_PORT=${HOST_APACHE_PORT:-8080}

##### Apache file where passwords will be stored
APACHE_AUTH_FILE=${APACHE_AUTH_FILE:-apache-auth}

##### gasadmin user password for apache
GASADMIN_PASSWD=${GASADMIN_PASSWD:-gasadmin}

##### Provide ROOT_URL_PREFIX base on HOST_APACHE_PORT
ROOT_URL_PREFIX=http://localhost:${HOST_APACHE_PORT}/gas

##### FGLGWS package
FGLGWS_PACKAGE=${FGLGWS_PACKAGE:-$(ls -tr fjs-fglgws-*l64xl212.run | tail -n 1)}

##### GAS package
GAS_PACKAGE=${GAS_PACKAGE:-$(ls -tr fjs-gas-*l64xl212.run | tail -n 1)}

##### Ensure packages to install are provided.
[ -z "${FGLGWS_PACKAGE}" ] && fail "No fglgws package provided. FGLGWS_PACKAGE environment variable is missing."
[ -z "${GAS_PACKAGE}" ] && fail "No gas package provided. GAS_PACKAGE environment variable is missing."

cp ${FGLGWS_PACKAGE} fglgws-install.run ||  fail "Failed to copy ${FGLGWS_PACKAGE} to ./fglgws-install.run"
cp ${GAS_PACKAGE} gas-install.run ||  fail "Failed to copy ${GAS_PACKAGE} to ./fglgws-install.run"

##### Generate the password file
htpasswd -cb apache-auth gasadmin ${GASADMIN_PASSWD}

##### Build the Genero GAS image
docker build --pull --force-rm --build-arg FGLGWS_PACKAGE=fglgws-install.run \
     --build-arg GAS_PACKAGE=gas-install.run          \
     --build-arg ROOT_URL_PREFIX=${ROOT_URL_PREFIX}   \
     --build-arg APACHE_AUTH_FILE=${APACHE_AUTH_FILE} \
     -t ${GENERO_DOCKER_IMAGE} .

rm -f fglgws-install.run gas-install.run
