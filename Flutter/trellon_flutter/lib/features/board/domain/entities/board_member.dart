class BoardMember {
  final String userUId;
  final String userName;
  final String email;
  final String? avatarUrl;
  final String role;

  const BoardMember({
    required this.userUId,
    required this.userName,
    required this.email,
    this.avatarUrl,
    required this.role,
  });

  factory BoardMember.fromJson(Map<String, dynamic> json) {
    return BoardMember(
      userUId: json['userUId'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      role: json['role'] as String? ?? 'Viewer',
    );
  }

  String get resolvedAvatarUrl {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) return avatarUrl!;
    final initials = Uri.encodeComponent(
      userName.trim().isNotEmpty ? userName.trim() : 'U',
    );
    return 'https://ui-avatars.com/api/?name=$initials&background=random&color=fff';
  }

  BoardMember copyWith({String? role}) {
    return BoardMember(
      userUId: userUId,
      userName: userName,
      email: email,
      avatarUrl: avatarUrl,
      role: role ?? this.role,
    );
  }
}
