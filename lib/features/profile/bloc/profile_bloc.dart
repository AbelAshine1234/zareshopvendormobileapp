import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/vendor_model.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(const ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<ChangeLanguage>(_onChangeLanguage);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      await Future.delayed(const Duration(seconds: 1));
      final vendor = _getMockVendor();
      emit(ProfileLoaded(vendor: vendor));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      await Future.delayed(const Duration(milliseconds: 500));
      
      emit(ProfileUpdateSuccess(
        message: 'Profile updated successfully',
        vendor: event.vendor,
      ));
      emit(currentState.copyWith(vendor: event.vendor));
    }
  }

  void _onChangeLanguage(
    ChangeLanguage event,
    Emitter<ProfileState> emit,
  ) {
    if (state is ProfileLoaded) {
      emit((state as ProfileLoaded).copyWith(currentLanguage: event.languageCode));
    }
  }

  Vendor _getMockVendor() {
    return Vendor(
      id: 'VEND001',
      shopName: 'Ethiopian Treasures',
      ownerName: 'Abebe Kebede',
      email: 'abebe@ethiopiantreasures.com',
      phone: '+251911234567',
      profileImageUrl: 'https://via.placeholder.com/100',
      bannerImageUrl: 'https://via.placeholder.com/400x150',
      address: 'Bole, Addis Ababa, Ethiopia',
      subscriptionPlan: 'Premium',
      joinedDate: DateTime(2023, 1, 15),
    );
  }
}
