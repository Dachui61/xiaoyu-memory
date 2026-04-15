package ai

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"mime/multipart"
	"net/http"
	"os"
	"path/filepath"
	"time"
)

type ASR struct {
	apiKey string
}

func NewASR() *ASR {
	apiKey := os.Getenv("MINIMAX_API_KEY")
	if apiKey == "" {
		apiKey = "YOUR_MINIMAX_API_KEY"
	}
	return &ASR{apiKey: apiKey}
}

// Transcribe converts audio file to text using MiniMax API
func (a *ASR) Transcribe(audioFilePath string) (string, error) {
	groupID := os.Getenv("MINIMAX_GROUP_ID")
	if groupID == "" {
		return "", fmt.Errorf("MINIMAX_GROUP_ID not set")
	}

	url := fmt.Sprintf("https://api.minimax.io/v1/asr?GroupId=%s", groupID)

	// Read audio file
	audioData, err := os.ReadFile(audioFilePath)
	if err != nil {
		return "", fmt.Errorf("failed to read audio file: %w", err)
	}

	// Create multipart form
	body := &bytes.Buffer{}
	writer := multipart.NewWriter(body)

	// Add model param
	_ = writer.WriteField("model", "speech-01")

	// Add audio file
	part, err := writer.CreateFormFile("file", filepath.Base(audioFilePath))
	if err != nil {
		return "", fmt.Errorf("failed to create form file: %w", err)
	}
	part.Write(audioData)
	writer.Close()

	req, err := http.NewRequest("POST", url, body)
	if err != nil {
		return "", err
	}
	req.Header.Set("Content-Type", writer.FormDataContentType())
	req.Header.Set("Authorization", "Bearer "+a.apiKey)

	client := &http.Client{Timeout: 60 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return "", fmt.Errorf("ASR request failed: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		respBody, _ := io.ReadAll(resp.Body)
		return "", fmt.Errorf("ASR API error %d: %s", resp.StatusCode, string(respBody))
	}

	var result struct {
		Data struct {
			Text string `json:"text"`
		} `json:"data"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return "", fmt.Errorf("failed to parse ASR response: %w", err)
	}

	return result.Data.Text, nil
}
