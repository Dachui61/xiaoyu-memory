import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/memory.dart';
import '../services/api_service.dart';

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
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> add(Memory memory) async {
    // Always add to current state, whether loading, error, or data
    state = state.when(
      data: (list) {
        if (list.any((m) => m.id == memory.id)) return AsyncValue.data(list);
        return AsyncValue.data([memory, ...list]);
      },
      loading: () => AsyncValue.data([memory]),
      error: (e, st) => AsyncValue.data([memory]),
    );
  }

  Future<void> remove(String id) async {
    try {
      await _api.deleteMemory(id);
      state.whenData((list) {
        state = AsyncValue.data(list.where((m) => m.id != id).toList());
      });
    } catch (e, st) { debugPrint('Error: $e\n$st'); }
  }

  Future<void> update(Memory memory) async {
    try {
      final updated = await _api.updateMemory(memory.id, memory.toJson());
      state.whenData((list) {
        state = AsyncValue.data(list.map((m) => m.id == memory.id ? updated : m).toList());
      });
    } catch (e, st) { debugPrint('Error: $e\n$st'); }
  }

  Future<void> summarize(String id) async {
    try {
      final summarized = await _api.summarizeMemory(id);
      state.whenData((list) {
        state = AsyncValue.data(list.map((m) => m.id == id ? summarized : m).toList());
      });
    } catch (e, st) { debugPrint('Error: $e\n$st'); }
  }
}
