package handler

import (
	"net/http"
	"strings"

	"xiaoyu-memory-backend/internal/model"
	"xiaoyu-memory-backend/internal/service"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type MemoryHandler struct {
	svc *service.MemoryService
}

func NewMemoryHandler(svc *service.MemoryService) *MemoryHandler {
	return &MemoryHandler{svc: svc}
}

func (h *MemoryHandler) Health(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"status": "ok"})
}

// Auth
func (h *MemoryHandler) AuthRegister(c *gin.Context) {
	var req struct {
		Phone    string `json:"phone"`
		Password string `json:"password"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid request"})
		return
	}
	c.JSON(http.StatusOK, gin.H{
		"user": gin.H{
			"id":    uuid.New().String(),
			"phone": req.Phone,
		},
		"token": uuid.New().String(),
	})
}

func (h *MemoryHandler) AuthLogin(c *gin.Context) {
	var req struct {
		Phone    string `json:"phone"`
		Password string `json:"password"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid request"})
		return
	}
	c.JSON(http.StatusOK, gin.H{
		"user": gin.H{
			"id":    uuid.New().String(),
			"phone": req.Phone,
		},
		"token": uuid.New().String(),
	})
}

// Memories
func (h *MemoryHandler) List(c *gin.Context) {
	memories := h.svc.List()
	c.JSON(http.StatusOK, gin.H{"memories": memories})
}

func (h *MemoryHandler) Create(c *gin.Context) {
	var m model.Memory
	if err := c.ShouldBindJSON(&m); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	created := h.svc.Create(m)
	c.JSON(http.StatusCreated, gin.H{"memory": created})
}

func (h *MemoryHandler) Get(c *gin.Context) {
	id := c.Param("id")
	m, ok := h.svc.Get(id)
	if !ok {
		c.JSON(http.StatusNotFound, gin.H{"error": "memory not found"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"memory": m})
}

func (h *MemoryHandler) Update(c *gin.Context) {
	id := c.Param("id")
	var updates map[string]interface{}
	if err := c.ShouldBindJSON(&updates); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	m, ok := h.svc.Update(id, updates)
	if !ok {
		c.JSON(http.StatusNotFound, gin.H{"error": "memory not found"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"memory": m})
}

func (h *MemoryHandler) Delete(c *gin.Context) {
	id := c.Param("id")
	if !h.svc.Delete(id) {
		c.JSON(http.StatusNotFound, gin.H{"error": "memory not found"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "deleted"})
}

func (h *MemoryHandler) Summarize(c *gin.Context) {
	id := c.Param("id")
	m, ok := h.svc.Summarize(id)
	if !ok {
		c.JSON(http.StatusNotFound, gin.H{"error": "memory not found"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"memory": m})
}

// AI Chat
func (h *MemoryHandler) Chat(c *gin.Context) {
	var req struct {
		Message  string `json:"message"`
		History  string `json:"history"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid request"})
		return
	}

	reply, err := h.svc.Chat(req.Message, req.History)
	if err != nil {
		c.JSON(http.StatusOK, gin.H{"reply": "抱歉，AI 服务暂时不可用。请稍后重试。"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"reply": reply})
}

// Search
func (h *MemoryHandler) Search(c *gin.Context) {
	q := strings.ToLower(c.Query("q"))
	if q == "" {
		c.JSON(http.StatusOK, gin.H{"results": []model.Memory{}})
		return
	}

	all := h.svc.List()
	var results []model.Memory
	for _, m := range all {
		if strings.Contains(strings.ToLower(m.Content), q) ||
			strings.Contains(strings.ToLower(m.Title), q) ||
			containsAnyTag(m.Tags, q) {
			results = append(results, m)
		}
	}
	c.JSON(http.StatusOK, gin.H{"results": results})
}

func containsAnyTag(tags []string, q string) bool {
	for _, t := range tags {
		if strings.Contains(strings.ToLower(t), q) {
			return true
		}
	}
	return false
}
