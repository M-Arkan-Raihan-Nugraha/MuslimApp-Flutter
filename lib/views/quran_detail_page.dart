import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/quran_detail_view_model.dart';

class QuranDetailPage extends StatelessWidget {
  final int nomorSurat;

  const QuranDetailPage({super.key, required this.nomorSurat});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => QuranDetailViewModel()..fetchDetail(nomorSurat),
      child: Scaffold(
        appBar: AppBar(
          title: Consumer<QuranDetailViewModel>(
            builder: (context, vm, _) {
              if (vm.detail == null) {
                return Text(
                  'Detail Surat',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }
              return Text(
                'Surat ${vm.detail!.namaLatin}',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ),
        body: Consumer<QuranDetailViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Memuat detail surat...',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }
            if (vm.detail == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Gagal memuat detail surat',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
              );
            }

            final surat = vm.detail!;
            final colorScheme = Theme.of(context).colorScheme;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                  // Surat header card
                  Container(
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
                        Text(
                          surat.nama,
                          style: GoogleFonts.amiri(
                            fontSize: 36,
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          surat.namaLatin,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          surat.arti,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: colorScheme.onPrimary.withOpacity(0.9),
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 12,
                                color: colorScheme.onPrimary.withOpacity(0.9),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                surat.tempatTurun,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.menu_book_rounded,
                                size: 12,
                                color: colorScheme.onPrimary.withOpacity(0.9),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${surat.jumlahAyat} Ayat',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Ayah list
                  ...surat.ayat.map(
                    (ayat) => Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Ayah number - compact inline badge
                          Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      colorScheme.secondary,
                                      colorScheme.secondary.withOpacity(0.8),
                                    ],
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${ayat.nomorAyat}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Arabic text
                          Text(
                            ayat.arab,
                            style: GoogleFonts.amiri(
                              fontSize: 26,
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                              height: 2.2,
                            ),
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            textScaler: const TextScaler.linear(1.0),
                          ),
                          const SizedBox(height: 16),
                          Divider(
                            color: colorScheme.outlineVariant,
                            thickness: 1,
                          ),
                          const SizedBox(height: 12),

                          // Latin transliteration
                          Text(
                            ayat.latin,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          const SizedBox(height: 10),

                          // Translation
                          Text(
                            ayat.arti,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
