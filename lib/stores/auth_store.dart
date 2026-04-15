import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

final authStoreProvider = StateNotifierProvider<AuthStore, User?>((ref) {
  return AuthStore();
});

class AuthStore extends StateNotifier<User?> {
  AuthStore() : super(null);

  final _api = ApiService();

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      _api.setToken(token);
      // In production, validate token with backend
      state = User(id: 'cached');
    }
  }

  Future<bool> login(String phone, String password) async {
    try {
      final res = await _api.login(phone, password);
      final token = res['token'] as String?;
      if (token != null) {
        _api.setToken(token);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        state = User.fromJson(res['user'] ?? {});
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> register(String phone, String password) async {
    try {
      final res = await _api.register(phone, password);
      final token = res['token'] as String?;
      if (token != null) {
        _api.setToken(token);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        state = User.fromJson(res['user'] ?? {});
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    state = null;
  }
}
