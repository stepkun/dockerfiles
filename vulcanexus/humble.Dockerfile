# syntax=docker/dockerfile:1

# non-root user "ros"
ARG USERNAME=ros
ARG USER_UID=1000
ARG USER_GID=$USER_UID

######################################
# Base image
######################################
# Base image for Vulcanexus/ROS2 humble is ubuntu 22.04
FROM ubuntu:22.04 AS run

# use global args
ARG USERNAME
ARG USER_UID
ARG USER_GID

ENV DEBIAN_FRONTEND=noninteractive

# Install apt-utils, language and timezone
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    apt-utils \
    tzdata \
    locales \
  && locale-gen de_DE.UTF-8 \
  && update-locale LC_ALL=de_DE.UTF-8 LANG=de_DE.UTF-8 \
  && dpkg-reconfigure --frontend noninteractive tzdata \
  # Cleanup
  && rm -rf /var/lib/apt/lists/*

# set language and timezone
ENV LANG de_DE.UTF-8
ENV TZ="Europe/Berlin"

# Install Base package of Vulcanexus which is including ROS2
RUN apt-get update && apt-get install -y \
    curl \
    gnupg2 \
    lsb-release \
  && curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null \
  && curl -sSL https://raw.githubusercontent.com/eProsima/vulcanexus/main/vulcanexus.key -o /usr/share/keyrings/vulcanexus-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/vulcanexus-archive-keyring.gpg] http://repo.vulcanexus.org/debian $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/vulcanexus.list > /dev/null \
  && apt-get -y update && apt-get install -y \
    vulcanexus-humble-base \
  # Cleanup
  && rm -rf /var/lib/apt/lists/*

# set environment for Vulcanexus/ROS2
ENV ROS_VERSION=2 \
    ROS_PYTHON_VERSION=3 \
    ROS_DISTRO=humble \
    ROS_LOCALHOST_ONLY=0 \
    VULCANEXUS_DISTRO=humble \
    VULCANEXUS_HOME=/opt/vulcanexus/humble \
    RMW_IMPLEMENTATION=rmw_fastrtps_cpp \
    PKG_CONFIG_PATH=/opt/vulcanexus/humble/lib/x86_64-linux-gnu/pkgconfig:/opt/vulcanexus/humble/lib/pkgconfig \
    AMENT_PREFIX_PATH=/opt/vulcanexus/humble:/opt/ros/humble \
    CMAKE_PREFIX_PATH=/opt/vulcanexus/humble \
    COLCON_PREFIX_PATH=/opt/vulcanexus/humble \
    PYTHONPATH=/opt/vulcanexus/humble/local/lib/python3.10/dist-packages:/opt/vulcanexus/humble/lib/python3.10/site-packages:/opt/ros/humble/lib/python3.10/site-packages:/opt/ros/humble/local/lib/python3.10/dist-packages \
    LD_LIBRARY_PATH=/opt/vulcanexus/humble/lib:/opt/ros/humble/opt/rviz_ogre_vendor/lib:/opt/ros/humble/lib/x86_64-linux-gnu:/opt/ros/humble/lib \
    PATH=/opt/vulcanexus/humble/bin:/opt/ros/humble/bin:$PATH

# add non-root user as defined above
RUN groupadd --gid $USER_GID $USERNAME \
  && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
  # Cleanup
  && rm -rf /var/lib/apt/lists/* \
  && echo "if [ -f /opt/ros/${ROS_DISTRO}/setup.bash ]; then source /opt/ros/${ROS_DISTRO}/setup.bash; fi" >> /home/$USERNAME/.bashrc

# cleanup image
ENV DEBIAN_FRONTEND=

######################################
# Developer image
######################################
FROM run AS devel

# use global args
ARG USERNAME
ARG USER_UID
ARG USER_GID

ENV DEBIAN_FRONTEND=noninteractive

# Add development packages
RUN apt-get update \
  && apt-get install -y \
    sudo \
    bash-completion \
    gdb \
    git \
    pylint \
    python3-colcon-common-extensions \
    python3-rosdep \
    python3-vcstool \
    python3-autopep8 \
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

ENV AMENT_CPPCHECK_ALLOW_SLOW_VERSIONS=1

# cleanup image
ENV DEBIAN_FRONTEND=

######################################
# Developer image
######################################
FROM devel AS full

ENV DEBIAN_FRONTEND=noninteractive

# Add development packages
RUN apt-get update \
  && apt-get install -y \
    vulcanexus-humble-desktop \
  # Cleanup
  && rm -rf /var/lib/apt/lists/*

# cleanup image
ENV DEBIAN_FRONTEND=

