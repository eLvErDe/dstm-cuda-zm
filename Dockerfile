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
# 11e1fSA2cl14xRL8sMA9BA3AhBGQNn4e4 is "zm_0.5.7.tar.gz"
RUN mkdir /root/src \
    && wget "https://drive.google.com/uc?export=download&id=11e1fSA2cl14xRL8sMA9BA3AhBGQNn4e4" -O /root/src/miner.tar.gz \
    && tar xvzf /root/src/miner.tar.gz -C /root/src/ \
    && find /root/src -name 'zm' -exec cp {} /root/dstm-zm \; \
    && chmod 0755 /root/ && chmod 0755 /root/dstm-zm \
    && rm -rf /root/src/

# This version is dynamically linked to libssl.so.1.0.0 so we'll get those files from Debian Stretch
RUN mkdir /root/src \
    && wget http://deb.debian.org/debian/pool/main/o/openssl/libssl1.0.0_1.0.1t-1+deb8u7_amd64.deb -O /root/src/libssl.deb \
    && dpkg --fsys-tarfile /root/src/libssl.deb \
       | tar xv --directory=/root --strip-components=4 ./usr/lib/x86_64-linux-gnu/libcrypto.so.1.0.0 ./usr/lib/x86_64-linux-gnu/libssl.so.1.0.0 \
    && rm -rf /root/src/

# nvidia-container-runtime @ https://gitlab.com/nvidia/cuda/blob/ubuntu16.04/8.0/runtime/Dockerfile
ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64
# For libssl.so.1.0.0
ENV LD_LIBRARY_PATH /root:${LD_LIBRARY_PATH}
LABEL com.nvidia.volumes.needed="nvidia_driver"
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
