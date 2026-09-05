# Base image for the applause-detection Cloud Agent environment.
#
# Mirrors the project's Singularity definition (applause-detection.def), which
# targets ubuntu:20.04 -- the distro that ships Python 3.8 natively, matching the
# pinned scientific/ML stack (scipy==1.4.1, numba==0.48, librosa==0.7.2,
# tensorflow 2.8.x). System packages live here; Python packages are installed
# from requirements.txt by .cursor/install.sh after the repo is checked out.
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=America/New_York \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        python3.8 \
        python3.8-venv \
        python3.8-dev \
        python3.8-distutils \
        python3-pip \
        ffmpeg \
        build-essential \
        libsndfile1 \
        libatlas-base-dev \
        git \
        curl \
        ca-certificates \
        sudo \
    && rm -rf /var/lib/apt/lists/*

# Non-root user for the agent (passwordless sudo for any incidental setup).
RUN useradd --create-home --shell /bin/bash ubuntu \
    && echo "ubuntu ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ubuntu \
    && chmod 0440 /etc/sudoers.d/ubuntu

USER ubuntu
WORKDIR /home/ubuntu
