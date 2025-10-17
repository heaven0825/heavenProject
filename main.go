package main

import (
	"fmt"
	"heavenProject/handlers"
	"log"

	"github.com/gin-gonic/gin"
)

func main() {
	// 创建默认的gin路由
	router := gin.Default()

	// 定义API路由组1
	api := router.Group("/api")
	{
		// 注册一个GET请求处理函数
		api.GET("/hello", handlers.HelloHandler)
	}

	// 定义根路由
	router.GET("/", func(c *gin.Context) {
		c.String(200, "欢迎访问Gin服务器! 请尝试访问 /api/hello 接口")
	})

	// 启动服务器在8080端口
	port := 8080
	fmt.Printf("服务器启动在 http://localhost:%d\n", port)
	fmt.Printf("可以访问的API接口: http://localhost:%d/api/hello\n", port)

	if err := router.Run(fmt.Sprintf(":%d", port)); err != nil {
		log.Fatalf("启动服务器失败: %v", err)
	}
}
