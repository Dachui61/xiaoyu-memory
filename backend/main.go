package main

import (
	"net/http"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type Memory struct {
	ID        string    `json:"id"`
	Title     string    `json:"title"`
	Content   string    `json:"content"`
	Tags      []string  `json:"tags"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

var memories = make(map[string]Memory)

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

	// Auth routes
	r.POST("/api/auth/register", register)
	r.POST("/api/auth/login", login)

	// Memory routes
	r.GET("/api/memories", getMemories)
	r.POST("/api/memories", createMemory)
	r.GET("/api/memories/:id", getMemory)
	r.PUT("/api/memories/:id", updateMemory)
	r.DELETE("/api/memories/:id", deleteMemory)
	r.POST("/api/memories/:id/summarize", summarizeMemory)

	// AI routes
	r.POST("/api/chat", chat)
	r.GET("/api/search", search)

	// Health
	r.GET("/api/health", health)

	r.Run(":8080")
}

func health(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"status": "ok"})
}

func register(c *gin.Context) {
	var req struct {
		Username string `json:"username"`
		Email    string `json:"email"`
		Password string `json:"password"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid request"})
		return
	}
	c.JSON(http.StatusOK, gin.H{
		"user": gin.H{
			"id":       uuid.New().String(),
			"username": req.Username,
			"email":    req.Email,
		},
		"token": uuid.New().String(),
	})
}

func login(c *gin.Context) {
	var req struct {
		Email    string `json:"email"`
		Password string `json:"password"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid request"})
		return
	}
	c.JSON(http.StatusOK, gin.H{
		"token": uuid.New().String(),
	})
}

func getMemories(c *gin.Context) {
	list := make([]Memory, 0, len(memories))
	for _, m := range memories {
		list = append(list, m)
	}
	c.JSON(http.StatusOK, list)
}

func createMemory(c *gin.Context) {
	var req struct {
		Title   string   `json:"title"`
		Content string   `json:"content"`
		Tags    []string `json:"tags"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid request"})
		return
	}
	m := Memory{
		ID:        uuid.New().String(),
		Title:     req.Title,
		Content:   req.Content,
		Tags:      req.Tags,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}
	memories[m.ID] = m
	c.JSON(http.StatusCreated, m)
}

func getMemory(c *gin.Context) {
	id := c.Param("id")
	m, ok := memories[id]
	if !ok {
		c.JSON(http.StatusNotFound, gin.H{"error": "memory not found"})
		return
	}
	c.JSON(http.StatusOK, m)
}

func updateMemory(c *gin.Context) {
	id := c.Param("id")
	m, ok := memories[id]
	if !ok {
		c.JSON(http.StatusNotFound, gin.H{"error": "memory not found"})
		return
	}
	var req struct {
		Title   string   `json:"title"`
		Content string   `json:"content"`
		Tags    []string `json:"tags"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid request"})
		return
	}
	m.Title = req.Title
	m.Content = req.Content
	m.Tags = req.Tags
	m.UpdatedAt = time.Now()
	memories[id] = m
	c.JSON(http.StatusOK, m)
}

func deleteMemory(c *gin.Context) {
	id := c.Param("id")
	if _, ok := memories[id]; !ok {
		c.JSON(http.StatusNotFound, gin.H{"error": "memory not found"})
		return
	}
	delete(memories, id)
	c.JSON(http.StatusOK, gin.H{"message": "deleted"})
}

func summarizeMemory(c *gin.Context) {
	id := c.Param("id")
	if _, ok := memories[id]; !ok {
		c.JSON(http.StatusNotFound, gin.H{"error": "memory not found"})
		return
	}
	c.JSON(http.StatusOK, gin.H{
		"summary": "This is a mock AI summary of the memory content.",
	})
}

func chat(c *gin.Context) {
	var req struct {
		Message string `json:"message"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid request"})
		return
	}
	c.JSON(http.StatusOK, gin.H{
		"response": "This is a mock AI response to: " + req.Message,
	})
}

func search(c *gin.Context) {
	q := c.Query("q")
	c.JSON(http.StatusOK, gin.H{
		"query": q,
		"results": []Memory{
			{
				ID:        uuid.New().String(),
				Title:     "Sample memory matching: " + q,
				Content:   "This is a sample memory for search results.",
				Tags:      []string{"sample"},
				CreatedAt: time.Now(),
				UpdatedAt: time.Now(),
			},
		},
	})
}
