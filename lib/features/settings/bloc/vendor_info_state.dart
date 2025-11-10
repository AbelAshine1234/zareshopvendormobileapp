import 'package:equatable/equatable.dart';

class VendorInfoState extends Equatable {
  const VendorInfoState();

  @override
  List<Object?> get props => [];
}

class VendorInfoInitial extends VendorInfoState {}

class VendorInfoLoading extends VendorInfoState {}

class VendorInfoLoaded extends VendorInfoState {
  final Map<String, dynamic> vendorInfo;

  const VendorInfoLoaded({required this.vendorInfo});

  @override
  List<Object?> get props => [vendorInfo];
}

class VendorInfoError extends VendorInfoState {
  final String message;

  const VendorInfoError({required this.message});

  @override
  List<Object?> get props => [message];
}
