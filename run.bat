@echo off
REM Enter MoveIt 2 Docker Container

setlocal enabledelayedexpansion

echo ========================================
echo   Enter MoveIt 2 Container
echo ========================================
echo.

REM Check which container is running (including unhealthy state)
docker ps -a --filter "name=moveit2_container_gpu" --filter "status=running" --format "{{.Names}}" | findstr moveit2_container_gpu >nul 2>&1
if %errorlevel% equ 0 (
    set CONTAINER_NAME=moveit2_container_gpu
    echo [Info] GPU container is running
    goto connect
)

docker ps -a --filter "name=moveit2_container$" --filter "status=running" --format "{{.Names}}" | findstr moveit2_container >nul 2>&1
if %errorlevel% equ 0 (
    set CONTAINER_NAME=moveit2_container
    echo [Info] CPU container is running
    goto connect
)

echo [Error] No MoveIt container is running
echo [Tip] Please run start.bat first to start the container
pause
exit /b 1

:connect
echo [Info] Connecting to container: %CONTAINER_NAME%
echo.

docker exec -it %CONTAINER_NAME% bash