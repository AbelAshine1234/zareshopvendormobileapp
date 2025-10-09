import 'package:equatable/equatable.dart';
import '../../../data/models/vendor_model.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {
  const LoadProfile();
}

class UpdateProfile extends ProfileEvent {
  final Vendor vendor;

  const UpdateProfile(this.vendor);

  @override
  List<Object?> get props => [vendor];
}

class ChangeLanguage extends ProfileEvent {
  final String languageCode;

  const ChangeLanguage(this.languageCode);

  @override
  List<Object?> get props => [languageCode];
}
