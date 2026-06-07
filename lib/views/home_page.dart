import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:muslim_app/views/chat_page.dart';
import 'package:muslim_app/views/kiblat_page.dart';
import 'package:muslim_app/views/sunnah_shalat_page.dart';
import 'package:muslim_app/views/ramadhan_notes_page.dart';
import 'package:muslim_app/views/tasbih_counter_page.dart';
import 'package:muslim_app/views/hadist_page.dart';
import 'package:muslim_app/views/asmaul_husna_page.dart';
import '../viewmodels/shalat_view_model.dart';
import '../models/shalat_schedule_response.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  ShalatDaySchedule? _getTodaySchedule(List<ShalatDaySchedule> schedules) {
    if (schedules.isEmpty) return null;
    final now = DateTime.now();
    final todayStr = "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
    try {
      return schedules.firstWhere((s) => s.tanggal.contains(todayStr));
    } catch (_) {
      return schedules.first;
    }
  }

  String _getNextPrayer(ShalatDaySchedule schedule) {
    final now = DateTime.now();
    final currentTime = now.hour * 60 + now.minute;
    
    int parseTime(String t) {
      final parts = t.split(':');
      if (parts.length != 2) return 0;
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    }

    final subuh = parseTime(schedule.subuh);
    final dzuhur = parseTime(schedule.dzuhur);
    final ashar = parseTime(schedule.ashar);
    final maghrib = parseTime(schedule.maghrib);
    final isya = parseTime(schedule.isya);

    if (currentTime < subuh) return 'Subuh';
    if (currentTime < dzuhur) return 'Dzuhur';
    if (currentTime < ashar) return 'Ashar';
    if (currentTime < maghrib) return 'Maghrib';
    if (currentTime < isya) return 'Isya';
    return 'Subuh'; // Next day Subuh
  }

  static const List<Map<String, String>> _quotes = [
    {
      'text': 'Maka sesungguhnya bersama kesulitan ada kemudahan.',
      'source': 'QS. Al-Insyirah: 5'
    },
    {
      'text': 'Jadikanlah sabar dan shalat sebagai penolongmu.',
      'source': 'QS. Al-Baqarah: 45'
    },
    {
      'text': 'Barangsiapa yang bertaqwa kepada Allah, niscaya Dia akan mengadakan baginya jalan keluar.',
      'source': 'QS. At-Talaq: 2'
    },
    {
      'text': 'Senyummu di hadapan saudaramu adalah sedekah.',
      'source': 'HR. Tirmidzi'
    },
    {
      'text': 'Sebaik-baik manusia adalah yang paling bermanfaat bagi manusia lainnya.',
      'source': 'HR. Ahmad'
    },
  ];

  Map<String, String> _getQuoteOfTheDay() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return _quotes[dayOfYear % _quotes.length];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final shalatVM = context.watch<ShalatViewModel>();
    final todaySchedule = _getTodaySchedule(shalatVM.schedules);
    final quote = _getQuoteOfTheDay();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            // Header Section and Prayer Schedule Card combined for proper Z-ordering
            SliverToBoxAdapter(
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  // Green Background Header
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary.withOpacity(0.85),
                          const Color(0xFF14A3A8),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                  ),
                  // Content (Header Text + Card)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Content
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 24),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.18),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.25),
                                  width: 1.5,
                                ),
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/icon/app_icon.png',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getGreeting(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: Colors.white.withOpacity(0.85),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    'Assalamu\'alaikum',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Prayer Schedule Card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_rounded,
                                        size: 16,
                                        color: colorScheme.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        shalatVM.selectedCityName.split(',').first,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    todaySchedule != null 
                                        ? todaySchedule.tanggal.split(', ').last 
                                        : 'Memuat...',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (shalatVM.isLoading)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2.5),
                                    ),
                                  ),
                                )
                              else if (todaySchedule == null)
                                Center(
                                  child: TextButton.icon(
                                    onPressed: () {
                                      final now = DateTime.now();
                                      shalatVM.fetchMonthlySchedule(
                                        cityId: shalatVM.selectedCityId,
                                        year: now.year,
                                        month: now.month,
                                      );
                                    },
                                    icon: const Icon(Icons.refresh_rounded, size: 16),
                                    label: Text(
                                      'Coba lagi memuat jadwal',
                                      style: GoogleFonts.poppins(fontSize: 12),
                                    ),
                                  ),
                                )
                              else
                                _buildPrayerTimesRow(context, todaySchedule),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // AI Chat Bot Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                child: GestureDetector(
                  onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.secondary.withOpacity(0.12),
                            colorScheme.secondary.withOpacity(0.04),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colorScheme.secondary.withOpacity(0.25),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colorScheme.secondary.withOpacity(0.18),
                            ),
                            child: Icon(
                              Icons.smart_toy_rounded,
                              color: colorScheme.secondary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AI Chat Bot Islam',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Tanya mengenai aqidah, fiqih, & ibadah',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: colorScheme.secondary,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Quote of the Day Section (Moved before Layanan Utama)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.format_quote_rounded,
                            color: colorScheme.primary.withOpacity(0.6),
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Kutipan Hari Ini',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        quote['text']!,
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          quote['source']!,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Services Grid Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 8),
                child: Text(
                  'Layanan Utama',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ),

            // Services Grid (3 Columns, 2 Rows)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.88,
                ),
                delegate: SliverChildListDelegate([
                  _buildMenuCard(
                    context,
                    icon: Icons.library_books_rounded,
                    title: 'Hadits Shahih',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HadistPage(),
                        ),
                      );
                    },
                    color: const Color(0xFF00796B),
                  ),
                  _buildMenuCard(
                    context,
                    icon: Icons.auto_awesome_rounded,
                    title: 'Asmaul Husna',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AsmaulHusnaPage(),
                        ),
                      );
                    },
                    color: const Color(0xFFD4AF37),
                  ),
                  _buildMenuCard(
                    context,
                    icon: Icons.pin_rounded,
                    title: 'Tasbih',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TasbihCounterPage(),
                        ),
                      );
                    },
                    color: const Color(0xFF0D7377),
                  ),
                  _buildMenuCard(
                    context,
                    icon: Icons.explore_rounded,
                    title: 'Arah Kiblat',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const KiblatPage(),
                        ),
                      );
                    },
                    color: const Color(0xFF0288D1),
                  ),
                  _buildMenuCard(
                    context,
                    icon: Icons.note_alt_rounded,
                    title: 'Ramadhan',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RamadhanNotesPage(),
                        ),
                      );
                    },
                    color: const Color(0xFF7B1FA2),
                  ),
                  _buildMenuCard(
                    context,
                    icon: Icons.spa_rounded,
                    title: 'Shalat Sunnah',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SunnahShalatPage(),
                        ),
                      );
                    },
                    color: const Color(0xFF2E7D32),
                  ),
                ]),
              ),
            ),

            // Bottom Spacer
            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerTimesRow(BuildContext context, ShalatDaySchedule schedule) {
    final nextPrayer = _getNextPrayer(schedule);
    
    final prayers = [
      {'name': 'Subuh', 'time': schedule.subuh},
      {'name': 'Dzuhur', 'time': schedule.dzuhur},
      {'name': 'Ashar', 'time': schedule.ashar},
      {'name': 'Maghrib', 'time': schedule.maghrib},
      {'name': 'Isya', 'time': schedule.isya},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: prayers.map((p) {
        final isNext = p['name'] == nextPrayer;
        return _buildPrayerTimeColumn(context, p['name']!, p['time']!, isNext);
      }).toList(),
    );
  }

  Widget _buildPrayerTimeColumn(BuildContext context, String name, String time, bool isNext) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: isNext ? colorScheme.primary.withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isNext ? colorScheme.primary.withOpacity(0.3) : Colors.transparent,
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          Text(
            name,
            style: GoogleFonts.poppins(
              fontSize: 10.5,
              fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
              color: isNext ? colorScheme.primary : colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            time,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: isNext ? colorScheme.primary : colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.025),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.grey.withOpacity(0.06),
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.08),
              ),
              child: Icon(
                icon,
                size: 22,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
