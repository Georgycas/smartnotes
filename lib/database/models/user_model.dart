class User {
  final String id;
  final String username;
  final String? email;
  final String? profilePicture;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.username,
    this.email,
    this.profilePicture,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// 🔄 Convert User object to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'profile_picture': profilePicture,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 🔄 Create User object from Map (for local DB)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      profilePicture: map['profile_picture'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  /// 🔄 Create User object from Firebase doc (future-ready)
  factory User.fromFirebase(Map<String, dynamic> map) {
    return User(
      id: map['uid'],
      username: map['displayName'] ?? 'Unnamed',
      email: map['email'],
      profilePicture: map['photoURL'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
