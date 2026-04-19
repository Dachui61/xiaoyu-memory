import 'package:shared_preferences/shared_preferences.dart';
import '../models/memory.dart';
import 'api_service.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final ApiService _api = ApiService();
  static const String _lastSyncKey = 'last_sync_timestamp';

  Future<int> getLastSyncTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_lastSyncKey) ?? 0;
  }

  Future<void> setLastSyncTimestamp(int timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastSyncKey, timestamp);
  }

  /// Performs incremental sync with the backend
  /// Returns a SyncResult containing server changes, conflicts, and sync status
  Future<SyncResult> sync(List<Memory> localChanges) async {
    final lastSync = await getLastSyncTimestamp();
    final since = lastSync > 0 ? lastSync : 0;

    final response = await _api.sync(since, localChanges);

    final serverChanges = (response['server_changes'] as List? ?? [])
        .map((e) => Memory.fromJson(e))
        .toList();

    final conflicts = (response['conflicts'] as List? ?? [])
        .map((e) => SyncConflict.fromJson(e))
        .toList();

    final syncedAt = response['synced_at'] as int? ?? 0;
    await setLastSyncTimestamp(syncedAt);

    return SyncResult(
      serverChanges: serverChanges,
      conflicts: conflicts,
      syncedAt: syncedAt,
    );
  }
}

class SyncResult {
  final List<Memory> serverChanges;
  final List<SyncConflict> conflicts;
  final int syncedAt;

  SyncResult({
    required this.serverChanges,
    required this.conflicts,
    required this.syncedAt,
  });
}

class SyncConflict {
  final String memoryId;
  final DateTime clientVersion;
  final DateTime serverVersion;
  final Memory serverMemory;

  SyncConflict({
    required this.memoryId,
    required this.clientVersion,
    required this.serverVersion,
    required this.serverMemory,
  });

  factory SyncConflict.fromJson(Map<String, dynamic> json) {
    return SyncConflict(
      memoryId: json['memory_id'] ?? '',
      clientVersion: DateTime.tryParse(json['client_version'] ?? '') ?? DateTime.now(),
      serverVersion: DateTime.tryParse(json['server_version'] ?? '') ?? DateTime.now(),
      serverMemory: Memory.fromJson(json['server_memory'] ?? {}),
    );
  }

  /// Returns true if client should win the conflict
  bool shouldClientWin(DateTime localUpdatedAt) {
    return localUpdatedAt.isAfter(serverVersion);
  }
}
