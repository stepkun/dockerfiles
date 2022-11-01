# Base image for ROS2 humble is ubuntu 22.04
FROM ubuntu:22.04 AS base

ENV DEBIAN_FRONTEND=noninteractive

# set timezone
ENV TZ="Europe/Berlin"

# Install language
RUN apt-get update && apt-get install -y \
  locales \
  && locale-gen de_DE.UTF-8 \
  && update-locale LC_ALL=de_DE.UTF-8 LANG=de_DE.UTF-8 \
  && rm -rf /var/lib/apt/lists/*
ENV LANG de_DE.UTF-8

# Install timezone
RUN ln -fs /usr/share/zoneinfo/UTC /etc/localtime \
  && export DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get install -y tzdata \
  && dpkg-reconfigure --frontend noninteractive tzdata \
  && rm -rf /var/lib/apt/lists/*

# Install Base package of Vulcanexus
RUN apt-get update -y && apt-get install -y \
    curl \
    gnupg2 \
    lsb-release \
    sudo \
  && curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null \
  && curl -sSL https://raw.githubusercontent.com/eProsima/vulcanexus/main/vulcanexus.key -o /usr/share/keyrings/vulcanexus-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/vulcanexus-archive-keyring.gpg] http://repo.vulcanexus.org/debian $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/vulcanexus.list > /dev/null \
  && apt-get -y update && apt-get install -y \
    vulcanexus-humble-base \
    python3-argcomplete \
  && rm -rf /var/lib/apt/lists/*

ENV DEBIAN_FRONTEND=