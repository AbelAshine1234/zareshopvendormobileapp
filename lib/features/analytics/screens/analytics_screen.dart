import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/shared.dart';
import '../../../core/services/localization_service.dart';
import '../../../shared/utils/theme/theme_provider.dart';
import '../../sales/screens/sales_report_screen.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.currentTheme;
        return Scaffold(
          backgroundColor: theme.background,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Consumer<LocalizationService>(
              builder: (context, localization, child) {
                return Text(
                  localization.translate('navigation.analytics'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                );
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.download, color: Colors.black87),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.share, color: Colors.black87),
                onPressed: () {},
              ),
            ],
          ),
          body: const SalesReportScreen(),
        );
      },
    );
  }
}
