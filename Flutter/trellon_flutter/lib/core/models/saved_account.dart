class SavedAccount {
  final String userUId;
  final String userName;
  final String email;
  final String avatarUrl;

  const SavedAccount({
    required this.userUId,
    required this.userName,
    required this.email,
    this.avatarUrl = '',
  });

  Map<String, dynamic> toJson() => {
        'userUId': userUId,
        'userName': userName,
        'email': email,
        'avatarUrl': avatarUrl,
      };

  factory SavedAccount.fromJson(Map<String, dynamic> json) => SavedAccount(
        userUId: json['userUId'] as String? ?? '',
        userName: json['userName'] as String? ?? '',
        email: json['email'] as String? ?? '',
        avatarUrl: json['avatarUrl'] as String? ?? '',
      );

  @override
  bool operator ==(Object other) =>
      other is SavedAccount && other.userUId == userUId;

  @override
  int get hashCode => userUId.hashCode;
}
