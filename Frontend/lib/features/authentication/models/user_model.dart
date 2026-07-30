// lib/features/authentication/models/user_model.dart

class UserModel {
  final String id;
  final String email;
  final String preferredVoice;
  final String theme;
  final String username;
  final int highScore;
  final int streak;
  final String? profilePictureBase64;

  UserModel({
    required this.id,
    required this.email,
    this.preferredVoice = 'default',
    this.theme = 'light',
    this.username = 'user',
    this.highScore = 0,
    this.streak = 0,
    this.profilePictureBase64,
  });

  UserModel copyWith({
    String? id,
    String? email,
    String? preferredVoice,
    String? theme,
    String? username,
    int? highScore,
    int? streak,
    String? profilePictureBase64,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      preferredVoice: preferredVoice ?? this.preferredVoice,
      theme: theme ?? this.theme,
      username: username ?? this.username,
      highScore: highScore ?? this.highScore,
      streak: streak ?? this.streak,
      profilePictureBase64: profilePictureBase64 ?? this.profilePictureBase64,
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
      'streak': streak,
      'profilePictureBase64': profilePictureBase64,
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
      streak: json['streak'] as int? ?? 0,
      profilePictureBase64: json['profilePictureBase64']?.toString(),
    );
  }
}
