class WorkspaceMember {
  final String userUId;
  final String userName;
  final String email;
  final String? avatarUrl;
  final String role;

  const WorkspaceMember({
    required this.userUId,
    required this.userName,
    required this.email,
    this.avatarUrl,
    required this.role,
  });

  factory WorkspaceMember.fromJson(Map<String, dynamic> json) {
    return WorkspaceMember(
      userUId: json['userUId'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      role: json['role'] as String? ?? 'Member',
    );
  }

  /// Trả về URL avatar: nếu có avatar thực thì dùng, nếu không dùng ui-avatars.com
  String get resolvedAvatarUrl {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) return avatarUrl!;
    final initials = Uri.encodeComponent(
      userName.trim().isNotEmpty ? userName.trim() : 'U',
    );
    return 'https://ui-avatars.com/api/?name=$initials&background=random&color=fff';
  }

  WorkspaceMember copyWith({String? role}) {
    return WorkspaceMember(
      userUId: userUId,
      userName: userName,
      email: email,
      avatarUrl: avatarUrl,
      role: role ?? this.role,
    );
  }
}
