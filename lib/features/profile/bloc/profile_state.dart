import 'package:equatable/equatable.dart';
import '../../../data/models/vendor_model.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final Vendor vendor;
  final String currentLanguage;

  const ProfileLoaded({
    required this.vendor,
    this.currentLanguage = 'en',
  });

  ProfileLoaded copyWith({
    Vendor? vendor,
    String? currentLanguage,
  }) {
    return ProfileLoaded(
      vendor: vendor ?? this.vendor,
      currentLanguage: currentLanguage ?? this.currentLanguage,
    );
  }

  @override
  List<Object?> get props => [vendor, currentLanguage];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileUpdateSuccess extends ProfileState {
  final String message;
  final Vendor vendor;

  const ProfileUpdateSuccess({
    required this.message,
    required this.vendor,
  });

  @override
  List<Object?> get props => [message, vendor];
}
