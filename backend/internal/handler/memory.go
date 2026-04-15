package handler

import (
	"net/http"
	"xiaoyu-memory-backend/internal/model"
	"xiaoyu-memory-backend/internal/service"

	"github.com/gin-gonic/gin"
)

type MemoryHandler struct {
	svc *service.MemoryService
}

func NewMemoryHandler(svc *service.MemoryService) *MemoryHandler {
	return &MemoryHandler{svc: svc}
}

func (h *MemoryHandler) RegisterRoutes(r *gin.Engine) {
	api := r.Group("/api")
	api.GET("/health", h.health)
	api.GET("/memories", h.list)
	api.POST("/memories", h.create)
	api.GET("/memories/:id", h.get)
	api.PUT("/memories/:id", h.update)
	api.DELETE("/memories/:id", h.delete)
	api.POST("/memories/:id/summarize", h.summarize)
}

func (h *MemoryHandler) health(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"status": "ok"})
}

func (h *MemoryHandler) list(c *gin.Context) {
	memories := h.svc.List()
	c.JSON(http.StatusOK, gin.H{"memories": memories})
}

func (h *MemoryHandler) create(c *gin.Context) {
	var m model.Memory
	if err := c.ShouldBindJSON(&m); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	created := h.svc.Create(m)
	c.JSON(http.StatusCreated, gin.H{"memory": created})
}

func (h *MemoryHandler) get(c *gin.Context) {
	id := c.Param("id")
	m, ok := h.svc.Get(id)
	if !ok {
		c.JSON(http.StatusNotFound, gin.H{"error": "memory not found"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"memory": m})
}

func (h *MemoryHandler) update(c *gin.Context) {
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

func (h *MemoryHandler) delete(c *gin.Context) {
	id := c.Param("id")
	if !h.svc.Delete(id) {
		c.JSON(http.StatusNotFound, gin.H{"error": "memory not found"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "deleted"})
}

func (h *MemoryHandler) summarize(c *gin.Context) {
	id := c.Param("id")
	summary, ok := h.svc.Summarize(id)
	if !ok {
		c.JSON(http.StatusNotFound, gin.H{"error": "memory not found"})
		return
	}
	m, _ := h.svc.Get(id)
	c.JSON(http.StatusOK, gin.H{"summary": summary, "memory": m})
}
