import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'global_snackbar.dart';

class GlobalImagePicker {
  static Future<XFile?> pickImage({
    required BuildContext context,
    ImageSource source = ImageSource.gallery,
    int maxWidth = 1920,
    int maxHeight = 1080,
    int imageQuality = 85,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    try {
      final ImagePicker picker = ImagePicker();
      
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
        preferredCameraDevice: preferredCameraDevice,
      );
      
      return image;
    } catch (e) {
      if (context.mounted) {
        GlobalSnackBar.showError(
          context: context,
          message: 'Failed to pick image: ${e.toString()}',
        );
      }
      return null;
    }
  }

  static Future<XFile?> pickFromGallery({
    required BuildContext context,
    int maxWidth = 1920,
    int maxHeight = 1080,
    int imageQuality = 85,
  }) async {
    return await pickImage(
      context: context,
      source: ImageSource.gallery,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
    );
  }

  static Future<XFile?> pickFromCamera({
    required BuildContext context,
    int maxWidth = 1920,
    int maxHeight = 1080,
    int imageQuality = 85,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    if (kIsWeb) {
      GlobalSnackBar.showWarning(
        context: context,
        message: 'Camera is not available on web. Please use Gallery instead.',
      );
      return null;
    }
    
    return await pickImage(
      context: context,
      source: ImageSource.camera,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
      preferredCameraDevice: preferredCameraDevice,
    );
  }

  static void showImageSourceDialog({
    required BuildContext context,
    required Function(XFile) onImageSelected,
    String title = 'Select Image Source',
    String? description,
    int maxWidth = 1920,
    int maxHeight = 1080,
    int imageQuality = 85,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(description ?? 
          (kIsWeb 
            ? 'Choose an image from your device to upload.'
            : 'Choose how you want to select your image')),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final image = await pickFromGallery(
                context: context,
                maxWidth: maxWidth,
                maxHeight: maxHeight,
                imageQuality: imageQuality,
              );
              if (image != null) {
                onImageSelected(image);
              }
            },
            child: const Text('Gallery'),
          ),
          if (!kIsWeb) // Only show camera option on mobile/desktop
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final image = await pickFromCamera(
                  context: context,
                  maxWidth: maxWidth,
                  maxHeight: maxHeight,
                  imageQuality: imageQuality,
                );
                if (image != null) {
                  onImageSelected(image);
                }
              },
              child: const Text('Camera'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  static Widget buildImagePreview({
    required XFile image,
    double width = 200,
    double height = 150,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(8)),
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: borderRadius,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: kIsWeb
            ? Image.network(
                image.path,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.image, size: 50, color: Colors.grey),
                  );
                },
              )
            : Image.file(
                File(image.path),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.image, size: 50, color: Colors.grey),
                  );
                },
              ),
      ),
    );
  }
}
