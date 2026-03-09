import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/listings_provider.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'utils/theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Already initialized
  }
  runApp(const KigaliCityApp());
}

class KigaliCityApp extends StatelessWidget {
  const KigaliCityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(AuthService())),
        ChangeNotifierProvider(create: (_) => ListingsProvider(FirestoreService())),
      ],
      child: MaterialApp(
        title: 'Kigali City Services',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const _AppRouter(),
      ),
    );
  }
}

class _AppRouter extends StatelessWidget {
  const _AppRouter();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    switch (auth.status) {
      case AuthStatus.initial:
      case AuthStatus.loading:
        return const _SplashScreen();
      case AuthStatus.authenticated:
        return const HomeScreen();
      case AuthStatus.unauthenticated:
      case AuthStatus.error:
        return const LoginScreen();
    }
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.accentGold,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.location_city, color: AppTheme.primaryDark, size: 44),
            ),
            const SizedBox(height: 20),
            const Text('Kigali City', style: TextStyle(color: AppTheme.textPrimary, fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: AppTheme.accentGold, strokeWidth: 2),
          ],
        ),
      ),
    );
  }
}
