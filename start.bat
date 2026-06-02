@echo off
REM MoveIt 2 Docker Startup Script for Windows 10/11

setlocal enabledelayedexpansion

echo ========================================
echo   MoveIt 2 Docker Startup (ROS2 Jazzy)
echo ========================================
echo.

REM Check parameters
if "%~1"=="" (
    echo [Info] No service type specified, using CPU mode by default
    set SERVICE=cpu
) else (
    set SERVICE=%~1
)

REM Validate service type
if /i "%SERVICE%"=="cpu" goto valid_service
if /i "%SERVICE%"=="gpu" goto valid_service

echo [Error] Invalid service type: %SERVICE%
echo [Usage] start.bat [cpu^|gpu]
echo   cpu - CPU mode only ^(no GPU required^)
echo   gpu - GPU accelerated mode ^(requires NVIDIA GPU^)
pause
exit /b 1

:valid_service
REM Normalize to lowercase
set SERVICE=%SERVICE: =%

REM Check Docker
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo [Error] Docker is not running, please start Docker Desktop first
    pause
    exit /b 1
)

REM Create workspace directory
if not exist "ros2_ws\src" (
    echo [Info] Creating workspace directory...
    mkdir ros2_ws\src
)

REM Set environment variables
set DOCKER_IMAGE=jazzy-tutorial-source

echo [Config] Service mode: %SERVICE%
echo [Config] Docker image tag: %DOCKER_IMAGE%
echo.

echo [Info] Please make sure X Server (VcXsrv or Xming) is installed and running
echo [Info] See GUI_SETUP.md for X Server configuration details
echo.

echo [1/4] Building Docker image (first run may take a while)...
docker-compose build

if %errorlevel% neq 0 (
    echo [Error] Docker image build failed
    pause
    exit /b 1
)

echo.
echo [2/4] Starting container (%SERVICE% mode)...
docker-compose up -d %SERVICE%

if %errorlevel% neq 0 (
    echo [Error] Container startup failed
    docker-compose logs %SERVICE%
    pause
    exit /b 1
)

echo [3/4] Waiting for container to be ready...
timeout /t 5 /nobreak >nul

echo [4/4] Checking container status...
docker ps --filter "name=moveit2_container" --filter "status=running" --format "{{.Names}}" | findstr moveit2_container >nul 2>&1
if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo   Startup Successful!
    echo ========================================
    echo.
    echo Enter container: run.bat
    echo Stop container: docker-compose down
    echo View logs: docker-compose logs -f %SERVICE%
    echo.
    echo [Tips] Try these commands in the container:
    echo   ros2 launch moveit2_tutorials demo.launch.py
    echo   ros2 run rviz2 rviz2
    echo.
) else (
    echo [Error] Container is not running properly
    docker-compose logs %SERVICE%
)

pause