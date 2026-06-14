import '../../domain/entities/invite_suggestion.dart';

class InviteSuggestionModel extends InviteSuggestion {
  const InviteSuggestionModel({
    required super.userUId,
    required super.userName,
    required super.email,
    super.avatarUrl,
    super.workspaceRole,
  });

  factory InviteSuggestionModel.fromJson(Map<String, dynamic> json) {
    return InviteSuggestionModel(
      userUId: json['userUId'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      workspaceRole: json['workspaceRole'] as String?,
    );
  }
}
