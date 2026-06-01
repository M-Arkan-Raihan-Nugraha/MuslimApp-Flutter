import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/shalat_schedule_response.dart';

class ShalatDetailPage extends StatelessWidget {
  final ShalatDaySchedule shalatDaySchedule;

  const ShalatDetailPage({super.key, required this.shalatDaySchedule});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Jadwal Shalat',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withOpacity(0.85),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 32,
                    color: colorScheme.onPrimary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    shalatDaySchedule.tanggal,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Prayer times list
            Text(
              'Waktu Shalat',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),

            _buildPrayerTimeCard(
              'Imsak',
              shalatDaySchedule.imsak,
              context,
              icon: Icons.free_breakfast,
            ),
            const SizedBox(height: 8),
            _buildPrayerTimeCard(
              'Subuh',
              shalatDaySchedule.subuh,
              context,
              icon: Icons.wb_sunny_rounded,
              isHighlighted: true,
            ),
            const SizedBox(height: 8),
            _buildPrayerTimeCard(
              'Terbit',
              shalatDaySchedule.terbit,
              context,
              icon: Icons.wb_sunny_outlined,
            ),
            const SizedBox(height: 8),
            _buildPrayerTimeCard(
              'Dhuha',
              shalatDaySchedule.dhuha,
              context,
              icon: Icons.sunny_snowing,
            ),
            const SizedBox(height: 8),
            _buildPrayerTimeCard(
              'Dzuhur',
              shalatDaySchedule.dzuhur,
              context,
              icon: Icons.light_mode_rounded,
              isHighlighted: true,
            ),
            const SizedBox(height: 8),
            _buildPrayerTimeCard(
              'Ashar',
              shalatDaySchedule.ashar,
              context,
              icon: Icons.wb_cloudy_rounded,
              isHighlighted: true,
            ),
            const SizedBox(height: 8),
            _buildPrayerTimeCard(
              'Maghrib',
              shalatDaySchedule.maghrib,
              context,
              icon: Icons.nights_stay_rounded,
              isHighlighted: true,
            ),
            const SizedBox(height: 8),
            _buildPrayerTimeCard(
              'Isya',
              shalatDaySchedule.isya,
              context,
              icon: Icons.dark_mode_rounded,
              isHighlighted: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerTimeCard(
    String label,
    String value,
    BuildContext context, {
    IconData icon = Icons.access_time,
    bool isHighlighted = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isHighlighted
            ? Border.all(
                color: colorScheme.secondary.withOpacity(0.3),
                width: 1.5,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isHighlighted
                  ? colorScheme.secondary.withOpacity(0.15)
                  : colorScheme.primary.withOpacity(0.1),
            ),
            child: Icon(
              icon,
              size: 22,
              color: isHighlighted ? colorScheme.secondary : colorScheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isHighlighted
                  ? colorScheme.secondary.withOpacity(0.15)
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isHighlighted ? colorScheme.secondary : colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
