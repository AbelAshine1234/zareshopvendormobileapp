import 'package:equatable/equatable.dart';

abstract class ContactUpdateState extends Equatable {
  const ContactUpdateState();

  @override
  List<Object?> get props => [];
}

class ContactUpdateInitial extends ContactUpdateState {}

class ContactUpdateLoading extends ContactUpdateState {}

class ContactUpdateSuccess extends ContactUpdateState {
  final String message;

  const ContactUpdateSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class ContactUpdateError extends ContactUpdateState {
  final String message;

  const ContactUpdateError({required this.message});

  @override
  List<Object?> get props => [message];
}
