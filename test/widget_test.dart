import 'package:flutter_test/flutter_test.dart';
import 'package:xiaoyu_memory/models/memory.dart';

void main() {
  test('Memory model serialization', () {
    final memory = Memory(
      id: 'test-id',
      userId: 'user-1',
      type: 'text',
      content: '测试内容',
      summary: '测试总结',
      title: '测试标题',
      tags: ['tag1', 'tag2'],
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

    expect(memory.id, 'test-id');
    expect(memory.content, '测试内容');
    expect(memory.tags.length, 2);
  });
}
