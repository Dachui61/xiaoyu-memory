package repository

import (
	"database/sql"
	"encoding/json"
	"strings"
	"time"
)

func now() time.Time {
	return time.Now()
}

func tagsToJSON(tags []string) string {
	b, _ := json.Marshal(tags)
	return string(b)
}

func parseTags(s string) []string {
	s = strings.TrimSpace(s)
	s = strings.TrimPrefix(s, "\"")
	s = strings.TrimSuffix(s, "\"")
	parts := strings.Split(s, "\",\"")
	var tags []string
	for _, p := range parts {
		p = strings.TrimSpace(p)
		p = strings.TrimPrefix(p, "\"")
		p = strings.TrimSuffix(p, "\"")
		if p != "" {
			tags = append(tags, p)
		}
	}
	return tags
}

type UserRepository struct {
	db *sql.DB
}

func NewUserRepository(db *sql.DB) *UserRepository {
	return &UserRepository{db: db}
}

func (r *UserRepository) InitSchema() error {
	_, err := r.db.Exec(`
	CREATE TABLE IF NOT EXISTS users (
		id TEXT PRIMARY KEY,
		phone TEXT UNIQUE NOT NULL,
		password_hash TEXT NOT NULL,
		nickname TEXT DEFAULT '',
		created_at DATETIME DEFAULT CURRENT_TIMESTAMP
	);
	`)
	return err
}

func (r *UserRepository) Create(id, phone, passwordHash string) error {
	_, err := r.db.Exec(`
		INSERT INTO users (id, phone, password_hash) VALUES (?, ?, ?)
	`, id, phone, passwordHash)
	return err
}

func (r *UserRepository) GetByPhone(phone string) (id, hash string, ok bool, err error) {
	err = r.db.QueryRow("SELECT id, password_hash FROM users WHERE phone = ?", phone).Scan(&id, &hash)
	if err == sql.ErrNoRows {
		return "", "", false, nil
	}
	if err != nil {
		return "", "", false, err
	}
	return id, hash, true, nil
}
