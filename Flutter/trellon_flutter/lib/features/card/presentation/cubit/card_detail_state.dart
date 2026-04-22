import 'package:equatable/equatable.dart';
import '../../domain/entities/card_entity.dart';

abstract class CardDetailState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CardDetailLoading extends CardDetailState {}

class CardDetailLoaded extends CardDetailState {
  final CardEntity card;
  final List<TodoItemEntity> todos;
  final List<CardMemberEntity> members;
  final List<CardMemberEntity> potentialMembers;
  final List<CommentEntity> comments;
  final bool isUploadingAttachment;
  final String? attachmentError;

  CardDetailLoaded({
    required this.card,
    required this.todos,
    required this.members,
    this.potentialMembers = const [],
    required this.comments,
    this.isUploadingAttachment = false,
    this.attachmentError,
  });

  CardDetailLoaded copyWith({
    CardEntity? card,
    List<TodoItemEntity>? todos,
    List<CardMemberEntity>? members,
    List<CardMemberEntity>? potentialMembers,
    List<CommentEntity>? comments,
    bool? isUploadingAttachment,
    String? attachmentError,
    bool clearAttachmentError = false,
  }) {
    return CardDetailLoaded(
      card: card ?? this.card,
      todos: todos ?? this.todos,
      members: members ?? this.members,
      potentialMembers: potentialMembers ?? this.potentialMembers,
      comments: comments ?? this.comments,
      isUploadingAttachment: isUploadingAttachment ?? this.isUploadingAttachment,
      attachmentError: clearAttachmentError ? null : (attachmentError ?? this.attachmentError),
    );
  }

  @override
  List<Object?> get props => [card, todos, members, potentialMembers, comments, isUploadingAttachment, attachmentError];
}

class CardDetailError extends CardDetailState {
  final String message;
  CardDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
