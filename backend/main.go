package main

import (
	"net/http"
	"time"

	"xiaoyu-memory-backend/internal/handler"
	"xiaoyu-memory-backend/internal/service"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

func main() {
	r := gin.Default()

	r.Use(cors.New(cors.Config{
		AllowAllOrigins:  true,
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Authorization"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
		MaxAge:           12 * time.Hour,
	}))

	// Initialize services
	memorySvc := service.NewMemoryService()

	// Initialize handlers
	memoryHandler := handler.NewMemoryHandler(memorySvc)

	// Register routes
	api := r.Group("/api")
	{
		api.GET("/health", memoryHandler.Health)

		// Auth
		api.POST("/auth/register", memoryHandler.AuthRegister)
		api.POST("/auth/login", memoryHandler.AuthLogin)

		// Memories
		api.GET("/memories", memoryHandler.List)
		api.POST("/memories", memoryHandler.Create)
		api.GET("/memories/:id", memoryHandler.Get)
		api.PUT("/memories/:id", memoryHandler.Update)
		api.DELETE("/memories/:id", memoryHandler.Delete)
		api.POST("/memories/:id/summarize", memoryHandler.Summarize)

		// AI Chat
		api.POST("/chat", memoryHandler.Chat)

		// Search
		api.GET("/search", memoryHandler.Search)
	}

	r.GET("/", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"message": "小宇记忆 Backend API", "version": "0.1"})
	})

	r.Run(":8080")
}
