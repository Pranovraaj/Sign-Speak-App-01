// lib/features/history/models/history_item.dart

class HistoryItem {
  final String id;
  final String userId;
  final String text;
  final int timestamp;
  final String? image; // Base64 image snapshot

  HistoryItem({
    required this.id,
    required this.userId,
    required this.text,
    required this.timestamp,
    this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'text': text,
      'timestamp': timestamp,
      'image': image,
    };
  }

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      timestamp: (json['timestamp'] as num?)?.toInt() ?? 0,
      image: json['image']?.toString(),
    );
  }
}
