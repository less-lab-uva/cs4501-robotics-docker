FROM ubuntu:18.04

# Set the work directory 
WORKDIR /root

# Minimal setup
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    lsb-release \
    locales \
    gnupg2

# Stop questions about geography
ARG DEBIAN_FRONTEND=noninteractive
RUN dpkg-reconfigure locales

# Prepare ROS installation
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

# Install ROS melodic
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ros-melodic-desktop-full

# Install additional packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ros-melodic-imu-filter-madgwick \
    ros-melodic-mav-msgs \
    libsdl-image1.2-dev \
    python-catkin-tools \
    python-tk \
    python-pip \
	git

# Setup ROS dep
RUN apt-get install -y --no-install-recommends python-rosdep
RUN rosdep init \
 && rosdep fix-permissions \
 && rosdep update

#Setup python\r alias
RUN ln /usr/bin/python $(printf "/usr/bin/python\r")

ARG USER_ID
ARG GROUP_ID
ARG USER_NAME

# Bridge user into Docker
RUN if [ ${USER_ID:-0} -ne 0 ] && [ ${GROUP_ID:-0} -ne 0 ]; then \
    userdel -f ${USER_NAME};\
    if getent group ${USER_NAME} ; then groupdel ${USER_NAME}; fi &&\
    groupadd -g ${GROUP_ID} ${USER_NAME} &&\
    useradd -l -u ${USER_ID} -g ${USER_NAME} ${USER_NAME} &&\
    install -d -m 0755 -o root -g ${USER_NAME} /${USER_NAME} \
;fi

USER ${USER_NAME:-root}

WORKDIR /home/${USER_NAME:-/../root}

# Source ROS
RUN echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc
