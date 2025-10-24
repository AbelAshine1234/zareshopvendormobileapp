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
import 'features/contacts/bloc/contacts_bloc.dart';
import 'features/addresses/bloc/address_bloc.dart';
import 'features/change_password/bloc/change_password_bloc.dart';
import 'features/wallet_management/bloc/wallet_bloc.dart';
import 'core/services/api_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/cart_service.dart';
import 'core/bloc/socket_bloc.dart';

void main() async {
  // Initialize Flutter binding
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize localization service
  await LocalizationService.instance.loadLanguage('en');
  
  // Set up BlocObserver for debugging
  Bloc.observer = AppBlocObserver();
  
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
            return VendorInfoBloc(
              apiService: ApiService(),
              authBloc: context.read<AuthBloc>(),
            );
          },
        ),
        BlocProvider<ContactsBloc>(
          create: (context) {
            return ContactsBloc(
              apiService: ApiService(),
              authBloc: context.read<AuthBloc>(),
            );
          },
        ),
        BlocProvider<AddressBloc>(
          create: (context) {
            return AddressBloc(
              apiService: ApiService(),
              authBloc: context.read<AuthBloc>(),
            );
          },
        ),
        BlocProvider<ChangePasswordBloc>(
          create: (context) {
            return ChangePasswordBloc(
              apiService: ApiService(),
              storageService: StorageService(),
            );
          },
        ),
        // Global WebSocket BLoC - will connect after authentication
        BlocProvider<SocketBloc>(
          create: (context) => SocketBloc(),
        ),
        // Global Wallet BLoC - with WebSocket integration
        BlocProvider<WalletBloc>(
          create: (context) => WalletBloc(
            socketBloc: context.read<SocketBloc>(),
          ),
        ),
      ],
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider.value(value: LocalizationService.instance),
          ChangeNotifierProvider(create: (_) => CartService()),
        ],
        child: Consumer2<ThemeProvider, LocalizationService>(
          builder: (context, themeProvider, localization, child) {
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
