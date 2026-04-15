package service

import (
	"fmt"
	"xiaoyu-memory-backend/internal/model"
	"xiaoyu-memory-backend/pkg/ai"
	"time"
)

type MemoryService struct {
	memories   map[string]model.Memory
	summarizer *ai.Summarizer
}

func NewMemoryService() *MemoryService {
	svc := &MemoryService{
		memories:   make(map[string]model.Memory),
		summarizer: ai.NewSummarizer(),
	}
	svc.seed()
	return svc
}

func (s *MemoryService) seed() {
	s.memories["1"] = model.Memory{
		ID:        "1",
		UserID:    "u1",
		Type:      "voice",
		Content:   "今天去超市买了些水果，苹果和香蕉，还有牛奶。想着周末要打扫房间，然后约朋友去爬山。",
		Summary:   "日常购物与周末计划",
		Title:     "今日随想",
		Tags:      []string{"生活", "计划"},
		CreatedAt: time.Now().Add(-2 * time.Hour),
		UpdatedAt: time.Now().Add(-2 * time.Hour),
	}
	s.memories["2"] = model.Memory{
		ID:        "2",
		UserID:    "u1",
		Type:      "text",
		Content:   "Flutter 真的很强大，一套代码可以跑 iOS、Android、HarmonyOS。前端用 Riverpod 做状态管理，后端用 Go 语言，性能应该没问题。",
		Summary:   "跨平台技术选型思考",
		Title:     "技术选型",
		Tags:      []string{"技术", "Flutter"},
		CreatedAt: time.Now().Add(-24 * time.Hour),
		UpdatedAt: time.Now().Add(-24 * time.Hour),
	}
	s.memories["3"] = model.Memory{
		ID:        "3",
		UserID:    "u1",
		Type:      "image",
		Content:   "这张照片是上周拍的，当时天气很好，天特别蓝。",
		Summary:   "天气晴朗的日子",
		Title:     "好天气",
		Tags:      []string{"生活", "记录"},
		CreatedAt: time.Now().Add(-72 * time.Hour),
		UpdatedAt: time.Now().Add(-72 * time.Hour),
	}
}

func (s *MemoryService) List() []model.Memory {
	result := make([]model.Memory, 0, len(s.memories))
	for _, m := range s.memories {
		result = append(result, m)
	}
	return result
}

func (s *MemoryService) Get(id string) (model.Memory, bool) {
	m, ok := s.memories[id]
	return m, ok
}

func (s *MemoryService) Create(m model.Memory) model.Memory {
	m.ID = fmt.Sprintf("%d", len(s.memories)+1)
	m.CreatedAt = time.Now()
	m.UpdatedAt = time.Now()
	s.memories[m.ID] = m
	return m
}

func (s *MemoryService) Update(id string, updates map[string]interface{}) (model.Memory, bool) {
	m, ok := s.memories[id]
	if !ok {
		return model.Memory{}, false
	}
	if title, ok := updates["title"].(string); ok {
		m.Title = title
	}
	if content, ok := updates["content"].(string); ok {
		m.Content = content
	}
	if tags, ok := updates["tags"].([]string); ok {
		m.Tags = tags
	}
	if summary, ok := updates["summary"].(string); ok {
		m.Summary = summary
	}
	m.UpdatedAt = time.Now()
	s.memories[id] = m
	return m, true
}

func (s *MemoryService) Delete(id string) bool {
	if _, ok := s.memories[id]; !ok {
		return false
	}
	delete(s.memories, id)
	return true
}

func (s *MemoryService) Summarize(id string) (model.Memory, bool) {
	m, ok := s.memories[id]
	if !ok {
		return model.Memory{}, false
	}

	title, summary, tags, err := s.summarizer.Summarize(m.Content)
	if err != nil {
		// Fallback values on error
		if title == "" {
			title = m.Title
		}
		if summary == "" {
			summary = m.Summary
		}
		if len(tags) == 0 {
			tags = m.Tags
		}
	}

	m.Title = title
	m.Summary = summary
	m.Tags = tags
	m.UpdatedAt = time.Now()
	s.memories[id] = m
	return m, true
}

func (s *MemoryService) Chat(message, context string) (string, error) {
	return s.summarizer.Chat(message, context)
}
