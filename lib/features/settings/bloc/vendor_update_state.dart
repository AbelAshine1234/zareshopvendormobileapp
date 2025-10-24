import 'package:equatable/equatable.dart';

class VendorUpdateState extends Equatable {
  const VendorUpdateState();

  @override
  List<Object?> get props => [];
}

class VendorUpdateInitial extends VendorUpdateState {}

class VendorUpdateLoading extends VendorUpdateState {}

class VendorUpdateSuccess extends VendorUpdateState {
  final Map<String, dynamic> updatedVendor;

  const VendorUpdateSuccess({required this.updatedVendor});

  @override
  List<Object?> get props => [updatedVendor];
}

class VendorUpdateError extends VendorUpdateState {
  final String message;

  const VendorUpdateError({required this.message});

  @override
  List<Object?> get props => [message];
}
