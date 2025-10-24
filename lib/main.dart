import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'shared/utils/theme/theme_provider.dart';
import 'core/constants/app_constants.dart';
import 'core/utils/app_bloc_observer.dart';
import 'core/navigation/simple_router.dart';
import 'core/services/localization_service.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'core/bloc/app_data.dart';
import 'features/settings/bloc/vendor_update_bloc.dart';
import 'features/settings/bloc/vendor_info_bloc.dart';
import 'core/services/api_service.dart';

void main() async {
  // Initialize Flutter binding
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize localization service
  await LocalizationService.instance.loadLanguage('en');
  
  // Set up BlocObserver for debugging
  Bloc.observer = AppBlocObserver();
  
  print('🚀 [MAIN] App Starting...');
  print('🔍 [MAIN] BlocObserver Registered: ${Bloc.observer.runtimeType}');
  print('🌐 [MAIN] Localization initialized with language: ${LocalizationService.instance.currentLanguage}');
  print('🚀 [MAIN] Initial route should be: /splash');
  
  runApp(const ZareshopVendorApp());
}

class ZareshopVendorApp extends StatelessWidget {
  const ZareshopVendorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(),
        ),
        BlocProvider<AppDataBloc>(
          create: (context) => AppDataBloc()..add(const FetchAllAppData()),
        ),
        BlocProvider<VendorUpdateBloc>(
          create: (context) => VendorUpdateBloc(
            apiService: ApiService(),
            authBloc: context.read<AuthBloc>(),
          ),
        ),
        BlocProvider<VendorInfoBloc>(
          create: (context) {
            print('🚀 [MAIN] Creating VendorInfoBloc...');
            return VendorInfoBloc(
              apiService: ApiService(),
              authBloc: context.read<AuthBloc>(),
            );
          },
        ),
      ],
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider.value(value: LocalizationService.instance),
        ],
        child: Consumer2<ThemeProvider, LocalizationService>(
          builder: (context, themeProvider, localization, child) {
            print('🎨 [MAIN] Building MaterialApp.router with theme: ${themeProvider.currentTheme.runtimeType}');
            print('🌐 [MAIN] Current language: ${localization.currentLanguage}');
            print('🎨 [MAIN] Router config: ${SimpleRouter.router.runtimeType}');
            return MaterialApp.router(
              title: AppConstants.appName,
              debugShowCheckedModeBanner: false,
              theme: themeProvider.themeData,
              routerConfig: SimpleRouter.router,
            );
          },
        ),
      ),
    );
  }
}
