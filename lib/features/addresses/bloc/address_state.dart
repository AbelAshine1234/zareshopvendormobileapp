import 'package:equatable/equatable.dart';
import '../models/address_model.dart';

class AddressState extends Equatable {
  const AddressState();

  @override
  List<Object?> get props => [];
}

class AddressInitial extends AddressState {}

class AddressLoading extends AddressState {}

class AddressesLoaded extends AddressState {
  final List<AddressModel> addresses;
  final int page;
  final int limit;
  final int total;
  final List<AddressModel>? vendorAddresses;

  const AddressesLoaded({
    required this.addresses,
    required this.page,
    required this.limit,
    required this.total,
    this.vendorAddresses,
  });

  @override
  List<Object?> get props => [addresses, page, limit, total, vendorAddresses];
}

class AddressError extends AddressState {
  final String message;

  const AddressError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Address creation states
class AddressCreating extends AddressState {}

class AddressCreated extends AddressState {
  final AddressModel address;

  const AddressCreated({required this.address});

  @override
  List<Object?> get props => [address];
}

class AddressCreateError extends AddressState {
  final String message;

  const AddressCreateError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Address update states
class AddressUpdating extends AddressState {}

class AddressUpdated extends AddressState {
  final AddressModel address;

  const AddressUpdated({required this.address});

  @override
  List<Object?> get props => [address];
}

class AddressUpdateError extends AddressState {
  final String message;

  const AddressUpdateError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Address deletion states
class AddressDeleting extends AddressState {}

class AddressDeleted extends AddressState {
  final int addressId;

  const AddressDeleted({required this.addressId});

  @override
  List<Object?> get props => [addressId];
}

class AddressDeleteError extends AddressState {
  final String message;

  const AddressDeleteError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Set primary address states
class AddressSettingPrimary extends AddressState {}

class AddressSetAsPrimary extends AddressState {
  final AddressModel address;

  const AddressSetAsPrimary({required this.address});

  @override
  List<Object?> get props => [address];
}

class AddressSetPrimaryError extends AddressState {
  final String message;

  const AddressSetPrimaryError({required this.message});

  @override
  List<Object?> get props => [message];
}
