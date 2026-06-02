#!/bin/bash
# ROS2 Jazzy Docker 启动脚本

set -e

echo "========================================"
echo "  ROS2 Jazzy 启动程序"
echo "========================================"
echo ""

# 检查Docker
if ! docker info > /dev/null 2>&1; then
    echo "[错误] Docker未运行，请先启动Docker Desktop"
    exit 1
fi

# 创建工作空间目录
if [ ! -d "ros2_ws/src" ]; then
    echo "[提示] 创建工作空间目录..."
    mkdir -p ros2_ws/src
fi

echo "[1/3] 启动容器..."
docker-compose up -d

echo "[2/3] 等待容器就绪..."
sleep 3

echo "[3/3] 检查容器状态..."
if docker ps | grep -q ros2-jazzy; then
    echo ""
    echo "========================================"
    echo "  启动成功！"
    echo "========================================"
    echo ""
    echo "进入容器: ./run.sh"
    echo "停止容器: docker-compose down"
    echo ""
else
    echo "[错误] 容器未正常运行"
    docker-compose logs
    exit 1
fi
