package model

import "time"

type Memory struct {
	ID        string    `json:"id"`
	UserID    string    `json:"user_id"`
	Type      string    `json:"type"`
	Content   string    `json:"content"`
	Summary   string    `json:"summary"`
	Title     string    `json:"title"`
	Tags      []string  `json:"tags"`
	MediaURL  string    `json:"media_url,omitempty"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

func (m Memory) ToJSON() map[string]interface{} {
	return map[string]interface{}{
		"id":          m.ID,
		"user_id":     m.UserID,
		"type":        m.Type,
		"content":     m.Content,
		"summary":     m.Summary,
		"title":       m.Title,
		"tags":        m.Tags,
		"media_url":   m.MediaURL,
		"created_at":  m.CreatedAt,
		"updated_at":  m.UpdatedAt,
	}
}

func JSONToMemory(m map[string]interface{}) Memory {
	tags := []string{}
	if t, ok := m["tags"].([]string); ok {
		tags = t
	}
	return Memory{
		ID:       getString(m, "id"),
		UserID:   getString(m, "user_id"),
		Type:     getString(m, "type"),
		Content:  getString(m, "content"),
		Summary:  getString(m, "summary"),
		Title:    getString(m, "title"),
		Tags:     tags,
		MediaURL: getString(m, "media_url"),
	}
}

func getString(m map[string]interface{}, key string) string {
	if v, ok := m[key].(string); ok {
		return v
	}
	return ""
}

type User struct {
	ID        string    `json:"id"`
	Phone     string    `json:"phone"`
	Email     string    `json:"email"`
	CreatedAt time.Time `json:"created_at"`
}

func (u User) ToJSON() map[string]interface{} {
	return map[string]interface{}{
		"id":    u.ID,
		"phone": u.Phone,
		"email": u.Email,
	}
}

type ChatMessage struct {
	Message string `json:"message"`
}

type ChatReply struct {
	Reply string `json:"reply"`
}
