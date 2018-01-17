FROM debian:stretch

MAINTAINER Adam Cecile <acecile@le-vert.net>

ENV TERM xterm
ENV HOSTNAME dstm-cuda-zm.local
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /root

# Upgrade base system
RUN apt update \
    && apt -y -o 'Dpkg::Options::=--force-confdef' -o 'Dpkg::Options::=--force-confold' --no-install-recommends dist-upgrade \
    && rm -rf /var/lib/apt/lists/*

# Install dependencies
RUN apt update && apt -y -o 'Dpkg::Options::=--force-confdef' -o 'Dpkg::Options::=--force-confold' --no-install-recommends install wget ca-certificates && rm -rf /var/lib/apt/lists/*

# Install binary
#
# https://bitcointalk.org/index.php?topic=2021765.0
# Go to Google Drive link
# Next to the download button, click on the dots and select share
# Insert ID in the link below
# 19fSFYqoeOhOkxQqKnGpNI3n-7TIppHnq is "zm_0.5.8.tar.gz"
RUN mkdir /root/src \
    && wget "https://drive.google.com/uc?export=download&id=19fSFYqoeOhOkxQqKnGpNI3n-7TIppHnq" -O /root/src/miner.tar.gz \
    && tar xvzf /root/src/miner.tar.gz -C /root/src/ \
    && find /root/src -name 'zm' -exec cp {} /root/dstm-zm \; \
    && chmod 0755 /root/ && chmod 0755 /root/dstm-zm \
    && rm -rf /root/src/

# nvidia-container-runtime @ https://gitlab.com/nvidia/cuda/blob/ubuntu16.04/8.0/runtime/Dockerfile
ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64
LABEL com.nvidia.volumes.needed="nvidia_driver"
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
