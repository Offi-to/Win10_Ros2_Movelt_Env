win10系统ros2使用指南

#========================================================================================
镜像名字
ros2-jazzy-win10
容器名字
moveit2_container
#========================================================================================

查看所有本地镜像
docker images

查看运行容器
docker ps

停止容器
docker-compose down

查看当前容器状态
docker ps -a --filter "name=moveit2_container" --format "{{.Names}} {{.Status}}"

如果已经创建了容器，直接在容器中启动docker；如果没有创建过容器，则创建容器并启动docker，可能会多次失败，但是反复执行docker-compose up -d cpu可以继续下载
docker-compose up -d cpu

启动代码
.\run.bat

启动示例代码
# Panda机械臂
docker exec -it moveit2_container bash -c "source /opt/ros/jazzy/setup.bash && unset RMW_IMPLEMENTATION && ros2 launch moveit_resources_panda_moveit_config demo.launch.py"

# Fanuc M-10iA机械臂
docker exec -it moveit2_container bash -c "source /opt/ros/jazzy/setup.bash && unset RMW_IMPLEMENTATION && ros2 launch moveit_resources_fanuc_moveit_config demo.launch.py"