import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/memory.dart';
import '../services/api_service.dart';

final _sampleMemories = [
  Memory(id: '1', userId: 'u1', type: 'voice', content: '今天去超市买了些水果，苹果和香蕉，还有牛奶。想着周末要打扫房间，然后约朋友去爬山。', summary: '日常购物与周末计划', title: '今日随想', tags: ['生活', '计划'], createdAt: DateTime.now().subtract(Duration(hours: 2)), updatedAt: DateTime.now()),
  Memory(id: '2', userId: 'u1', type: 'text', content: 'Flutter 真的很强大，一套代码可以跑 iOS、Android、HarmonyOS。前端用 Riverpod 做状态管理，后端用 Go 语言，性能应该没问题。', summary: '跨平台技术选型思考', title: '技术选型', tags: ['技术', 'Flutter'], createdAt: DateTime.now().subtract(Duration(days: 1)), updatedAt: DateTime.now()),
  Memory(id: '3', userId: 'u1', type: 'image', content: '这张照片是上周拍的，当时天气很好，天特别蓝。', summary: '天气晴朗的日子', title: '好天气', tags: ['生活', '记录'], createdAt: DateTime.now().subtract(Duration(days: 3)), updatedAt: DateTime.now()),
];

final memoryStoreProvider = StateNotifierProvider<MemoryStore, AsyncValue<List<Memory>>>((ref) {
  return MemoryStore();
});

class MemoryStore extends StateNotifier<AsyncValue<List<Memory>>> {
  MemoryStore() : super(const AsyncValue.loading());

  final _api = ApiService();

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final memories = await _api.getMemories();
      state = AsyncValue.data(memories);
    } catch (e, st) {
      state = AsyncValue.data(_sampleMemories);
    }
  }

  Future<void> add(Memory memory) async {
    try {
      final created = await _api.createMemory(memory.toJson());
      state.whenData((list) {
        state = AsyncValue.data([created, ...list]);
      });
    } catch (e) {
      // keep current state on error
    }
  }

  Future<void> remove(String id) async {
    try {
      await _api.deleteMemory(id);
      state.whenData((list) {
        state = AsyncValue.data(list.where((m) => m.id != id).toList());
      });
    } catch (e) {}
  }

  Future<void> update(Memory memory) async {
    try {
      final updated = await _api.updateMemory(memory.id, memory.toJson());
      state.whenData((list) {
        state = AsyncValue.data(list.map((m) => m.id == memory.id ? updated : m).toList());
      });
    } catch (e) {}
  }

  Future<void> summarize(String id) async {
    try {
      final summarized = await _api.summarizeMemory(id);
      state.whenData((list) {
        state = AsyncValue.data(list.map((m) => m.id == id ? summarized : m).toList());
      });
    } catch (e) {}
  }
}
