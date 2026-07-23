// lib/features/tutorial/models/gesture_model.dart

class GestureModel {
  final String id;
  final String name;
  final String description;
  final String image;
  final String category;
  final bool isLiveRecognized;

  const GestureModel({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.category,
    required this.isLiveRecognized,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'category': category,
      'isLiveRecognized': isLiveRecognized,
    };
  }

  factory GestureModel.fromJson(Map<String, dynamic> json) {
    return GestureModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Beginner',
      isLiveRecognized: json['isLiveRecognized'] as bool? ?? false,
    );
  }
}
