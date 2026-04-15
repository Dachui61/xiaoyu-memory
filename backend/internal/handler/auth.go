package handler

import (
	"net/http"
	"time"

	"xiaoyu-memory-backend/internal/repository"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
)

type AuthHandler struct {
	userRepo *repository.UserRepository
}

func NewAuthHandler(userRepo *repository.UserRepository) *AuthHandler {
	return &AuthHandler{userRepo: userRepo}
}

func (h *AuthHandler) Register(c *gin.Context) {
	var req struct {
		Phone    string `json:"phone"`
		Password string `json:"password"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid request"})
		return
	}

	if req.Phone == "" || req.Password == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "phone and password required"})
		return
	}

	hash, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to hash password"})
		return
	}

	userID := uuid.New().String()
	if err := h.userRepo.Create(userID, req.Phone, string(hash)); err != nil {
		c.JSON(http.StatusConflict, gin.H{"error": "phone already registered"})
		return
	}

	token := uuid.New().String()
	c.JSON(http.StatusCreated, gin.H{
		"user": gin.H{
			"id":    userID,
			"phone": req.Phone,
		},
		"token": token,
	})
}

func (h *AuthHandler) Login(c *gin.Context) {
	var req struct {
		Phone    string `json:"phone"`
		Password string `json:"password"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid request"})
		return
	}

	userID, hash, ok, err := h.userRepo.GetByPhone(req.Phone)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "database error"})
		return
	}
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid phone or password"})
		return
	}

	if err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(req.Password)); err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid phone or password"})
		return
	}

	token := uuid.New().String()
	c.JSON(http.StatusOK, gin.H{
		"user": gin.H{
			"id":    userID,
			"phone": req.Phone,
		},
		"token":     token,
		"expires_at": time.Now().Add(7 * 24 * time.Hour).Unix(),
	})
}
