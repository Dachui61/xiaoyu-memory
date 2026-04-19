import 'package:flutter_test/flutter_test.dart';
import 'package:xiaoyu_memory/models/user.dart';

void main() {
  group('User Model', () {
    test('fromJson creates user with all fields', () {
      final json = {
        'id': 'user-123',
        'phone': '13800138000',
        'email': 'test@example.com',
        'nickname': '测试用户',
      };
      final user = User.fromJson(json);

      expect(user.id, 'user-123');
      expect(user.phone, '13800138000');
      expect(user.email, 'test@example.com');
      expect(user.nickname, '测试用户');
    });

    test('fromJson handles missing fields', () {
      final json = {'id': 'user-456'};
      final user = User.fromJson(json);

      expect(user.id, 'user-456');
      expect(user.phone, '');
      expect(user.email, '');
      expect(user.nickname, '');
    });
  });
}
