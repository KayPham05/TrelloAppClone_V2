import 'package:equatable/equatable.dart';
import 'package:apptreolon/features/card/domain/entities/card_entity.dart';

abstract class InboxState extends Equatable {
  const InboxState();

  @override
  List<Object?> get props => [];
}

class InboxInitial extends InboxState {}

class InboxLoading extends InboxState {}

class InboxLoaded extends InboxState {
  final List<CardEntity> cards;
  const InboxLoaded({required this.cards});

  @override
  List<Object?> get props => [cards];
}

class InboxEmpty extends InboxState {}

class InboxError extends InboxState {
  final String message;

  const InboxError({required this.message});

  @override
  List<Object?> get props => [message];
}
