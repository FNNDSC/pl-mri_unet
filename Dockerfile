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
# Add NVIDIA package repositories
RUN apt install -y wget
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-repo-ubuntu1804_10.1.243-1_amd64.deb
RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub
RUN dpkg -i cuda-repo-ubuntu1804_10.1.243-1_amd64.deb
RUN apt-get update
#RUN wget https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64/nvidia-machine-learning-repo- ubuntu1804_1.0.0-1_amd64.deb
#RUN apt install ./nvidia-machine-learning-repo-ubuntu1804_1.0.0-1_amd64.deb
RUN apt-get update

# Install NVIDIA driver
RUN apt-get install -y --no-install-recommends nvidia-driver-450
# Reboot. Check that GPUs are visible using the command: nvidia-smi

# Install development and runtime libraries (~4GB)
RUN apt-get install -y --no-install-recommends \
    cuda-10-1 
    #libcudnn7=7.6.5.32-1+cuda10.1  \
    #libcudnn7-dev=7.6.5.32-1+cuda10.1

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

