# syntax=docker/dockerfile:1

# global configuration values
# non-root user "ros"
ARG USERNAME=ros
ARG USER_UID=1000
ARG USER_GID=$USER_UID
# wanted ros distro
ARG ROS_DISTRO=humble
# wanted timezone
ARG TIMEZONE="Europe/Berlin"

######################################
# Localized image
######################################
# Base image for Vulcanexus/ROS2 humble is ubuntu 22.04
FROM ubuntu:22.04 AS localized

ARG TIMEZONE

ENV DEBIAN_FRONTEND=noninteractive

# Install apt-utils, language, timezone and xterm
RUN apt-get update \
  && apt-get install -y \
    apt-utils \
    locales \
    tzdata \
    xterm \
  && locale-gen de_DE.UTF-8 \
  && update-locale LC_ALL=de_DE.UTF-8 LANG=de_DE.UTF-8 \
  && dpkg-reconfigure --frontend noninteractive tzdata \
  # Cleanup
  && rm -rf /var/lib/apt/lists/*

# set language and timezone
ENV LANG de_DE.UTF-8 \
    TZ=$TIMEZONE

# cleanup image
ENV DEBIAN_FRONTEND=

######################################
# Runtime image
######################################
# Base image for Vulcanexus/ROS2 humble is ubuntu 22.04
FROM localized AS run

# use global args
ARG USERNAME
ARG USER_UID
ARG USER_GID
ARG ROS_DISTRO
ARG TIMEZONE

ENV DEBIAN_FRONTEND=noninteractive

# Install Base package of Vulcanexus which is including ROS2
RUN apt-get update \
  && apt-get install -y \
    curl \
    gnupg2 \
    lsb-release \
  && curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null \
  && curl -sSL https://raw.githubusercontent.com/eProsima/vulcanexus/main/vulcanexus.key -o /usr/share/keyrings/vulcanexus-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/vulcanexus-archive-keyring.gpg] http://repo.vulcanexus.org/debian $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/vulcanexus.list > /dev/null \
  && apt-get -y update \
  && apt-get install -y \
    vulcanexus-$ROS_DISTRO-base \
  # add non-root user as defined above
  && groupadd --gid $USER_GID $USERNAME \
  && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
  && echo "if [ -f /opt/ros/${ROS_DISTRO}/setup.bash ]; then source /opt/ros/${ROS_DISTRO}/setup.bash; fi" >> /home/$USERNAME/.bashrc \
  # Cleanup
  && rm -rf /var/lib/apt/lists/*

# set environment for Vulcanexus/ROS2
ENV AMENT_PREFIX_PATH=/opt/vulcanexus/humble:/opt/ros/humble \
    CMAKE_PREFIX_PATH=/opt/vulcanexus/humble \
    COLCON_PREFIX_PATH=/opt/vulcanexus/humble \
    LD_LIBRARY_PATH=/opt/vulcanexus/humble/lib:/opt/ros/humble/opt/rviz_ogre_vendor/lib:/opt/ros/humble/lib/x86_64-linux-gnu:/opt/ros/humble/lib \
    PATH=/opt/vulcanexus/humble/bin:/opt/ros/humble/bin:$PATH \
    PKG_CONFIG_PATH=/opt/vulcanexus/humble/lib/x86_64-linux-gnu/pkgconfig:/opt/vulcanexus/humble/lib/pkgconfig \
    PYTHONPATH=/opt/vulcanexus/humble/local/lib/python3.10/dist-packages:/opt/vulcanexus/humble/lib/python3.10/site-packages:/opt/ros/humble/lib/python3.10/site-packages:/opt/ros/humble/local/lib/python3.10/dist-packages \
    RMW_IMPLEMENTATION=rmw_fastrtps_cpp \
    ROS_DISTRO=$ROS_DISTRO \
    ROS_LOCALHOST_ONLY=0 \
    ROS_PYTHON_VERSION=3 \
    ROS_VERSION=2 \
    VULCANEXUS_DISTRO=humble \
    VULCANEXUS_HOME=/opt/vulcanexus/humble \
    TZ=$TIMEZONE \
    # cleanup image
    DEBIAN_FRONTEND=

# change startup user to ros
CMD su ros


######################################
# Developer image
######################################
FROM run AS dev

# use global args
ARG USERNAME
ARG USER_UID
ARG USER_GID
#ARG ROS_DISTRO
ARG TIMEZONE

ENV DEBIAN_FRONTEND=noninteractive

# Add development packages
RUN apt-get update \
  && apt-get install -y \
    bash-completion \
    gdb \
    git \
    pylint \
    python3-autopep8 \
    python3-colcon-common-extensions \
    python3-rosdep \
    python3-vcstool \
    sudo \
    vim \
    wget \
  && rosdep init || echo "rosdep already initialized" \
  # Update pydocstyle
  && pip install --upgrade pydocstyle \
  # Add sudo support for the non-root user
  && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME\
  && chmod 0440 /etc/sudoers.d/$USERNAME \
  && echo "source /usr/share/bash-completion/completions/git" >> /home/$USERNAME/.bashrc \
  # Cleanup
  && rm -rf /var/lib/apt/lists/*

ENV AMENT_CPPCHECK_ALLOW_SLOW_VERSIONS=1 \
    TZ=$TIMEZONE \
    DEBIAN_FRONTEND=

######################################
# Full desktop image
######################################
FROM dev AS full

# use global args
ARG USERNAME
ARG USER_UID
ARG USER_GID
ARG ROS_DISTRO

ENV DEBIAN_FRONTEND=noninteractive

# Add development packages
RUN apt-get update \
  && apt-get install -y \
    vulcanexus-$ROS_DISTRO-desktop \
  # Cleanup
  && rm -rf /var/lib/apt/lists/*

# cleanup image
ENV TZ=$TIMEZONE \
    DEBIAN_FRONTEND=
