package ai

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"
	"time"
)

type Summarizer struct {
	apiKey string
	model  string
}

func NewSummarizer() *Summarizer {
	apiKey := os.Getenv("MINIMAX_API_KEY")
	if apiKey == "" {
		apiKey = "YOUR_MINIMAX_API_KEY"
	}
	return &Summarizer{
		apiKey: apiKey,
		model:  "MiniMax-M2.7",
	}
}

type MiniMaxRequest struct {
	Model string        `json:"model"`
	Messages []Message `json:"messages"`
}

type Message struct {
	Role    string `json:"role"`
	Content string `json:"content"`
}

type MiniMaxResponse struct {
	Choices []Choice `json:"choices"`
	Usage   Usage    `json:"usage"`
}

type Choice struct {
	Message Message `json:"message"`
}

type Usage struct {
	InputTokens  int `json:"input_tokens"`
	OutputTokens int `json:"output_tokens"`
}

func (s *Summarizer) callMiniMax(system, user string) (string, error) {
	url := "https://api.minimaxi.com/v1/chat/completions"
	groupId := os.Getenv("MINIMAX_GROUP_ID")
	if groupId != "" {
		url += "?GroupId=" + groupId
	}

	reqBody := MiniMaxRequest{
		Model: s.model,
		Messages: []Message{
			{Role: "system", Content: system},
			{Role: "user", Content: user},
		},
	}
	jsonBody, _ := json.Marshal(reqBody)

	req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonBody))
	if err != nil {
		return "", err
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+s.apiKey)

	client := &http.Client{Timeout: 30 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return "", fmt.Errorf("MiniMax API error: %d - %s", resp.StatusCode, string(body))
	}

	var result MiniMaxResponse
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return "", err
	}

	if len(result.Choices) == 0 {
		return "", fmt.Errorf("no response from MiniMax")
	}
	return result.Choices[0].Message.Content, nil
}

func (s *Summarizer) Summarize(content string) (summary, title string, tags []string, err error) {
	system := `你是一个AI记忆助手。用户会输入一段记忆内容，你需要：
1. 生成一个简短的标题（8字以内）
2. 生成3个关键词标签
3. 生成一段AI总结（20字以内）

请以JSON格式返回：
{"title":"标题","tags":["标签1","标签2","标签3"],"summary":"总结"}

只返回JSON，不要其他内容。`

	user := fmt.Sprintf("记忆内容：%s", content)

	reply, err := s.callMiniMax(system, user)
	if err != nil {
		// Fallback
		title = s.fallbackTitle(content)
		summary = s.fallbackSummary(content)
		tags = s.fallbackTags(content)
		return
	}

	// Parse JSON from reply
	reply = strings.TrimSpace(reply)
	reply = strings.TrimPrefix(reply, "```json")
	reply = strings.TrimPrefix(reply, "```")
	reply = strings.TrimSuffix(reply, "```")
	reply = strings.TrimSpace(reply)

	var result map[string]interface{}
	if err = json.Unmarshal([]byte(reply), &result); err != nil {
		title = s.fallbackTitle(content)
		summary = s.fallbackSummary(content)
		tags = s.fallbackTags(content)
		return
	}

	if t, ok := result["title"].(string); ok && t != "" {
		title = t
	} else {
		title = s.fallbackTitle(content)
	}

	if sm, ok := result["summary"].(string); ok && sm != "" {
		summary = sm
	} else {
		summary = s.fallbackSummary(content)
	}

	if tg, ok := result["tags"].([]interface{}); ok {
		for _, t := range tg {
			if tag, ok := t.(string); ok {
				tags = append(tags, tag)
			}
		}
	}
	if len(tags) == 0 {
		tags = s.fallbackTags(content)
	}

	return
}

func (s *Summarizer) Chat(message, context string) (string, error) {
	system := `你是一个贴心的小宇AI记忆助手。你能访问用户的记忆库，可以帮助用户回忆、总结、整理记忆。
你可以：
- 回答用户关于他们记忆的问题
- 帮助整理和归纳记忆
- 提醒用户重要的事情
- 进行自然的对话

保持温暖、专业、简洁。`

	history := context
	if history == "" {
		history = "用户：你好"
	}

	prompt := fmt.Sprintf("%s\n\n用户：%s", history, message)
	return s.callMiniMax(system, prompt)
}

func (s *Summarizer) fallbackTitle(content string) string {
	if len(content) <= 10 {
		return content
	}
	return content[:10] + "..."
}

func (s *Summarizer) fallbackSummary(content string) string {
	runes := []rune(content)
	if len(runes) <= 30 {
		return content
	}
	return string(runes[:30]) + "..."
}

func (s *Summarizer) fallbackTags(content string) []string {
	return []string{"记忆", "日常"}
}
