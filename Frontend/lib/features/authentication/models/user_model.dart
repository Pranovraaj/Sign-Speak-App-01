// lib/features/authentication/models/user_model.dart

class UserModel {
  final String id;
  final String email;
  final String preferredVoice;
  final String theme;
  final String username;
  final int highScore;

  UserModel({
    required this.id,
    required this.email,
    this.preferredVoice = 'default',
    this.theme = 'light',
    this.username = 'user',
    this.highScore = 0,
  });

  UserModel copyWith({
    String? id,
    String? email,
    String? preferredVoice,
    String? theme,
    String? username,
    int? highScore,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      preferredVoice: preferredVoice ?? this.preferredVoice,
      theme: theme ?? this.theme,
      username: username ?? this.username,
      highScore: highScore ?? this.highScore,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'preferredVoice': preferredVoice,
      'theme': theme,
      'username': username,
      'highScore': highScore,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      preferredVoice: json['preferredVoice']?.toString() ?? 'default',
      theme: json['theme']?.toString() ?? 'light',
      username: json['username']?.toString() ?? 'user',
      highScore: json['highScore'] as int? ?? 0,
    );
  }
}
