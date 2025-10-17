package handlers

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
)

// HelloResponse 定义响应结构
type HelloResponse struct {
	Message   string    `json:"message"`
	Timestamp time.Time `json:"timestamp"`
}

// HelloHandler 处理 /api/hello 请求
func HelloHandler(c *gin.Context) {
	response := HelloResponse{
		Message:   "你好，欢迎使用Gin框架! 2025 10 17 19:00",
		Timestamp: time.Now(),
	}

	c.JSON(http.StatusOK, response)
}
