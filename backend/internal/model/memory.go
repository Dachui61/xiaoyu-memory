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

type User struct {
	ID        string    `json:"id"`
	Phone     string    `json:"phone"`
	Email     string    `json:"email"`
	CreatedAt time.Time `json:"created_at"`
}

type ChatMessage struct {
	Message string `json:"message"`
}

type ChatReply struct {
	Reply string `json:"reply"`
}
