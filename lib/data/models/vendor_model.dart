import 'package:equatable/equatable.dart';

class Vendor extends Equatable {
  final String id;
  final String shopName;
  final String ownerName;
  final String email;
  final String phone;
  final String profileImageUrl;
  final String bannerImageUrl;
  final String address;
  final String subscriptionPlan;
  final DateTime joinedDate;

  const Vendor({
    required this.id,
    required this.shopName,
    required this.ownerName,
    required this.email,
    required this.phone,
    required this.profileImageUrl,
    required this.bannerImageUrl,
    required this.address,
    required this.subscriptionPlan,
    required this.joinedDate,
  });

  Vendor copyWith({
    String? id,
    String? shopName,
    String? ownerName,
    String? email,
    String? phone,
    String? profileImageUrl,
    String? bannerImageUrl,
    String? address,
    String? subscriptionPlan,
    DateTime? joinedDate,
  }) {
    return Vendor(
      id: id ?? this.id,
      shopName: shopName ?? this.shopName,
      ownerName: ownerName ?? this.ownerName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bannerImageUrl: bannerImageUrl ?? this.bannerImageUrl,
      address: address ?? this.address,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      joinedDate: joinedDate ?? this.joinedDate,
    );
  }

  @override
  List<Object?> get props => [
        id,
        shopName,
        ownerName,
        email,
        phone,
        profileImageUrl,
        bannerImageUrl,
        address,
        subscriptionPlan,
        joinedDate,
      ];
}
