abstract class VendorUpdateEvent {}

class UpdateVendorCoverImage extends VendorUpdateEvent {
  final String imagePath;

  UpdateVendorCoverImage({required this.imagePath});
}

class UpdateVendorInfo extends VendorUpdateEvent {
  final String? name;
  final String? description;
  final String? coverImagePath;
  final String? faydaImagePath;
  final String? businessLicenseImagePath;

  UpdateVendorInfo({
    this.name,
    this.description,
    this.coverImagePath,
    this.faydaImagePath,
    this.businessLicenseImagePath,
  });
}
