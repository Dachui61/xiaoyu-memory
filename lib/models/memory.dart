class Memory {
  final String id;
  final String userId;
  final String type; // "voice", "text", "image"
  final String content;
  final String summary;
  final String title;
  final List<String> tags;
  final String? mediaUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Memory({
    required this.id,
    required this.userId,
    required this.type,
    required this.content,
    this.summary = '',
    this.title = '',
    this.tags = const [],
    this.mediaUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Memory.fromJson(Map<String, dynamic> json) {
    return Memory(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      type: json['type'] ?? 'text',
      content: json['content'] ?? '',
      summary: json['summary'] ?? '',
      title: json['title'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      mediaUrl: json['media_url'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'type': type,
    'content': content,
    'summary': summary,
    'title': title,
    'tags': tags,
    'media_url': mediaUrl,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  Memory copyWith({
    String? id, String? userId, String? type, String? content,
    String? summary, String? title, List<String>? tags, String? mediaUrl,
    DateTime? createdAt, DateTime? updatedAt,
  }) {
    return Memory(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      content: content ?? this.content,
      summary: summary ?? this.summary,
      title: title ?? this.title,
      tags: tags ?? this.tags,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
