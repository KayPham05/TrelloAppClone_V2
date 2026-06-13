class InviteSuggestion {
  final String userUId;
  final String userName;
  final String email;
  final String? avatarUrl;
  final String? workspaceRole;

  const InviteSuggestion({
    required this.userUId,
    required this.userName,
    required this.email,
    this.avatarUrl,
    this.workspaceRole,
  });

  String get displayName =>
      userName.trim().isNotEmpty ? userName.trim() : email;
}
