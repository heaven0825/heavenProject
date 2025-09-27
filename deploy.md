# 阿里云轻量服务器Docker部署指南

本文档提供在阿里云轻量服务器上使用Docker部署Go Gin应用的步骤。

## 前提条件

1. 已购买阿里云轻量应用服务器
2. 已开通8080端口（或者你想使用的其他端口）
3. 已安装Docker和Docker Compose

## 安装Docker和Docker Compose（如果尚未安装）

连接到你的阿里云轻量服务器后，执行以下命令安装Docker：

```bash
# 更新包索引
sudo apt-get update

# 安装必要的依赖
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

# 添加Docker官方GPG密钥
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# 设置稳定版仓库
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 安装Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# 安装Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 验证安装
docker --version
docker-compose --version

# 将当前用户添加到docker组（可选，避免每次都需要sudo）
sudo usermod -aG docker $USER
# 注意：添加用户到组后需要重新登录才能生效
```

## 部署应用

1. 将项目文件上传到服务器：

```bash
# 在本地执行，将项目文件打包
tar -czvf gin-app.tar.gz ./*

# 使用scp上传到服务器
scp gin-app.tar.gz username@your-server-ip:/path/to/destination/

# 在服务器上解压
ssh username@your-server-ip
cd /path/to/destination/
tar -xzvf gin-app.tar.gz
```

2. 构建并启动Docker容器：

```bash
# 构建并在后台启动容器
docker-compose up -d --build

# 查看容器状态
docker-compose ps

# 查看应用日志
docker-compose logs -f
```

3. 验证部署：

在浏览器中访问 `http://your-server-ip:8080/api/hello` 检查API是否正常工作。

## 管理应用

```bash
# 停止应用
docker-compose down

# 重启应用
docker-compose restart

# 查看日志
docker-compose logs -f
```

## 配置Nginx反向代理（可选）

如果你想使用域名访问应用或配置HTTPS，可以安装Nginx作为反向代理：

```bash
# 安装Nginx
sudo apt-get install -y nginx

# 创建Nginx配置文件
sudo nano /etc/nginx/sites-available/gin-app

# 添加以下配置
server {
    listen 80;
    server_name your-domain.com;  # 替换为你的域名

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# 创建符号链接启用配置
sudo ln -s /etc/nginx/sites-available/gin-app /etc/nginx/sites-enabled/

# 测试Nginx配置
sudo nginx -t

# 重启Nginx
sudo systemctl restart nginx
```

## 配置HTTPS（可选）

使用Let's Encrypt免费SSL证书：

```bash
# 安装Certbot
sudo apt-get install -y certbot python3-certbot-nginx

# 获取并配置SSL证书
sudo certbot --nginx -d your-domain.com

# 证书自动续期
sudo certbot renew --dry-run
```

## 故障排除

1. 如果应用无法访问，检查防火墙设置：
```bash
sudo ufw status
sudo ufw allow 8080/tcp
```

2. 检查Docker容器状态：
```bash
docker ps
docker logs gin-app
```

3. 检查应用日志：
```bash
docker-compose logs -f