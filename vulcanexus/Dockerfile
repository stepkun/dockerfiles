# Base image for ROS2 humble is ubuntu 22.04
FROM ubuntu:22.04 AS base

ENV DEBIAN_FRONTEND=noninteractive

# Install apt-utils, language and timezone
RUN apt-get update && apt-get install -y \
    apt-utils \
    tzdata \
    locales \
  && locale-gen de_DE.UTF-8 \
  && update-locale LC_ALL=de_DE.UTF-8 LANG=de_DE.UTF-8 \
  && dpkg-reconfigure --frontend noninteractive tzdata \
  && rm -rf /var/lib/apt/lists/*

# set language and timezone
ENV LANG de_DE.UTF-8
ENV TZ="Europe/Berlin"

# Install Base package of Vulcanexus including ROS2
RUN apt-get update && apt-get install -y \
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
  && rm -rf /var/lib/apt/lists/*

ENV DEBIAN_FRONTEND=