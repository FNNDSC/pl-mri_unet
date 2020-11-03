# Docker file for mri_unet ChRIS plugin app
#
# Build with
#
#   docker build -t <name> .
#
# For example if building a local version, you could do:
#
#   docker build -t local/pl-mri_unet .
#
# In the case of a proxy (located at 192.168.13.14:3128), do:
#
#    docker build --build-arg http_proxy=http://192.168.13.14:3128 --build-arg UID=$UID -t local/pl-mri_unet .
#
# To run an interactive shell inside this container, do:
#
#   docker run -ti --entrypoint /bin/bash local/pl-mri_unet
#
# To pass an env var HOST_IP to container, do:
#
#   docker run -ti -e HOST_IP=$(ip route | grep -v docker | awk '{if(NF==11) print $9}') --entrypoint /bin/bash local/pl-mri_unet
#

FROM fnndsc/ubuntu-python3:latest
MAINTAINER fnndsc "dev@babymri.org"

WORKDIR /usr/local/src
COPY . .
RUN apt install python3-dev python3-pip
RUN pip install -U pip numpy wheel
RUN pip install -U keras_preprocessing --no-deps
RUN pip install -U tensorflow
RUN pip --disable-pip-version-check install -r requirements.txt && pip install .

# the precedent is for a plugin to be run like
# docker run --entrypoint /usr/bin/python fnndsc/pl-appname appname /in /out
# executable scripts are expected to be found in the working directory
WORKDIR /usr/local/bin
CMD ["mri_unet", "--help"]

