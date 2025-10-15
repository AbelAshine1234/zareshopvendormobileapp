import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/navigation/app_router.dart';
import 'core/utils/app_bloc_observer.dart';

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
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
