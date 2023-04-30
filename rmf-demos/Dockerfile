# syntax=docker/dockerfile:1

# global configuration values
# wanted ros distro and corresponding ubuntu version
ARG ROS_DISTRO=humble
ARG UBUNTU_VERSION=22.04
# wanted language
ARG LANGUAGE=de_DE.UTF-8
# wanted timezone
ARG TIMEZONE="Europe/Berlin"

FROM stepkun/vulcanexus:humble-run as base

# use global args
ARG TIMEZONE

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get upgrade -y \
  && sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list' \
  && wget https://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add - \
  && install ros-$ROS_DISTRO-rmf-demos-gz \
  # Cleanup
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/*

# set language and timezone
ENV LANG=$LANGUAGE \
    LANGUAGE=$LANGUAGE \
    LC_ALL=$LANGUAGE \
    TZ=$TIMEZONE \
    DEBIAN_FRONTEND=dialog
