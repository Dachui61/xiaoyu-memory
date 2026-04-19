package service

import (
	"fmt"
	"time"

	"xiaoyu-memory-backend/internal/model"
	"xiaoyu-memory-backend/internal/repository"
	"xiaoyu-memory-backend/pkg/ai"
)

type MemoryService struct {
	repo       *repository.MemoryRepository
	summarizer *ai.Summarizer
}

func NewMemoryService(repo *repository.MemoryRepository) *MemoryService {
	return &MemoryService{
		repo:       repo,
		summarizer: ai.NewSummarizer(),
	}
}

func (s *MemoryService) List() []model.Memory {
	list, err := s.repo.List("u1") // default user for now
	if err != nil {
		return nil
	}
	return list
}

func (s *MemoryService) Get(id string) (model.Memory, bool) {
	m, ok, err := s.repo.Get(id)
	if err != nil {
		return m, false
	}
	return m, ok
}

func (s *MemoryService) Create(m model.Memory) model.Memory {
	if m.ID == "" {
		m.ID = fmt.Sprintf("%d", 0) // SQLite will override
	}
	s.repo.Create(m)
	return m
}

func (s *MemoryService) Update(id string, updates map[string]interface{}) (model.Memory, bool) {
	m, ok, err := s.repo.Update(id, updates)
	if err != nil {
		return m, false
	}
	return m, ok
}

func (s *MemoryService) Delete(id string) bool {
	return s.repo.Delete(id)
}

func (s *MemoryService) Summarize(id string) (model.Memory, bool) {
	m, ok, err := s.repo.Get(id)
	if err != nil || !ok {
		return m, false
	}

	title, summary, tags, err := s.summarizer.Summarize(m.Content)
	if err != nil {
		return m, false
	}

	m.Title = title
	m.Summary = summary
	m.Tags = tags
	s.repo.Update(id, map[string]interface{}{
		"title":   title,
		"summary": summary,
		"tags":    tags,
	})
	return m, true
}

func (s *MemoryService) Chat(message, context string) (string, error) {
	return s.summarizer.Chat(message, context)
}

func (s *MemoryService) Search(userID, q string) ([]model.Memory, error) {
	return s.repo.Search(userID, q)
}

func (s *MemoryService) SyncSince(userID string, since int64) ([]model.Memory, error) {
	t := time.Unix(since, 0)
	return s.repo.GetUpdatedSince(userID, t)
}
