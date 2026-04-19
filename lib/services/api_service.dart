import 'package:dio/dio.dart';
import '../models/memory.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: 'http://localhost:8080/api',
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 30),
    ));
  }

  late final Dio _dio;
  String? _token;

  void setToken(String token) => _token = token;

  Map<String, String> get _headers => {
    if (_token != null) 'Authorization': 'Bearer $_token',
    'Content-Type': 'application/json',
  };

  // Auth
  Future<Map<String, dynamic>> register(String phone, String password) async {
    final res = await _dio.post('/auth/register', data: {
      'phone': phone,
      'password': password,
    }, options: Options(headers: _headers));
    return res.data;
  }

  Future<Map<String, dynamic>> login(String phone, String password) async {
    final res = await _dio.post('/auth/login', data: {
      'phone': phone,
      'password': password,
    }, options: Options(headers: _headers));
    return res.data;
  }

  // Memories
  Future<List<Memory>> getMemories() async {
    final res = await _dio.get('/memories', options: Options(headers: _headers));
    final list = res.data['memories'] as List? ?? [];
    return list.map((e) => Memory.fromJson(e)).toList();
  }

  Future<Memory> createMemory(Map<String, dynamic> data) async {
    final res = await _dio.post('/memories', data: data, options: Options(headers: _headers));
    return Memory.fromJson(res.data['memory']);
  }

  Future<Memory> createVoiceMemory(String audioPath) async {
    final formData = FormData.fromMap({
      'audio': MultipartFile.fromFile(audioPath, filename: 'voice.m4a'),
    });
    final res = await _dio.post('/memories', data: formData, options: Options(
      headers: {if (_token != null) 'Authorization': 'Bearer $_token'},
    ));
    return Memory.fromJson(res.data['memory']);
  }

  Future<String> transcribeAudio(String audioPath) async {
    final formData = FormData.fromMap({
      'audio': MultipartFile.fromFile(audioPath, filename: 'voice.m4a'),
    });
    final res = await _dio.post('/asr', data: formData, options: Options(
      headers: {if (_token != null) 'Authorization': 'Bearer $_token'},
    ));
    return res.data['text'] ?? '';
  }

  Future<Memory> getMemory(String id) async {
    final res = await _dio.get('/memories/$id', options: Options(headers: _headers));
    return Memory.fromJson(res.data['memory']);
  }

  Future<Memory> updateMemory(String id, Map<String, dynamic> data) async {
    final res = await _dio.put('/memories/$id', data: data, options: Options(headers: _headers));
    return Memory.fromJson(res.data['memory']);
  }

  Future<void> deleteMemory(String id) async {
    await _dio.delete('/memories/$id', options: Options(headers: _headers));
  }

  Future<Memory> summarizeMemory(String id) async {
    final res = await _dio.post('/memories/$id/summarize', options: Options(headers: _headers));
    return Memory.fromJson(res.data['memory']);
  }

  // AI Chat
  Future<String> chat(String message) async {
    final res = await _dio.post('/chat', data: {'message': message}, options: Options(headers: _headers));
    return res.data['reply'] ?? '';
  }

  // Search
  Future<List<Memory>> search(String query) async {
    final res = await _dio.get('/search', queryParameters: {'q': query}, options: Options(headers: _headers));
    final list = res.data['results'] as List? ?? [];
    return list.map((e) => Memory.fromJson(e)).toList();
  }

  // Profile
  Future<void> updateProfile(String nickname, String phone) async {
    await _dio.put('/profile', data: {
      'nickname': nickname,
      'phone': phone,
    }, options: Options(headers: _headers));
  }

  // Sync
  Future<Map<String, dynamic>> sync(int lastSync, List<Memory> changes) async {
    final res = await _dio.post('/sync', data: {
      'last_sync': lastSync,
      'changes': changes.map((m) => m.toJson()).toList(),
    }, options: Options(headers: _headers));
    return res.data;
  }

  // Auth
  Future<void> deleteAccount() async {
    await _dio.delete('/auth/delete', options: Options(headers: _headers));
  }
}
