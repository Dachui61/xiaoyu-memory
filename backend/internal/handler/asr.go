package handler

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"

	"xiaoyu-memory-backend/pkg/ai"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type ASRHandler struct {
	asr *ai.ASR
}

func NewASRHandler() *ASRHandler {
	return &ASRHandler{asr: ai.NewASR()}
}

func (h *ASRHandler) Transcribe(c *gin.Context) {
	file, header, err := c.Request.FormFile("audio")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "no audio file provided"})
		return
	}
	defer file.Close()

	// Save to temp file
	ext := filepath.Ext(header.Filename)
	if ext == "" {
		ext = ".m4a"
	}
	tmpPath := filepath.Join(os.TempDir(), fmt.Sprintf("asr_%s%s", uuid.New().String(), ext))
	out, err := os.Create(tmpPath)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to save temp file"})
		return
	}
	defer os.Remove(tmpPath)

	if _, err := io.Copy(out, file); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to write temp file"})
		return
	}
	out.Close()

	// Transcribe
	text, err := h.asr.Transcribe(tmpPath)
	if err != nil {
		c.JSON(http.StatusOK, gin.H{"text": "", "error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"text": text})
}
