abstract class AddressEvent {}

// Load addresses
class LoadAddresses extends AddressEvent {
  final int? page;
  final int? limit;
  final int? vendorId;
  final String? city;
  final String? region;
  final String? subcity;
  final String? woreda;
  final String? kebele;
  final bool? isPrimary;
  final bool? isVerified;

  LoadAddresses({
    this.page,
    this.limit,
    this.vendorId,
    this.city,
    this.region,
    this.subcity,
    this.woreda,
    this.kebele,
    this.isPrimary,
    this.isVerified,
  });
}

// Load vendor addresses
class LoadVendorAddresses extends AddressEvent {
  final int vendorId;

  LoadVendorAddresses({required this.vendorId});
}

// Create address
class CreateAddress extends AddressEvent {
  final String addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? region;
  final String? subcity;
  final String? woreda;
  final String? kebele;
  final String? postalCode;
  final String? country;
  final bool isPrimary;

  CreateAddress({
    required this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.region,
    this.subcity,
    this.woreda,
    this.kebele,
    this.postalCode,
    this.country,
    this.isPrimary = false,
  });
}

// Update address
class UpdateAddress extends AddressEvent {
  final int addressId;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? region;
  final String? subcity;
  final String? woreda;
  final String? kebele;
  final String? postalCode;
  final String? country;
  final bool? isPrimary;

  UpdateAddress({
    required this.addressId,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.region,
    this.subcity,
    this.woreda,
    this.kebele,
    this.postalCode,
    this.country,
    this.isPrimary,
  });
}

// Delete address
class DeleteAddress extends AddressEvent {
  final int addressId;

  DeleteAddress({required this.addressId});
}

// Set primary address
class SetPrimaryAddress extends AddressEvent {
  final int addressId;

  SetPrimaryAddress({required this.addressId});
}

// Refresh addresses
class RefreshAddresses extends AddressEvent {}
