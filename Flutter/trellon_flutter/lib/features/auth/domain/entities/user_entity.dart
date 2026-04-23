class UserEntity {
  final String id;
  final String userName;
  final String email;
  final String? token;
  final String? userUId;
  final bool requiresVerification;

  UserEntity({
    required this.id,
    required this.userName,
    required this.email,
    this.token,
    this.userUId,
    this.requiresVerification = false,
  });
}
