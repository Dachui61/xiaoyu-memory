package repository

import (
	"database/sql"
	"xiaoyu-memory-backend/internal/model"
)

type MemoryRepository struct {
	db *sql.DB
}

func NewMemoryRepository(db *sql.DB) *MemoryRepository {
	return &MemoryRepository{db: db}
}

func (r *MemoryRepository) InitSchema() error {
	_, err := r.db.Exec(`
	CREATE TABLE IF NOT EXISTS memories (
		id TEXT PRIMARY KEY,
		user_id TEXT NOT NULL,
		type TEXT NOT NULL DEFAULT 'text',
		content TEXT NOT NULL,
		summary TEXT DEFAULT '',
		title TEXT DEFAULT '',
		tags TEXT DEFAULT '[]',
		media_url TEXT DEFAULT '',
		created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
		updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
	);
	CREATE INDEX IF NOT EXISTS idx_memories_user_id ON memories(user_id);
	CREATE INDEX IF NOT EXISTS idx_memories_created_at ON memories(created_at);
	`)
	return err
}

func (r *MemoryRepository) List(userID string) ([]model.Memory, error) {
	rows, err := r.db.Query(`
		SELECT id, user_id, type, content, summary, title, tags, media_url, created_at, updated_at
		FROM memories WHERE user_id = ? ORDER BY created_at DESC
	`, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var memories []model.Memory
	for rows.Next() {
		var m model.Memory
		var tags, mediaURL string
		err := rows.Scan(&m.ID, &m.UserID, &m.Type, &m.Content, &m.Summary, &m.Title, &tags, &mediaURL, &m.CreatedAt, &m.UpdatedAt)
		if err != nil {
			return nil, err
		}
		if tags != "" && tags != "[]" {
			// Parse from "[\"tag1\",\"tag2\"]" format
			tags = tags[1 : len(tags)-1]
			if tags != "" {
				m.Tags = parseTags(tags)
			}
		}
		if mediaURL != "" {
			m.MediaURL = mediaURL
		}
		memories = append(memories, m)
	}
	return memories, nil
}

func (r *MemoryRepository) Get(id string) (model.Memory, bool, error) {
	var m model.Memory
	var tags, mediaURL string
	err := r.db.QueryRow(`
		SELECT id, user_id, type, content, summary, title, tags, media_url, created_at, updated_at
		FROM memories WHERE id = ?
	`, id).Scan(&m.ID, &m.UserID, &m.Type, &m.Content, &m.Summary, &m.Title, &tags, &mediaURL, &m.CreatedAt, &m.UpdatedAt)
	if err == sql.ErrNoRows {
		return m, false, nil
	}
	if err != nil {
		return m, false, err
	}
	if tags != "" && tags != "[]" {
		m.Tags = parseTags(tags[1 : len(tags)-1])
	}
	if mediaURL != "" {
		m.MediaURL = mediaURL
	}
	return m, true, nil
}

func (r *MemoryRepository) Create(m model.Memory) (model.Memory, error) {
	tagsJSON := "[]"
	if len(m.Tags) > 0 {
		tagsJSON = tagsToJSON(m.Tags)
	}
	_, err := r.db.Exec(`
		INSERT INTO memories (id, user_id, type, content, summary, title, tags, media_url, created_at, updated_at)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
	`, m.ID, m.UserID, m.Type, m.Content, m.Summary, m.Title, tagsJSON, m.MediaURL, m.CreatedAt, m.UpdatedAt)
	if err != nil {
		return m, err
	}
	return m, nil
}

func (r *MemoryRepository) Update(id string, updates map[string]interface{}) (model.Memory, bool, error) {
	m, ok, err := r.Get(id)
	if err != nil || !ok {
		return m, ok, err
	}

	if v, ok := updates["content"].(string); ok {
		m.Content = v
	}
	if v, ok := updates["summary"].(string); ok {
		m.Summary = v
	}
	if v, ok := updates["title"].(string); ok {
		m.Title = v
	}
	if v, ok := updates["tags"].([]string); ok {
		m.Tags = v
	}
	m.UpdatedAt = now()

	tagsJSON := tagsToJSON(m.Tags)
	_, err = r.db.Exec(`
		UPDATE memories SET content=?, summary=?, title=?, tags=?, updated_at=? WHERE id=?
	`, m.Content, m.Summary, m.Title, tagsJSON, m.UpdatedAt, id)
	if err != nil {
		return m, false, err
	}
	return m, true, nil
}

func (r *MemoryRepository) Delete(id string) bool {
	result, _ := r.db.Exec("DELETE FROM memories WHERE id = ?", id)
	affected, _ := result.RowsAffected()
	return affected > 0
}

func (r *MemoryRepository) Search(userID, q string) ([]model.Memory, error) {
	rows, err := r.db.Query(`
		SELECT id, user_id, type, content, summary, title, tags, media_url, created_at, updated_at
		FROM memories WHERE user_id = ? AND (content LIKE ? OR title LIKE ? OR tags LIKE ?)
		ORDER BY created_at DESC
	`, userID, "%"+q+"%", "%"+q+"%", "%"+q+"%")
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var memories []model.Memory
	for rows.Next() {
		var m model.Memory
		var tags, mediaURL string
		err := rows.Scan(&m.ID, &m.UserID, &m.Type, &m.Content, &m.Summary, &m.Title, &tags, &mediaURL, &m.CreatedAt, &m.UpdatedAt)
		if err != nil {
			continue
		}
		if tags != "" && tags != "[]" {
			m.Tags = parseTags(tags[1 : len(tags)-1])
		}
		if mediaURL != "" {
			m.MediaURL = mediaURL
		}
		memories = append(memories, m)
	}
	return memories, nil
}
