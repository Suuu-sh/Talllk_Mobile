import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
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
    const lightScaffold = Color(0xFFFAFAFA);
    const darkScaffold = Color(0xFF0A0A0A);
    const darkSurface = Color(0xFF151515);
    const darkCard = Color(0xFF1A1A1A);
    
    // Modern color scheme - Blue/Purple gradient
    final lightScheme = ColorScheme.light(
      primary: const Color(0xFF6366F1), // Indigo
      secondary: const Color(0xFF8B5CF6), // Purple
      tertiary: const Color(0xFF06B6D4), // Cyan
      surface: Colors.white,
      background: lightScaffold,
      error: const Color(0xFFEF4444),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: const Color(0xFF1F2937),
      onBackground: const Color(0xFF1F2937),
    );
    
    final darkScheme = ColorScheme.dark(
      primary: const Color(0xFF818CF8), // Light Indigo
      secondary: const Color(0xFFA78BFA), // Light Purple
      tertiary: const Color(0xFF22D3EE), // Light Cyan
      surface: darkSurface,
      background: darkScaffold,
      error: const Color(0xFFF87171),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: const Color(0xFFF9FAFB),
      onBackground: const Color(0xFFF9FAFB),
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
            textTheme: GoogleFonts.interTextTheme(
              ThemeData.light().textTheme.apply(
                bodyColor: const Color(0xFF1F2937),
                displayColor: const Color(0xFF111827),
              ),
            ).copyWith(
              bodyLarge: GoogleFonts.inter(fontWeight: FontWeight.w300),
              bodyMedium: GoogleFonts.inter(fontWeight: FontWeight.w300),
              bodySmall: GoogleFonts.inter(fontWeight: FontWeight.w300),
              labelLarge: GoogleFonts.inter(fontWeight: FontWeight.w300),
              labelMedium: GoogleFonts.inter(fontWeight: FontWeight.w300),
              labelSmall: GoogleFonts.inter(fontWeight: FontWeight.w300),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF111827),
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              titleTextStyle: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w300,
                color: const Color(0xFF111827),
              ),
            ),
            cardTheme: CardThemeData(
              color: Colors.white,
              elevation: 0,
              shadowColor: Colors.black.withOpacity(0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                textStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF6366F1),
                textStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Color(0xFF6366F1),
              foregroundColor: Colors.white,
              elevation: 2,
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: Color(0xFF6366F1), width: 2),
              ),
              labelStyle: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkScheme,
            scaffoldBackgroundColor: darkScaffold,
            textTheme: GoogleFonts.interTextTheme(
              ThemeData.dark().textTheme.apply(
                bodyColor: const Color(0xFFF9FAFB),
                displayColor: const Color(0xFFFFFFFF),
              ),
            ).copyWith(
              bodyLarge: GoogleFonts.inter(fontWeight: FontWeight.w300),
              bodyMedium: GoogleFonts.inter(fontWeight: FontWeight.w300),
              bodySmall: GoogleFonts.inter(fontWeight: FontWeight.w300),
              labelLarge: GoogleFonts.inter(fontWeight: FontWeight.w300),
              labelMedium: GoogleFonts.inter(fontWeight: FontWeight.w300),
              labelSmall: GoogleFonts.inter(fontWeight: FontWeight.w300),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: darkScaffold,
              foregroundColor: Colors.white,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              titleTextStyle: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w300,
                color: Colors.white,
              ),
            ),
            cardTheme: CardThemeData(
              color: darkCard,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF818CF8),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                textStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF818CF8),
                textStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Color(0xFF818CF8),
              foregroundColor: Colors.white,
              elevation: 2,
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: darkSurface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: Color(0xFF818CF8), width: 2),
              ),
              labelStyle: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF9CA3AF),
              ),
            ),
          ),
          themeMode: themeProvider.themeMode,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(0.9),
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
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
