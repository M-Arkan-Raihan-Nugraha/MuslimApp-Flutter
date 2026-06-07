import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../viewmodels/shalat_view_model.dart';
import 'main_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _iconController;
  late AnimationController _textController;
  late AnimationController _subtitleController;
  late Animation<double> _iconAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _subtitleAnimation;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    // Icon animation
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _iconAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _iconController,
        curve: Curves.elasticOut,
      ),
    );

    // Title text animation
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _textAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeInOutCubic,
      ),
    );

    // Subtitle text animation
    _subtitleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _subtitleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _subtitleController,
        curve: Curves.easeInOutCubic,
      ),
    );

    // Start animations with staggered timing safely
    _iconController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _textController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _subtitleController.forward();
    });

    // Pre-fetch shalat schedule and city list in background
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        final vm = context.read<ShalatViewModel>();
        final now = DateTime.now();
        vm.repository.getCityList().catchError((_) => <Map<String, dynamic>>[]);
        vm.fetchMonthlySchedule(
          cityId: vm.selectedCityId,
          year: now.year,
          month: now.month,
        ).catchError((_) {});
      } catch (_) {}
    });

    // Navigate to MainPage after splash duration using cancellable Timer
    _navigationTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainPage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _iconController.dispose();
    _textController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary,
              colorScheme.primary.withOpacity(0.85),
              const Color(0xFF14A3A8),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Decorative circles in background
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              Positioned(
                bottom: 100,
                left: -80,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.03),
                  ),
                ),
              ),
              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    // Animated Icon with glow effect
                    ScaleTransition(
                      scale: _iconAnimation,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.3),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/icon/app_icon.png',
                            width: 140,
                            height: 140,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Animated Text
                    FadeTransition(
                      opacity: _textAnimation,
                      child: Column(
                        children: [
                          Text(
                            'Muslim App',
                            style: GoogleFonts.poppins(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimary,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          FadeTransition(
                            opacity: _subtitleAnimation,
                            child: Text(
                              'Your Daily Islamic Companion',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: colorScheme.onPrimary.withOpacity(0.85),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(flex: 1),
                    // Modern loading indicator
                    FadeTransition(
                      opacity: _subtitleAnimation,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 60),
                        child: Column(
                          children: [
                            SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  colorScheme.onPrimary.withOpacity(0.8),
                                ),
                                strokeWidth: 3,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Loading...',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: colorScheme.onPrimary.withOpacity(0.7),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
