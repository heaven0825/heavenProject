#!/bin/bash
set -e  # 脚本执行出错时立即退出（避免后续步骤异常执行）

# -------------------------- 需修改的参数 --------------------------
GITHUB_REPO="git@github.com:heaven0825/heavenProject.git"  # GitHub 仓库 SSH 地址
PROJECT_DIR="/path/to/heavenyi"  # 服务器项目目录
DOCKER_IMAGE_NAME="heavenyi-test"  # Docker 镜像名（自定义）
DOCKER_CONTAINER_NAME="heavenyi-test"  # Docker 容器名（自定义）
# -------------------------------------------------------------------

echo "===== 1. 进入项目目录 ====="
cd $PROJECT_DIR

echo "===== 2. 拉取最新代码 ====="
git pull origin main  # 若主分支是 master，替换为 git pull origin master

echo "===== 3. 构建 Docker 镜像 ====="
# 注意：需在项目根目录有 Dockerfile（参考 3.3 节）
docker build -t $DOCKER_IMAGE_NAME:latest .

echo "===== 4. 停止并删除旧容器 ====="
# 若容器存在，先停止再删除（避免端口占用）
if [ $(docker ps -a | grep -c $DOCKER_CONTAINER_NAME) -ge 1 ]; then
  docker stop $DOCKER_CONTAINER_NAME
  docker rm $DOCKER_CONTAINER_NAME
  echo "旧容器已删除"
fi

echo "===== 5. 启动新容器 ====="
# -d：后台运行；-p 80:8080：端口映射（服务器80端口→容器8080端口，根据项目调整）
# --name：指定容器名；--restart=always：服务器重启后容器自动启动
docker run -d -p 8080:8080 --name $DOCKER_CONTAINER_NAME --restart=always $DOCKER_IMAGE_NAME:latest

echo "===== 部署完成！ ====="
docker ps | grep $DOCKER_CONTAINER_NAME  # 显示容器运行状态