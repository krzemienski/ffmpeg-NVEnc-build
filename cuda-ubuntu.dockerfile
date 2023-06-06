ARG VER=20.04

FROM ubuntu:${VER} AS build

ARG CUDAVER=11.8.0-1

ENV DEBIAN_FRONTEND noninteractive
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility,video

ENV FFMPEG_VERSION ${FFMPEG_VERSION}
ENV NVENC_VERSION ${NVENC_VERSION}
ENV VER ${VER}

RUN apt-get update \
    && apt-get -y --no-install-recommends install wget ca-certificates \
    && update-ca-certificates \
    && wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.0-1_all.deb \
    && dpkg -i cuda-keyring_1.0-1_all.deb \
    && apt-get update

RUN apt-get -y --no-install-recommends install build-essential curl libva-dev python3 python-is-python3 ninja-build meson \
    cuda="${CUDAVER}" \
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*



RUN pip3 install meson

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 10

RUN add-apt-repository ppa:ubuntu-toolchain-r/test -y

RUN apt update && apt install gcc-9 g++-9 -y

RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 60 --slave /usr/bin/g++ g++ /usr/bin/g++-9

WORKDIR /app
COPY ./build-ffmpeg /app/build-ffmpeg
COPY ./ldd.sh /app/ldd.sh
COPY ./copyfiles.sh /app/copyfiles.sh

RUN /app/build-ffmpeg --build --enable-gpl-and-non-free

RUN /app/workspace/bin/ffmpeg --help

