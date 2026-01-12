class HistoryEntry {
  final String id;
  final String imageUrl;
  final String? thumbnailUrl;
  final String? originalImageUrl;
  final String? prompt;
  final DateTime createdAt;

  HistoryEntry({
    required this.id,
    required this.imageUrl,
    this.thumbnailUrl,
    this.originalImageUrl,
    this.prompt,
    required this.createdAt,
  });

  factory HistoryEntry.fromMap(Map<String, dynamic> map) {
    return HistoryEntry(
      id: map['id'] ?? '',
      imageUrl: map['storageUrl'] ?? map['imageUrl'] ?? '',
      thumbnailUrl: map['thumbnailUrl'],
      originalImageUrl: map['originalImageUrl'],
      prompt: map['prompt'],
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] is DateTime 
              ? map['createdAt'] 
              : DateTime.parse(map['createdAt'].toString()))
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'thumbnailUrl': thumbnailUrl,
      'originalImageUrl': originalImageUrl,
      'prompt': prompt,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
