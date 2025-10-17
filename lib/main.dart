import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'shared/theme/theme_provider.dart';
import 'core/constants/app_constants.dart';
import 'core/utils/app_bloc_observer.dart';
import 'features/splash/splash_screen.dart';

void main() {
  // Set up BlocObserver for debugging
  Bloc.observer = AppBlocObserver();
  
  print('🚀 App Starting...');
  print('🔍 BlocObserver Registered: ${Bloc.observer.runtimeType}');
  
  runApp(const ZareshopVendorApp());
}

class ZareshopVendorApp extends StatelessWidget {
  const ZareshopVendorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: themeProvider.themeData,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
