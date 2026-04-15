package handler

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
)

var jwtSecret = []byte("xiaoyu-memory-secret-key")

type AuthHandler struct{}

func NewAuthHandler() *AuthHandler {
	return &AuthHandler{}
}

func (h *AuthHandler) RegisterRoutes(r *gin.Engine) {
	api := r.Group("/api")
	api.POST("/auth/register", h.register)
	api.POST("/auth/login", h.login)
}

type AuthRequest struct {
	Phone    string `json:"phone"`
	Password string `json:"password"`
	Name     string `json:"name"`
}

type AuthResponse struct {
	Token string `json:"token"`
	User  User   `json:"user"`
}

type User struct {
	ID    string `json:"id"`
	Phone string `json:"phone"`
	Name  string `json:"name"`
}

func (h *AuthHandler) register(c *gin.Context) {
	var req AuthRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	token, _ := generateToken(req.Phone)
	c.JSON(http.StatusCreated, gin.H{
		"token": token,
		"user": User{
			ID:    "u1",
			Phone: req.Phone,
			Name:  req.Name,
		},
	})
}

func (h *AuthHandler) login(c *gin.Context) {
	var req AuthRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	token, _ := generateToken(req.Phone)
	c.JSON(http.StatusOK, gin.H{
		"token": token,
		"user": User{
			ID:    "u1",
			Phone: req.Phone,
			Name:  "",
		},
	})
}

func generateToken(phone string) (string, error) {
	claims := jwt.MapClaims{
		"phone": phone,
		"exp":   time.Now().Add(7 * 24 * time.Hour).Unix(),
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(jwtSecret)
}
