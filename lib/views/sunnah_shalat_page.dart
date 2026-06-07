import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SunnahShalatPage extends StatefulWidget {
  const SunnahShalatPage({super.key});

  @override
  State<SunnahShalatPage> createState() => _SunnahShalatPageState();
}

class _SunnahShalatPageState extends State<SunnahShalatPage> {
  final ScrollController _scrollController = ScrollController();
  int expandedIndex = -1;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final categories = {
      'Shalat Rawatib': {
        'subtitle': 'Sunnah Berkaitan Fardhu',
        'icon': Icons.auto_awesome_rounded,
        'items': [
          {
            'nama': 'Shalat sebelum Dzuhur',
            'waktu': 'Sebelum adzan Dzuhur',
            'jumlah': '4 rakaat',
            'keutamaan': 'Membersihkan dosa dan memperbanyak pahala.',
          },
          {
            'nama': 'Shalat sesudah Dzuhur',
            'waktu': 'Sesudah shalat Dzuhur',
            'jumlah': '2 rakaat',
            'keutamaan': 'Mengisi kekurangan shalat fardhu.',
          },
          {
            'nama': 'Shalat sebelum Ashar',
            'waktu': 'Sebelum adzan Ashar',
            'jumlah': '4 rakaat',
            'keutamaan': 'Disukai oleh malaikat dan memperbanyak pahala.',
          },
          {
            'nama': 'Shalat sesudah Maghrib',
            'waktu': 'Sesudah shalat Maghrib',
            'jumlah': '2 rakaat',
            'keutamaan': 'Mengisi kekurangan ibadah fardhu.',
          },
          {
            'nama': 'Shalat sesudah Isya',
            'waktu': 'Sesudah shalat Isya',
            'jumlah': '2 rakaat',
            'keutamaan': 'Mengisi kekurangan ibadah fardhu.',
          },
        ],
      },
      'Shalat Qiyamul Lail': {
        'subtitle': 'Shalat Malam Hari',
        'icon': Icons.nights_stay_rounded,
        'items': [
          {
            'nama': 'Shalat Tahajud',
            'waktu': 'Setelah tidur (1/3 malam terakhir lebih utama)',
            'jumlah': '2-8 rakaat (genap)',
            'keutamaan': 'Doa dikabulkan, mendapat kedekatan dengan Allah, pahala berlipat ganda.',
          },
          {
            'nama': 'Shalat Witir',
            'waktu': 'Setelah Isya atau di akhir malam',
            'jumlah': '1, 3, 5, 7, 9, atau 11 rakaat (ganjil)',
            'keutamaan': 'Penutup ibadah shalat, sangat dianjurkan, "Witir adalah hak bagi yang mengerjakan shalat malam".',
          },
        ],
      },
      'Shalat Matahari': {
        'subtitle': 'Terbit dan Terbenam',
        'icon': Icons.wb_sunny_rounded,
        'items': [
          {
            'nama': 'Shalat Dhuha',
            'waktu': 'Setelah matahari terbit 1/4 jam hingga sebelum Dzuhur',
            'jumlah': '2-8 rakaat (genap)',
            'keutamaan': 'Menghapuskan dosa, memperbanyak rezeki, membawa berkah, mencegah kemiskinan.',
          },
          {
            'nama': 'Shalat Awwabin',
            'waktu': 'Setelah Maghrib hingga Isya',
            'jumlah': '6-20 rakaat (genap, dalam kelompok 2 rakaat)',
            'keutamaan': 'Bertaubat, memohon ampunan dari Allah.',
          },
        ],
      },
      'Shalat Khusus': {
        'subtitle': 'Untuk Tujuan Khusus',
        'icon': Icons.stars_rounded,
        'items': [
          {
            'nama': 'Shalat Tasbih',
            'waktu': 'Kapan saja baik siang maupun malam',
            'jumlah': '4 rakaat',
            'keutamaan': 'Menghapuskan dosa, baik yang besar maupun yang kecil, dikatakan dosa sekeliling langit pun akan dihapuskan.',
          },
          {
            'nama': 'Shalat Taubat',
            'waktu': 'Kapan saja ketika ingin bertaubat',
            'jumlah': '2 rakaat',
            'keutamaan': 'Taubat kepada Allah dari segala dosa dan kesalahan.',
          },
          {
            'nama': 'Shalat Hajat',
            'waktu': 'Kapan saja sesuai kebutuhan mendesak',
            'jumlah': '2 rakaat',
            'keutamaan': 'Memohon kepada Allah untuk terpenuhinya kebutuhan dan hajat hidup.',
          },
          {
            'nama': 'Shalat Syukur',
            'waktu': 'Ketika mendapat nikmat atau berkah dari Allah',
            'jumlah': '2 rakaat',
            'keutamaan': 'Bersyukur dan berterima kasih atas nikmat yang diberikan Allah.',
          },
          {
            'nama': 'Shalat Istikharah',
            'waktu': 'Saat terdapat pilihan sulit',
            'jumlah': '2 rakaat',
            'keutamaan': 'Memohon petunjuk Allah dan membentangkan hati untuk memilih keputusan yang tepat.',
          },
        ],
      },
      'Shalat Lainnya': {
        'subtitle': 'Shalat Sunnah Tambahan',
        'icon': Icons.add_circle_outline_rounded,
        'items': [
          {
            'nama': 'Shalat Hari Raya (Eid)',
            'waktu': 'Pagi hari pada Idul Fitri dan Idul Adha',
            'jumlah': '2 rakaat',
            'keutamaan': 'Salah satu amalan di hari kemenangan umat Muslim, berbagi kebahagiaan.',
          },
          {
            'nama': 'Shalat Gerhana Matahari & Bulan',
            'waktu': 'Saat gerhana terjadi',
            'jumlah': '2-8 rakaat',
            'keutamaan': 'Mengingatkan manusia akan kekuasaan Allah dan tanda-tanda kiamat.',
          },
          {
            'nama': 'Shalat Istisqa\' (Minta Hujan)',
            'waktu': 'Ketika terjadi kekeringan',
            'jumlah': '2 rakaat',
            'keutamaan': 'Memohon kepada Allah agar memberikan hujan dan keselamatan dari musibah.',
          },
          {
            'nama': 'Shalat Khauf (Shalat Takut)',
            'waktu': 'Saat perang atau musibah besar',
            'jumlah': '2 rakaat',
            'keutamaan': 'Tetap menjaga shalat dalam situasi sulit dan bahaya.',
          },
        ],
      },
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Shalat Sunnah Lengkap',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        interactive: true,
        thickness: 6.0,
        radius: const Radius.circular(8.0),
        child: ListView.builder(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.all(16),
          itemCount: categories.length,
        itemBuilder: (context, categoryIndex) {
          final categoryName = categories.keys.elementAt(categoryIndex);
          final categoryData = categories[categoryName]!;
          final shalatList = categoryData['items'] as List<Map<String, String>>;
          final categoryIcon = categoryData['icon'] as IconData;
          final categorySubtitle = categoryData['subtitle'] as String;
          final isExpanded = expandedIndex == categoryIndex;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Category Header - Clickable
                InkWell(
                  onTap: () {
                    setState(() {
                      expandedIndex = isExpanded ? -1 : categoryIndex;
                    });
                  },
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.primary.withOpacity(0.1),
                          ),
                          child: Icon(
                            categoryIcon,
                            size: 24,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                categoryName,
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                categorySubtitle,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 24,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),

                // Expandable Content
                if (isExpanded)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      children: shalatList.asMap().entries.map((entry) {
                        final sunnah = entry.value;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sunnah['nama']!,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildInfoRow(
                                Icons.schedule_rounded,
                                'Waktu',
                                sunnah['waktu']!,
                                context,
                              ),
                              const SizedBox(height: 8),
                              _buildInfoRow(
                                Icons.repeat_rounded,
                                'Jumlah',
                                sunnah['jumlah']!,
                                context,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.stars_rounded,
                                    size: 16,
                                    color: colorScheme.secondary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Keutamaan',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: colorScheme.secondary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          sunnah['keutamaan']!,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            color: colorScheme.onSurface,
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    BuildContext context,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
