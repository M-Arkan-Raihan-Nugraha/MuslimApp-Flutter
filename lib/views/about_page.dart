// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tentang Aplikasi',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    // ignore: duplicate_ignore
                    // ignore: deprecated_member_use
                    colorScheme.primary.withOpacity(0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/icon/app_icon.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Muslim App',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Versi 1.0.0',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Tentang card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 22,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Tentang Aplikasi',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Muslim App membantu kegiatan ibadah sehari-hari dengan fitur utama: Mengetahui jadwal shalat dan membaca maupun mempelajari Al-Quran serta doa. Aplikasi ini dirancang sederhana, cepat, dan mudah digunakan.',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Fitur card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 22,
                              color: colorScheme.secondary,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Fitur-Fitur',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildFeatureItem(
                          Icons.access_time_filled_rounded,
                          'Jadwal shalat harian tepat dan akurat',
                          context,
                        ),
                        const SizedBox(height: 10),
                        _buildFeatureItem(
                          Icons.spa_rounded,
                          'Panduan shalat sunnah lengkap',
                          context,
                        ),
                        const SizedBox(height: 10),
                        _buildFeatureItem(
                          Icons.menu_book_rounded,
                          'Al-Quran lengkap dengan latin dan artinya',
                          context,
                        ),
                        const SizedBox(height: 10),
                        _buildFeatureItem(
                          Icons.favorite_rounded,
                          'Kumpulan doa sehari-hari',
                          context,
                        ),
                        const SizedBox(height: 10),
                        _buildFeatureItem(
                          Icons.explore_rounded,
                          'Penunjuk arah kiblat presisi',
                          context,
                        ),
                        const SizedBox(height: 10),
                        _buildFeatureItem(
                          Icons.note_alt_rounded,
                          'Catatan Ramadhan (shalat, ceramah, infaq)',
                          context,
                        ),
                        const SizedBox(height: 10),
                        _buildFeatureItem(
                          Icons.pin_rounded,
                          'Tasbih Counter digital',
                          context,
                        ),
                        const SizedBox(height: 10),
                        _buildFeatureItem(
                          Icons.library_books_rounded,
                          'Kumpulan hadits shahih lengkap',
                          context,
                        ),
                        const SizedBox(height: 10),
                        _buildFeatureItem(
                          Icons.auto_awesome_rounded,
                          '99 Asmaul Husna (Nama-nama Allah)',
                          context,
                        ),
                        const SizedBox(height: 10),
                        _buildFeatureItem(
                          Icons.smart_toy_rounded,
                          'AI Chat Bot untuk pertanyaan seputar Islam',
                          context,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Informasi card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline_rounded,
                              size: 22,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Informasi',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Aplikasi ini dibuat oleh Arkan Nugraha untuk memudahkan umat Muslim dalam beribadah dan belajar. Semoga bermanfaat dan menjadi amal jariyah.',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorScheme.secondary.withOpacity(0.15),
          ),
          child: Icon(
            icon,
            size: 18,
            color: colorScheme.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
