import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'global_image_picker.dart';

class GlobalDialog {
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String content,
    List<Widget>? actions,
    bool barrierDismissible = true,
    IconData? icon,
    Color? iconColor,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: iconColor),
              const SizedBox(width: 8),
            ],
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(content),
        actions: actions ?? [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color confirmColor = Colors.blue,
    Color cancelColor = Colors.grey,
    IconData? icon,
    Color? iconColor,
    bool barrierDismissible = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: iconColor),
              const SizedBox(width: 8),
            ],
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(foregroundColor: cancelColor),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  static Future<void> showLoading({
    required BuildContext context,
    String message = 'Loading...',
    bool barrierDismissible = false,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  static Future<T?> showCustom<T>({
    required BuildContext context,
    required Widget child,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => child,
    );
  }

  static void hide(BuildContext context) {
    Navigator.pop(context);
  }

  // Specific dialog types
  static Future<bool?> showLogoutConfirmation({
    required BuildContext context,
    String title = 'Logout',
    String content = 'Are you sure you want to logout from all devices?',
    String confirmText = 'Logout',
    String cancelText = 'Cancel',
  }) {
    return showConfirmation(
      context: context,
      title: title,
      content: content,
      confirmText: confirmText,
      cancelText: cancelText,
      confirmColor: Colors.red,
      icon: Icons.logout,
      iconColor: Colors.red,
    );
  }

  static Future<bool?> showDeleteConfirmation({
    required BuildContext context,
    String title = 'Delete',
    String content = 'Are you sure you want to delete this item?',
    String confirmText = 'Delete',
    String cancelText = 'Cancel',
  }) {
    return showConfirmation(
      context: context,
      title: title,
      content: content,
      confirmText: confirmText,
      cancelText: cancelText,
      confirmColor: Colors.red,
      icon: Icons.delete,
      iconColor: Colors.red,
    );
  }

  static Future<bool?> showImageUpdateConfirmation({
    required BuildContext context,
    required XFile image,
    String title = 'Confirm Image Update',
    String content = 'Are you sure you want to update your image?',
    String confirmText = 'Yes, Update',
    String cancelText = 'Cancel',
  }) {
    return showCustom<bool>(
      context: context,
      child: AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(content),
            const SizedBox(height: 16),
            GlobalImagePicker.buildImagePreview(image: image),
            const SizedBox(height: 16),
            Text(
              'File: ${image.name}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}
