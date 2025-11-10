import 'package:flutter/material.dart';
import '../../utils/theme/app_themes.dart';

/// Simple loading widget - just a circular progress indicator
class ZareshopLoadingWidget extends StatelessWidget {
  final AppThemeData? theme;
  final double size;
  final bool showBackground;

  const ZareshopLoadingWidget({
    super.key,
    this.theme,
    this.size = 200,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = this.theme;

    Widget content = CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(
        theme?.primary ?? Colors.blue,
      ),
    );

    if (showBackground) {
      return Container(
        color: theme?.background ?? Colors.white,
        child: Center(child: content),
      );
    }

    return Center(child: content);
  }
}

/// Full screen loading overlay
class ZareshopLoadingOverlay extends StatelessWidget {
  final AppThemeData? theme;

  const ZareshopLoadingOverlay({
    super.key,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: (theme?.background ?? Colors.white).withOpacity(0.95),
      child: ZareshopLoadingWidget(
        theme: theme,
        size: 200,
        showBackground: false,
      ),
    );
  }

  /// Show loading overlay
  static void show(BuildContext context, {AppThemeData? theme}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => ZareshopLoadingOverlay(theme: theme),
    );
  }

  /// Hide loading overlay
  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}
