How to build Genero GAS docker image
====================================

First copy all required installer, archives and fglprofile
files to the docker directory.

Fill an fglprofile file with appropriate licensing information:

```
flm.license.number="XXX#XXXXXXXX"
flm.license.key="XXXXXXXXXXXX"
flm.server="hostname"
flm.service="6399"
```

Export following environment variables (or use the env.txt as a sample to setup the environment):

```bash
# FGLGWS package to install - add you packeg in the current directory and replace the name below
export FGLGWS_PACKAGE=fjs-fglgws-3.10.01-build1486651223-l64xl212.run

# GAS package to install - same than for fglgws, copie in the current directory and replace the name of the packeg below

export GAS_PACKAGE=fjs-gas-3.10.00-build154169-l64xl212.run
```

Then execute the `docker_build_genero_image.sh`

By default a genero gas docker image has been generated.

Now start the container by executing the `docker_run_genero_image.sh` script.

Then open the following url:

    http://localhost:8080/gas/ua/r/gwc-demo

The authentication parameters are:
  - user: gasadmin
  - password: gasadmin

