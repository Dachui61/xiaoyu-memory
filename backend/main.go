package main

import (
	"database/sql"
	"log"
	"net/http"
	"time"

	"xiaoyu-memory-backend/internal/handler"
	"xiaoyu-memory-backend/internal/repository"
	"xiaoyu-memory-backend/internal/service"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	_ "github.com/mattn/go-sqlite3"
)

func main() {
	// Open SQLite database
	db, err := sql.Open("sqlite3", "./xiaoyu_memory.db?_journal_mode=WAL&_busy_timeout=5000")
	if err != nil {
		log.Fatal("Failed to open database:", err)
	}
	defer db.Close()

	// Initialize repositories
	memoryRepo := repository.NewMemoryRepository(db)
	userRepo := repository.NewUserRepository(db)

	if err := memoryRepo.InitSchema(); err != nil {
		log.Fatal("Failed to init memory schema:", err)
	}
	if err := userRepo.InitSchema(); err != nil {
		log.Fatal("Failed to init user schema:", err)
	}

	// Initialize services
	memorySvc := service.NewMemoryService(memoryRepo)

	// Initialize handlers
	memoryHandler := handler.NewMemoryHandler(memorySvc)
	authHandler := handler.NewAuthHandler(userRepo)

	// Setup Gin
	r := gin.Default()

	r.Use(cors.New(cors.Config{
		AllowAllOrigins:  true,
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Authorization"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
		MaxAge:           12 * time.Hour,
	}))

	api := r.Group("/api")
	{
		api.GET("/health", memoryHandler.Health)
		api.GET("/", func(c *gin.Context) {
			c.JSON(http.StatusOK, gin.H{"message": "小宇记忆 Backend API", "version": "0.2"})
		})

		// Auth
		api.POST("/auth/register", authHandler.Register)
		api.POST("/auth/login", authHandler.Login)

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

	log.Println("小宇记忆 backend starting on :8080")
	r.Run(":8080")
}
