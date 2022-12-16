# syntax=docker/dockerfile:1

# global configuration values
# wanted ros distro and corresponding ubuntu version
ARG ROS_DISTRO=humble
ARG UBUNTU_VERSION=22.04
# wanted language
ARG LANGUAGE=de_DE.UTF-8
# wanted timezone
ARG TIMEZONE="Europe/Berlin"
# non-root user "ros"
ARG USERNAME=ros
ARG USER_UID=1000
ARG USER_GID=$USER_UID

######################################
# Localized image
######################################
FROM ubuntu:$UBUNTU_VERSION AS localized

ARG LANGUAGE
ARG TIMEZONE

ENV DEBIAN_FRONTEND=noninteractive

# Install basic necessities
RUN apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y \
    apt-utils \
    locales \
    nano \
    tzdata \
    vim \
    xterm \
  && locale-gen $LANGUAGE \
  && update-locale LC_ALL=$LANGUAGE LANG=$LANGUAGE \
  && dpkg-reconfigure --frontend noninteractive tzdata \
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

######################################
# Runtime image
######################################
FROM localized AS run

# use global args
ARG ROS_DISTRO
ARG TIMEZONE
ARG USERNAME
ARG USER_UID
ARG USER_GID

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
    vulcanexus-$ROS_DISTRO-core \
    vulcanexus-$ROS_DISTRO-micro \
    vulcanexus-$ROS_DISTRO-cloud \
  # add non-root user as defined above
  && groupadd --gid $USER_GID $USERNAME \
  && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
  && echo "if [ -f /opt/vulcanexus/${ROS_DISTRO}/setup.bash ]; then source /opt/vulcanexus/${ROS_DISTRO}/setup.bash; fi" >> /home/$USERNAME/.bashrc \
  # Cleanup
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/*

# set environment for Vulcanexus/ROS2
ENV AMENT_PREFIX_PATH=/opt/vulcanexus/$ROS_DISTRO:/opt/ros/$ROS_DISTRO \
    CMAKE_PREFIX_PATH=/opt/vulcanexus/$ROS_DISTRO \
    COLCON_PREFIX_PATH=/opt/vulcanexus/$ROS_DISTRO \
    LD_LIBRARY_PATH=/opt/vulcanexus/$ROS_DISTRO/lib:/opt/ros/$ROS_DISTRO/opt/rviz_ogre_vendor/lib:/opt/ros/$ROS_DISTRO/lib/x86_64-linux-gnu:/opt/ros/$ROS_DISTRO/lib \
    PATH=/opt/vulcanexus/$ROS_DISTRO/bin:/opt/ros/$ROS_DISTRO/bin:$PATH \
    PKG_CONFIG_PATH=/opt/vulcanexus/$ROS_DISTRO/lib/x86_64-linux-gnu/pkgconfig:/opt/vulcanexus/$ROS_DISTRO/lib/pkgconfig \
    PYTHONPATH=/opt/vulcanexus/$ROS_DISTRO/local/lib/python3.10/dist-packages:/opt/vulcanexus/$ROS_DISTRO/lib/python3.10/site-packages:/opt/ros/$ROS_DISTRO/lib/python3.10/site-packages:/opt/ros/$ROS_DISTRO/local/lib/python3.10/dist-packages \
    RMW_IMPLEMENTATION=rmw_fastrtps_cpp \
    ROS_DISTRO=$ROS_DISTRO \
    ROS_LOCALHOST_ONLY=0 \
    ROS_PYTHON_VERSION=3 \
    ROS_VERSION=2 \
    VULCANEXUS_DISTRO=$ROS_DISTRO \
    VULCANEXUS_HOME=/opt/vulcanexus/$ROS_DISTRO \
    TZ=$TIMEZONE \
    DEBIAN_FRONTEND=dialog

# change startup user to ros
CMD su ros


######################################
# Developer image
######################################
FROM run AS dev

# use global args
#ARG ROS_DISTRO
ARG TIMEZONE
ARG USERNAME

ENV DEBIAN_FRONTEND=noninteractive

# Add development packages
RUN apt-get update \
  && apt-get install -y \
    ros-dev-tools \
    bash-completion \
    gdb \
    git \
    pylint \
    python3-autopep8 \
    python3-colcon-common-extensions \
    python3-rosdep \
    python3-vcstool \
    sudo \
    wget \
    vulcanexus-$ROS_DISTRO-tools \
  && rosdep init || echo "rosdep already initialized" \
  # Update pydocstyle
  && pip install --upgrade pydocstyle \
  # Add sudo support for the non-root user
  && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME\
  && chmod 0440 /etc/sudoers.d/$USERNAME \
  && echo "source /usr/share/bash-completion/completions/git" >> /home/$USERNAME/.bashrc \
  # Cleanup
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/*

ENV AMENT_CPPCHECK_ALLOW_SLOW_VERSIONS=1 \
    TZ=$TIMEZONE \
    DEBIAN_FRONTEND=dialog

######################################
# Full desktop image
######################################
FROM dev AS full

# use global args
ARG ROS_DISTRO
ARG TIMEZONE

ENV DEBIAN_FRONTEND=noninteractive

# Add development packages
RUN apt-get update \
  && apt-get install -y \
    vulcanexus-$ROS_DISTRO-desktop \
  # Cleanup
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/*

ENV TZ=$TIMEZONE \
    DEBIAN_FRONTEND=dialog
