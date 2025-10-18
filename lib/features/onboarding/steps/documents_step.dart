import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../../../shared/shared.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';

class DocumentsStep extends StatefulWidget {
  final AppThemeData theme;

  const DocumentsStep({
    super.key,
    required this.theme,
  });

  @override
  State<DocumentsStep> createState() => _DocumentsStepState();
}

class _DocumentsStepState extends State<DocumentsStep> {
  XFile? _businessLicenseImage;
  XFile? _coverImage;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _selectImage(String documentType) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          if (documentType == 'business_license') {
            _businessLicenseImage = image;
            context.read<OnboardingBloc>().add(UpdateBusinessLicense(image));
          } else if (documentType == 'cover') {
            _coverImage = image;
            context.read<OnboardingBloc>().add(UpdateCoverImage(image));
          }
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${documentType == 'business_license' ? 'Business License' : 'Cover Image'} uploaded!'),
            backgroundColor: widget.theme.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting image: $e'),
          backgroundColor: widget.theme.error,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildImageUploadSection({
    required String title,
    required String description,
    required IconData icon,
    required String documentType,
    required XFile? selectedFile,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: widget.theme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.theme.accent.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.theme.accent.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: widget.theme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: widget.theme.primary, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppThemes.titleLarge(widget.theme).copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: AppThemes.bodyMedium(widget.theme).copyWith(
                              color: widget.theme.textHint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Image display or upload button
                if (selectedFile != null) ...[
                  // Show selected image with clickable area and pencil inside
                  GestureDetector(
                    onTap: () => _selectImage(documentType),
                    child: Container(
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: widget.theme.success,
                          width: 2,
                        ),
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: kIsWeb
                                ? Image.network(selectedFile.path, fit: BoxFit.cover)
                                : Image.file(File(selectedFile.path), fit: BoxFit.cover),
                          ),
                          // Pencil icon inside the image
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: widget.theme.primary,
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: widget.theme.primary.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  // Show upload button
                  InkWell(
                    onTap: () => _selectImage(documentType),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(
                        color: widget.theme.accent.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: widget.theme.primary.withValues(alpha: 0.2),
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_upload_outlined,
                            size: 40,
                            color: widget.theme.primary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tap to Upload',
                            style: AppThemes.titleMedium(widget.theme).copyWith(
                              color: widget.theme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Select from gallery',
                            style: AppThemes.bodySmall(widget.theme).copyWith(
                              color: widget.theme.textHint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        if (state is! OnboardingInProgress) return const SizedBox.shrink();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Business Documents',
              style: AppThemes.headlineLarge(widget.theme),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload the required documents to verify your business.',
              style: AppThemes.bodyLarge(widget.theme),
            ),
            const SizedBox(height: 24),
            
            // Business License Section
            _buildImageUploadSection(
              title: 'Business License *',
              description: 'Upload your official business registration or license document',
              icon: Icons.business_center,
              documentType: 'business_license',
              selectedFile: _businessLicenseImage,
            ),
            
            // Cover Image Section
            _buildImageUploadSection(
              title: 'Business Cover Image *',
              description: 'Upload a cover image that represents your business',
              icon: Icons.image,
              documentType: 'cover',
              selectedFile: _coverImage,
            ),
            
            const SizedBox(height: 24),
            
            // Guidelines
            Card(
              color: widget.theme.info.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: widget.theme.info),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Document Guidelines',
                            style: AppThemes.titleMedium(widget.theme).copyWith(
                              color: widget.theme.info,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '• Images should be clear and readable\n• Accepted formats: JPG, PNG\n• Maximum file size: 5MB per image',
                            style: AppThemes.bodySmall(widget.theme).copyWith(
                              color: widget.theme.info,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}