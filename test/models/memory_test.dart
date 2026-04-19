import 'package:flutter_test/flutter_test.dart';
import 'package:xiaoyu_memory/models/memory.dart';

void main() {
  group('Memory Model', () {
    test('fromJson creates memory with all fields', () {
      final json = {
        'id': 'mem-123',
        'user_id': 'user-1',
        'type': 'text',
        'content': '测试内容',
        'summary': '测试总结',
        'title': '测试标题',
        'tags': ['tag1', 'tag2'],
        'media_url': 'https://example.com/image.jpg',
        'created_at': '2026-01-01T00:00:00.000Z',
        'updated_at': '2026-01-01T00:00:00.000Z',
      };
      final memory = Memory.fromJson(json);

      expect(memory.id, 'mem-123');
      expect(memory.userId, 'user-1');
      expect(memory.type, 'text');
      expect(memory.content, '测试内容');
      expect(memory.summary, '测试总结');
      expect(memory.title, '测试标题');
      expect(memory.tags.length, 2);
      expect(memory.mediaUrl, 'https://example.com/image.jpg');
    });

    test('fromJson handles missing fields with defaults', () {
      final json = {'id': 'mem-456', 'user_id': 'user-2', 'type': 'text', 'content': '', 'created_at': '', 'updated_at': ''};
      final memory = Memory.fromJson(json);

      expect(memory.id, 'mem-456');
      expect(memory.type, 'text');
      expect(memory.summary, '');
      expect(memory.title, '');
      expect(memory.tags, isEmpty);
      expect(memory.mediaUrl, isNull);
    });

    test('toJson serializes correctly', () {
      final memory = Memory(
        id: 'mem-789',
        userId: 'user-3',
        type: 'voice',
        content: '语音内容',
        summary: '总结',
        title: '标题',
        tags: ['tagA'],
        mediaUrl: null,
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 1),
      );
      final json = memory.toJson();

      expect(json['id'], 'mem-789');
      expect(json['user_id'], 'user-3');
      expect(json['type'], 'voice');
      expect(json['content'], '语音内容');
      expect(json['summary'], '总结');
      expect(json['tags'], ['tagA']);
    });

    test('copyWith creates new instance with updated fields', () {
      final original = Memory(
        id: 'mem-original',
        userId: 'user-1',
        type: 'text',
        content: '原始内容',
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 1),
      );
      final updated = original.copyWith(content: '新内容', title: '新标题');

      expect(updated.id, 'mem-original');
      expect(updated.content, '新内容');
      expect(updated.title, '新标题');
      expect(original.content, '原始内容'); // original unchanged
    });
  });
}
