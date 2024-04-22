FROM osrf/ros:humble-desktop-full-jammy

ARG USERNAME=liosamuser
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Enable ability for ROS messages to be viewable from host 
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# install ros2 dependencies
RUN apt-get update \
    && apt-get install -y curl \
    && curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add - \
    && apt-get update \
    && apt install -y python3-colcon-common-extensions \
    && apt-get install -y ros-humble-navigation2 \
    && apt-get install -y ros-humble-robot-localization \
    && apt-get install -y ros-humble-robot-state-publisher \
    && apt install -y ros-humble-perception-pcl \
  	&& apt install -y ros-humble-pcl-msgs \
  	&& apt install -y ros-humble-vision-opencv \
  	&& apt install -y ros-humble-xacro \
    && apt-get install -y ros-humble-rosbag2-storage-mcap \
    && apt-get install -y ros-humble-nmea-msgs \
    && rm -rf /var/lib/apt/lists/*

# install gtsam (LIO-SAM dependency)
RUN apt-get update \
    && apt install -y software-properties-common \
    && add-apt-repository -y ppa:borglab/gtsam-release-4.1 \
    && apt-get update \
    && apt install -y libgtsam-dev libgtsam-unstable-dev \
    && rm -rf /var/lib/apt/lists/*

USER $USERNAME
SHELL ["/bin/bash", "-c"]

# clone and install LIO-SAM
RUN mkdir -p /home/$USERNAME/ros2_ws/src \
    && cd /home/$USERNAME/ros2_ws/src \
    && git clone --branch feature/ros2-thesis-mods https://github.com/aimas-lund/LIO-SAM \
    && cd .. \
    && source /opt/ros/humble/setup.bash \
    && colcon build

# add ros2 and LIO-SAM to bashrc
RUN echo "source /opt/ros/humble/setup.bash" >> /home/$USERNAME/.bashrc \
    && echo "source /home/$USERNAME/ros2_ws/install/setup.bash" >> /home/$USERNAME/.bashrc \
    && echo "export ROS_DOMAIN_ID=1" >> /home/$USERNAME/.bashrc

WORKDIR /home/$USERNAME/ros2_ws