# syntax=docker/dockerfile:1
# Copyright (c) 2022-2023 Stephan Kunz

# set global configuration values from environment
# wanted ros distro and corresponding ubuntu version
ARG ROS_DISTRO=${ROS_DISTRO}
ARG UBUNTU_VERSION=${UBUNTU_VERSION}
# wanted language
ARG LANGUAGE=${LANGUAGE}
# wanted timezone
ARG TIMEZONE=${TIMEZONE}
# non-root user
ARG USERNAME=${USERNAME}
ARG USER_UID=${USER_UID}
ARG USER_GID=${USER_GID}

######################################
# Runtime image
######################################
FROM ubuntu:$UBUNTU_VERSION AS run

# use global args
ARG LANGUAGE
ARG TIMEZONE
ARG ROS_DISTRO
ARG USERNAME
ARG USER_UID
ARG USER_GID

USER root

ENV DEBIAN_FRONTEND=noninteractive

# Install Base package of Vulcanexus which is including ROS2
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    alsa-utils \
    apt-utils \
    curl \
    gnupg2 \
    iputils-ping \
    locales \
    lsb-release \
    nano \
    pulseaudio \
    python-is-python3 \
    python3-pip \
    sudo \
    tmux \
    tzdata \
    vim \
    wget \
    xterm \
  && locale-gen $LANGUAGE \
  && update-locale LC_ALL=$LANGUAGE LANG=$LANGUAGE \
  && dpkg-reconfigure --frontend noninteractive tzdata \
  && curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null \
  && curl -sSL https://raw.githubusercontent.com/eProsima/vulcanexus/main/vulcanexus.key -o /usr/share/keyrings/vulcanexus-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/vulcanexus-archive-keyring.gpg] http://repo.vulcanexus.org/debian $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/vulcanexus.list > /dev/null

RUN apt-get update && apt-get install -y \
    bash-completion \
    vulcanexus-$ROS_DISTRO-core \
    vulcanexus-$ROS_DISTRO-micro \
    vulcanexus-$ROS_DISTRO-cloud \
    # also install demo nodes for testing purposes
    ros-$ROS_DISTRO-demo-nodes-cpp \
    ros-$ROS_DISTRO-demo-nodes-py \
  # add non-root user as defined above
  && groupadd --gid $USER_GID $USERNAME \
  && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
  # Add sudo support for the non-root user
  && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
  && chmod 0440 /etc/sudoers.d/$USERNAME \
  && echo "source /usr/share/bash-completion/completions/git" >> /home/$USERNAME/.bashrc \
  && echo "source /opt/vulcanexus/$ROS_DISTRO/setup.bash" >> /home/$USERNAME/.bashrc \
  # Cleanup
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/*

# set environment for Vulcanexus/ROS2
ENV LANG=$LANGUAGE \
    LANGUAGE=$LANGUAGE \
    LC_ALL=$LANGUAGE \
    TZ=$TIMEZONE \
    AMENT_PREFIX_PATH=/opt/vulcanexus/$ROS_DISTRO:/opt/ros/$ROS_DISTRO \
    CMAKE_PREFIX_PATH=/opt/vulcanexus/$ROS_DISTRO \
    COLCON_PREFIX_PATH=/opt/vulcanexus/$ROS_DISTRO \
    LD_LIBRARY_PATH=/opt/vulcanexus/$ROS_DISTRO/lib:/opt/ros/$ROS_DISTRO/opt/rviz_ogre_vendor/lib:/opt/ros/$ROS_DISTRO/lib/x86_64-linux-gnu:/opt/ros/$ROS_DISTRO/lib \
    LOGNAME=$USERNAME \
    PATH=/opt/vulcanexus/$ROS_DISTRO/bin:/opt/ros/$ROS_DISTRO/bin:$PATH \
    PKG_CONFIG_PATH=/opt/vulcanexus/$ROS_DISTRO/lib/x86_64-linux-gnu/pkgconfig:/opt/vulcanexus/$ROS_DISTRO/lib/pkgconfig \
    PYTHONPATH=/opt/vulcanexus/$ROS_DISTRO/local/lib/python3.10/dist-packages:/opt/vulcanexus/$ROS_DISTRO/lib/python3.10/site-packages:/opt/ros/$ROS_DISTRO/lib/python3.10/site-packages:/opt/ros/$ROS_DISTRO/local/lib/python3.10/dist-packages \
    RMW_IMPLEMENTATION=rmw_fastrtps_cpp \
    ROS_DISTRO=$ROS_DISTRO \
    ROS_LOCALHOST_ONLY=0 \
    ROS_PYTHON_VERSION=3 \
    ROS_VERSION=2 \
    USER=$USERNAME \
    VULCANEXUS_DISTRO=$ROS_DISTRO \
    VULCANEXUS_HOME=/opt/vulcanexus/$ROS_DISTRO \
    DEBIAN_FRONTEND=

# change startup user to ros
USER $USERNAME
WORKDIR /home/$USERNAME


######################################
# Developer image
######################################
FROM run AS dev

# use global args
ARG ROS_DISTRO
ARG TIMEZONE
ARG USERNAME

USER root

ENV DEBIAN_FRONTEND=noninteractive

# Add development packages
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    gdb \
    git \
    openssh-client \
    pylint \
    python3-autopep8 \
    python3-colcon-common-extensions \
    python3-rosdep2 \
    python3-vcstool \
    ros-dev-tools \
    terminator \
    valgrind \
    vulcanexus-$ROS_DISTRO-tools \
  # Update pydocstyle
  && pip install --upgrade pydocstyle \
  && rosdep init || echo "rosdep already initialized"

# build colcon sanitize environment for defined user
USER $USERNAME
WORKDIR /home/$USERNAME

RUN sudo apt-get install -y python3-colcon-mixin \
  && sudo rosdep init \
  && colcon mixin add default https://raw.githubusercontent.com/colcon/colcon-mixin-repository/master/index.yaml \
  && colcon mixin update default \
  && git clone https://github.com/colcon/colcon-sanitizer-reports.git \
  && cd colcon-sanitizer-reports \
  && sudo python3 setup.py install \
#  && cd .. \
#  && sudo rm -fR colcon-sanitizer-reports \
  # Cleanup
  && sudo apt-get autoremove -y \
  && sudo apt-get clean -y \
  && sudo rm -rf /var/lib/apt/lists/*

# set environment variables
ENV AMENT_CPPCHECK_ALLOW_SLOW_VERSIONS=1 \
    TZ=$TIMEZONE \
    DEBIAN_FRONTEND=


######################################
# Simulation image
######################################
FROM dev AS sim

# use global args
ARG ROS_DISTRO
ARG TIMEZONE
ARG USERNAME

USER root

ENV DEBIAN_FRONTEND=noninteractive

# Add simulation packages for both webots and gazebo
RUN apt-get update && apt-get install -y \
    vulcanexus-$ROS_DISTRO-simulation \
#    ros-$ROS_DISTRO-gazebo-ros \
#    ros-$ROS_DISTRO-gazebo-ros2-control \
  # install urdf to proto converter
  && pip install urdf2webots \
  # Cleanup
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/*

ENV LD_LIBRARY_PATH=/opt/ros/$ROS_DISTRO/lib/controller \
    TZ=$TIMEZONE \
    DEBIAN_FRONTEND=

# change startup user to ros
USER $USERNAME
WORKDIR /home/$USERNAME


######################################
# Full desktop image
######################################
FROM sim AS full

# use global args
ARG ROS_DISTRO
ARG TIMEZONE
ARG USERNAME

USER root

ENV DEBIAN_FRONTEND=noninteractive

# Add ros2/vulcanexus desktop packages
RUN apt-get update && apt-get install -y \
# needed?
#    xvfb \
    vulcanexus-$ROS_DISTRO-desktop \
  # Cleanup
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/*

ENV TZ=$TIMEZONE \
    DEBIAN_FRONTEND=

# change startup user to ros
USER $USERNAME
WORKDIR /home/$USERNAME
