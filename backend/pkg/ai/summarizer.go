package ai

import "fmt"

type Summarizer struct{}

func NewSummarizer() *Summarizer {
	return &Summarizer{}
}

func (s *Summarizer) Summarize(content string) string {
	if len(content) > 50 {
		return fmt.Sprintf("这是一个关于%s的记忆", content[:50])
	}
	return fmt.Sprintf("这是一个关于%s的记忆", content)
}

func (s *Summarizer) Chat(message string) string {
	replies := []string{
		"明白了，我会帮你记住这件事。",
		"好的，我已经记录下来了。",
		"收到！这件事我会帮你好好保存。",
		"已经记住了，有什么需要补充的吗？",
	}
	return replies[0]
}
