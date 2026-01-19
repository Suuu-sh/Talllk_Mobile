import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const TalllkApp(),
    ),
  );
}

class TalllkApp extends StatelessWidget {
  const TalllkApp({super.key});

  @override
  Widget build(BuildContext context) {
    const lightScaffold = Color(0xFFF8FAFC);
    const darkScaffold = Color(0xFF0B0B0B);
    const darkSurface = Color(0xFF121212);
    final lightScheme = ColorScheme.fromSeed(
      seedColor: Colors.orange,
      brightness: Brightness.light,
    );
    final darkScheme = ColorScheme.fromSeed(
      seedColor: Colors.orange,
      brightness: Brightness.dark,
    );

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Talllk',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightScheme,
            scaffoldBackgroundColor: lightScaffold,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 1,
              surfaceTintColor: Colors.white,
            ),
            cardTheme: CardThemeData(
              color: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange,
              ),
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.orange),
              ),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkScheme,
            scaffoldBackgroundColor: darkScaffold,
            appBarTheme: const AppBarTheme(
              backgroundColor: darkScaffold,
              foregroundColor: Colors.white,
              elevation: 0,
              surfaceTintColor: darkScaffold,
            ),
            cardTheme: CardThemeData(
              color: darkSurface,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange.shade200,
              ),
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: darkSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade700),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade700),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.orange),
              ),
            ),
          ),
          themeMode: themeProvider.themeMode,
          home: const SplashScreen(),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/dashboard': (context) => const DashboardScreen(),
          },
        );
      },
    );
  }
}
