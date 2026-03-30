import 'package:equatable/equatable.dart';
import '../../domain/entities/card_entity.dart';

abstract class CardState extends Equatable {
  const CardState();

  @override
  List<Object?> get props => [];
}

class CardInitial extends CardState {}

class CardLoading extends CardState {}

class CardActionSuccess extends CardState {
  final CardEntity card;
  const CardActionSuccess({required this.card});

  @override
  List<Object?> get props => [card];
}

class CardDescriptionLoaded extends CardState {
  final String description;
  const CardDescriptionLoaded({required this.description});

  @override
  List<Object?> get props => [description];
}

class CardActionError extends CardState {
  final String message;
  const CardActionError({required this.message});

  @override
  List<Object?> get props => [message];
}
