package model

import (
	"testing"
	"time"
)

func TestMemory_ToJSON(t *testing.T) {
	now := time.Now()
	m := Memory{
		ID:        "mem-123",
		UserID:    "user-1",
		Type:      "text",
		Content:   "测试内容",
		Summary:   "测试总结",
		Title:     "测试标题",
		Tags:      []string{"tag1", "tag2"},
		MediaURL:  "https://example.com/image.jpg",
		CreatedAt: now,
		UpdatedAt: now,
	}

	json := m.ToJSON()

	if json["id"] != "mem-123" {
		t.Errorf("expected id 'mem-123', got %v", json["id"])
	}
	if json["user_id"] != "user-1" {
		t.Errorf("expected user_id 'user-1', got %v", json["user_id"])
	}
	if json["type"] != "text" {
		t.Errorf("expected type 'text', got %v", json["type"])
	}
	if json["content"] != "测试内容" {
		t.Errorf("expected content '测试内容', got %v", json["content"])
	}
	if len(json["tags"].([]string)) != 2 {
		t.Errorf("expected 2 tags, got %v", len(json["tags"].([]string)))
	}
}

func TestMemory_JSONMap(t *testing.T) {
	json := map[string]interface{}{
		"id":         "mem-456",
		"user_id":    "user-2",
		"type":       "voice",
		"content":    "语音内容",
		"summary":    "总结",
		"title":      "标题",
		"tags":       []string{"tagA"},
		"media_url":  "",
		"created_at": time.Now(),
		"updated_at": time.Now(),
	}

	m := JSONToMemory(json)

	if m.ID != "mem-456" {
		t.Errorf("expected ID 'mem-456', got %v", m.ID)
	}
	if m.Type != "voice" {
		t.Errorf("expected Type 'voice', got %v", m.Type)
	}
	if m.Content != "语音内容" {
		t.Errorf("expected Content '语音内容', got %v", m.Content)
	}
}

func TestUser_ToJSON(t *testing.T) {
	now := time.Now()
	u := User{
		ID:        "user-123",
		Phone:     "13800138000",
		Email:     "test@example.com",
		CreatedAt: now,
	}

	json := u.ToJSON()

	if json["id"] != "user-123" {
		t.Errorf("expected id 'user-123', got %v", json["id"])
	}
	if json["phone"] != "13800138000" {
		t.Errorf("expected phone '13800138000', got %v", json["phone"])
	}
	if json["email"] != "test@example.com" {
		t.Errorf("expected email 'test@example.com', got %v", json["email"])
	}
}
