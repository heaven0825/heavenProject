FROM golang:1.21-alpine AS builder

# 设置工作目录
WORKDIR /app

# 复制go.mod和go.sum文件
COPY go.mod go.sum ./

# 设置国内代理并下载依赖
ENV GOPROXY=https://goproxy.cn,direct
RUN go mod download

# 复制源代码
COPY . .

# 编译应用
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o gin-app .

# 使用轻量级的alpine镜像
FROM alpine:latest

# 安装基本工具
RUN apk --no-cache add ca-certificates tzdata

# 设置时区为中国时区
ENV TZ=Asia/Shanghai

WORKDIR /root/

# 从builder阶段复制编译好的应用
COPY --from=builder /app/gin-app .

# 暴露8080端口
EXPOSE 8080

# 运行应用
CMD ["./gin-app"]