import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:muslim_app/firebase_options.dart';
import 'package:muslim_app/repositories/shalat_repository.dart';
import 'package:muslim_app/services/gemini_services.dart';
import 'package:muslim_app/services/auth_service.dart';
import 'package:muslim_app/services/firestore_service.dart';
import 'package:muslim_app/viewmodels/auth_view_model.dart';
import 'package:muslim_app/viewmodels/chat_view_model.dart';
import 'package:provider/provider.dart';

import 'views/splash_screen.dart';
import 'viewmodels/quran_view_model.dart';
import 'viewmodels/doa_view_model.dart';
import 'viewmodels/shalat_view_model.dart';
import 'viewmodels/hadist_view_model.dart';
import 'viewmodels/asmaul_husna_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: '.env');
  // Prevent Google Fonts from downloading fonts at runtime in release mode.
  // This avoids crashes/delays when internet is slow or unavailable.
  // Fonts will fallback to system defaults if not bundled.
  GoogleFonts.config.allowRuntimeFetching = true;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

    return MultiProvider(
      providers: [
        Provider(create: (_) => AuthService()),
        Provider(create: (_) => FirestoreService()),
        ChangeNotifierProvider(
          create: (context) => AuthViewModel(context.read<AuthService>()),
        ),
        ChangeNotifierProvider(create: (_) => ShalatViewModel(ShalatRepository())),
        ChangeNotifierProvider(create: (_) => QuranViewModel()),
        ChangeNotifierProvider(create: (_) => DoaViewModel()),
        ChangeNotifierProvider(create: (_) => HadistViewModel()),
        ChangeNotifierProvider(create: (_) => AsmaulHusnaViewModel()),
        Provider(
          create: (_) => GeminiService(apiKey),
        ),
        ChangeNotifierProvider(
          create: (context) => ChatViewModel(context.read<GeminiService>()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0D7377),
            brightness: Brightness.light,
            primary: const Color(0xFF0D7377),
            onPrimary: Colors.white,
            secondary: const Color(0xFFD4AF37),
            onSecondary: Colors.white,
            surface: Colors.white,
            onSurface: const Color(0xFF1A1A1A),
            surfaceContainerHighest: const Color(0xFFF5F5F5),
            onSurfaceVariant: const Color(0xFF666666),
          ),
          scaffoldBackgroundColor: const Color(0xFFFAFAFA),
          appBarTheme: AppBarTheme(
            backgroundColor: const Color(0xFF0D7377),
            foregroundColor: Colors.white,
            centerTitle: true,
            elevation: 0,
            scrolledUnderElevation: 2,
            titleTextStyle: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          textTheme: TextTheme(
            displayLarge: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold),
            displayMedium: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold),
            displaySmall: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
            headlineLarge: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600),
            headlineMedium: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
            headlineSmall: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
            titleLarge: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
            titleMedium: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
            titleSmall: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
            bodyLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.normal),
            bodyMedium: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.normal),
            bodySmall: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.normal),
            labelLarge: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
            labelMedium: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
            labelSmall: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500),
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shadowColor: Colors.black.withAlpha(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF0D7377),
            unselectedItemColor: const Color(0xFF999999),
            type: BottomNavigationBarType.fixed,
            elevation: 8,
            selectedLabelStyle: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          iconTheme: const IconThemeData(
            color: Color(0xFF0D7377),
          ),
          dividerTheme: DividerThemeData(
            color: const Color(0xFFE0E0E0),
            thickness: 1,
            space: 1,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF0D7377), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D7377),
              foregroundColor: Colors.white,
              elevation: 2,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}