import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/app_colors.dart';
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
    const lightScaffold = AppColors.lightScaffold;
    const darkScaffold = AppColors.darkScaffold;
    const darkSurface = AppColors.darkSurface;
    const darkCard = AppColors.darkCard;
    
    // Modern color scheme - Blue/Purple gradient
    final lightScheme = const ColorScheme.light(
      primary: AppColors.orange600,
      secondary: AppColors.orange600,
      tertiary: AppColors.orange600,
      surface: AppColors.white,
      background: AppColors.lightScaffold,
      error: AppColors.error,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.lightBodyText,
      onBackground: AppColors.lightBodyText,
    );
    
    final darkScheme = const ColorScheme.dark(
      primary: AppColors.orange500,
      secondary: AppColors.orange500,
      tertiary: AppColors.orange500,
      surface: AppColors.darkSurface,
      background: AppColors.darkScaffold,
      error: AppColors.errorLight,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.darkBodyText,
      onBackground: AppColors.darkBodyText,
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
                bodyColor: AppColors.lightBodyText,
                displayColor: AppColors.lightText,
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
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.lightText,
              elevation: 0,
              surfaceTintColor: AppColors.transparent,
              titleTextStyle: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w300,
                color: AppColors.lightText,
              ),
            ),
            cardTheme: CardThemeData(
              color: AppColors.white,
              elevation: 0,
              shadowColor: AppColors.black.withOpacity(0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.grey200, width: 1),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange600,
                foregroundColor: AppColors.white,
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
                foregroundColor: AppColors.orange600,
                textStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: AppColors.orange600,
              foregroundColor: AppColors.white,
              elevation: 2,
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: AppColors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.grey200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.grey200),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: AppColors.orange600, width: 2),
              ),
              labelStyle: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.lightMutedText,
              ),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkScheme,
            scaffoldBackgroundColor: darkScaffold,
            textTheme: GoogleFonts.interTextTheme(
              ThemeData.dark().textTheme.apply(
                bodyColor: AppColors.darkBodyText,
                displayColor: AppColors.white,
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
              foregroundColor: AppColors.white,
              elevation: 0,
              surfaceTintColor: AppColors.transparent,
              titleTextStyle: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w300,
                color: AppColors.white,
              ),
            ),
            cardTheme: CardThemeData(
              color: darkCard,
              elevation: 0,
              shadowColor: AppColors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppColors.white.withOpacity(0.1), width: 1),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange500,
                foregroundColor: AppColors.white,
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
                foregroundColor: AppColors.orange500,
                textStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: AppColors.orange500,
              foregroundColor: AppColors.white,
              elevation: 2,
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: darkSurface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.white.withOpacity(0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.white.withOpacity(0.1)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: AppColors.orange500, width: 2),
              ),
              labelStyle: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.darkMutedText,
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
