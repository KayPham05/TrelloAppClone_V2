class UserEntity {
  final String id;
  final String userName;
  final String email;
  final String? token;
  final String? refreshToken;
  final String? userUId;
  final bool requiresVerification;
  final bool requires2FA;

  UserEntity({
    required this.id,
    required this.userName,
    required this.email,
    this.token,
    this.refreshToken,
    this.userUId,
    this.requiresVerification = false,
    this.requires2FA = false,
  });
}
