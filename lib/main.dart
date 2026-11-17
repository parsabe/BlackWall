import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'services/auth_service.dart';
import 'services/blackwall_service.dart';
import 'services/storage_service.dart';
import 'widgets/route_guard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService();
  await storageService.init();

  final authService = AuthService(storageService);
  final blackwallService = BlackWallService();

  runApp(
    BlackWallApp(
      storageService: storageService,
      authService: authService,
      blackwallService: blackwallService,
    ),
  );
}

class BlackWallApp extends StatelessWidget {
  final StorageService storageService;
  final AuthService authService;
  final BlackWallService blackwallService;

  const BlackWallApp({
    super.key,
    required this.storageService,
    required this.authService,
    required this.blackwallService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService)..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(storageService)..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatProvider(blackwallService),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) => MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settings.themeMode,
          home: const RouteGuard(
            child: ChatScreen(),
          ),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignupScreen(),
            '/forgot-password': (context) => const ForgotPasswordScreen(),
            '/chat': (context) => const RouteGuard(child: ChatScreen()),
            '/settings': (context) => const RouteGuard(child: SettingsScreen()),
          },
        ),
      ),
    );
  }
}
