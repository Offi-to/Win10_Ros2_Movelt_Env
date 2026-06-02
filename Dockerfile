# MoveIt 2 Docker Image for Windows 10/11
# Based on: https://moveit.picknik.ai/main/doc/how_to_guides/how_to_setup_docker_containers_in_ubuntu.html
# ROS2 Jazzy with MoveIt 2 and development tools

# 使用官方ROS2 Jazzy基础镜像（与MoveIt官方推荐一致）
FROM ros:jazzy

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# 设置工作目录
WORKDIR /root/ros2_ws

# ============================================================================
# 第一步：安装系统基础工具和Python开发工具
# ============================================================================
RUN apt-get update && apt-get install -y --fix-missing --no-install-recommends \
    curl \
    wget \
    git \
    vim \
    nano \
    htop \
    net-tools \
    iputils-ping \
    bash-completion \
    python3-pip \
    build-essential \
    cmake \
    libboost-all-dev \
    && rm -rf /var/lib/apt/lists/*

# ============================================================================
# 第二步：安装Python工具(colcon, rosdep等)
# ============================================================================
RUN pip3 install --no-cache-dir --break-system-packages \
    colcon-common-extensions \
    rosdep \
    vcstool

# ============================================================================
# 第三步：初始化rosdep(只在未初始化时执行)
# ============================================================================
RUN if [ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]; then \
        rosdep init; \
    fi && \
    rosdep update || echo "rosdep update failed but continuing..."

# ============================================================================
# 第四步：安装MoveIt2核心包及相关依赖
# 参考: https://moveit.picknik.ai/ 和 CSDN教程
# 使用通配符安装所有moveit相关包，确保完整性
# 同时安装常用的可视化和URDF工具
# ============================================================================
RUN apt-get update && apt-get install -y --fix-missing --no-install-recommends \
    ros-jazzy-moveit \
    ros-jazzy-moveit-* \
    ros-jazzy-rviz2 \
    ros-jazzy-rqt \
    ros-jazzy-rqt-common-plugins \
    ros-jazzy-urdf \
    ros-jazzy-robot-state-publisher \
    ros-jazzy-joint-state-publisher \
    ros-jazzy-joint-state-publisher-gui \
    ros-jazzy-xacro \
    && rm -rf /var/lib/apt/lists/*

# ============================================================================
# 第七步：安装Navigation2导航栈（可选但推荐）
# ============================================================================
RUN apt-get update && apt-get install -y --fix-missing --no-install-recommends \
    ros-jazzy-navigation2 \
    ros-jazzy-nav2-bringup \
    ros-jazzy-slam-toolbox \
    && rm -rf /var/lib/apt/lists/*

# ============================================================================
# 第八步：安装常用消息包和图形库
# ============================================================================
RUN apt-get update && apt-get install -y --fix-missing --no-install-recommends \
    ros-jazzy-turtlebot3-msgs \
    ros-jazzy-geometry-msgs \
    ros-jazzy-sensor-msgs \
    ros-jazzy-nav-msgs \
    # OpenGL和X11支持
    libgl1-mesa-dri \
    libglx-mesa0 \
    libglu1-mesa \
    libxext6 \
    libx11-6 \
    libxcb1 \
    libxrender1 \
    libxi6 \
    && rm -rf /var/lib/apt/lists/*

# ============================================================================
# 第九步：配置ROS2环境
# ============================================================================
RUN echo "source /opt/ros/jazzy/setup.bash" >> /root/.bashrc && \
    echo "export ROS_DOMAIN_ID=0" >> /root/.bashrc && \
    echo "export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp" >> /root/.bashrc && \
    echo "export TURTLEBOT3_MODEL=waffle" >> /root/.bashrc && \
    echo "alias ll='ls -la'" >> /root/.bashrc && \
    echo "alias cw='cd ~/ros2_ws'" >> /root/.bashrc && \
    echo "alias cs='cd ~/ros2_ws/src'" >> /root/.bashrc && \
    echo "alias cb='cd ~/ros2_ws && colcon build'" >> /root/.bashrc && \
    echo "alias cbs='cd ~/ros2_ws && colcon build && source install/setup.bash'" >> /root/.bashrc

# ============================================================================
# 第十步：创建工作空间并初始化
# ============================================================================
RUN mkdir -p /root/ros2_ws/src

# ============================================================================
# 第十一步：克隆并构建MoveIt 2教程
# ============================================================================
#RUN cd /root/ros2_ws/src && \
#    git clone https://github.com/moveit/moveit2_tutorials.git -b jazzy && \
#    cd /root/ros2_ws && \
#    . /opt/ros/jazzy/setup.bash && \
#    rosdep install -y --from-paths src --ignore-src --rosdistro jazzy && \
#    colcon build --symlink-install && \
#    echo "source /root/ros2_ws/install/setup.bash" >> /root/.bashrc

# 注意: 不设置ENTRYPOINT,让docker-compose的command生效
