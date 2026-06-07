import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/hadist_book_response.dart';
import '../viewmodels/hadist_view_model.dart';

class HadistDetailPage extends StatefulWidget {
  final HadistBook book;

  const HadistDetailPage({super.key, required this.book});

  @override
  State<HadistDetailPage> createState() => _HadistDetailPageState();
}

class _HadistDetailPageState extends State<HadistDetailPage> {
  final ScrollController _scrollController = ScrollController();
  static const int _pageSize = 50;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHadists();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadHadists() async {
    final start = (_currentPage - 1) * _pageSize + 1;
    final end = (_currentPage * _pageSize).clamp(1, widget.book.available);
    await context.read<HadistViewModel>().fetchHadists(
      widget.book.id,
      start,
      end,
    );
  }

  int get _totalPages => (widget.book.available / _pageSize).ceil();

  void _goToNextPage() {
    if (_currentPage < _totalPages) {
      setState(() {
        _currentPage++;
      });
      _loadHadists();
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
      });
      _loadHadists();
    }
  }

  void _showJumpToPageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        int tempPage = _currentPage;
        return AlertDialog(
          title: Text(
            'Lompat ke Hadits',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pilih halaman rentang (Tersedia $_totalPages halaman rentang):',
                style: GoogleFonts.poppins(fontSize: 12),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _currentPage,
                isExpanded: true,
                items: List.generate(_totalPages, (index) {
                  final pageNum = index + 1;
                  final start = (pageNum - 1) * _pageSize + 1;
                  final end = (pageNum * _pageSize).clamp(
                    1,
                    widget.book.available,
                  );
                  return DropdownMenuItem<int>(
                    value: pageNum,
                    child: Text(
                      'Halaman $pageNum (Hadits $start - $end)',
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                  );
                }),
                onChanged: (val) {
                  if (val != null) {
                    tempPage = val;
                  }
                },
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  isDense: true,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentPage = tempPage;
                });
                _loadHadists();
                Navigator.pop(context);
              },
              child: const Text('Lompat'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HadistViewModel>();
    final colorScheme = Theme.of(context).colorScheme;

    final start = (_currentPage - 1) * _pageSize + 1;
    final end = (_currentPage * _pageSize).clamp(1, widget.book.available);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.book.name,
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          // Range Info Header Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.08),
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.primary.withOpacity(0.15),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Menampilkan Hadits $start - $end',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
                GestureDetector(
                  onTap: _showJumpToPageDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Ubah Rentang',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Hadist list view
          Expanded(
            child: viewModel.isLoadingHadists
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Memuat daftar hadits...',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : viewModel.error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 64,
                            color: colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Gagal memuat hadits',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            viewModel.error!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadHadists,
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      await _loadHadists();
                    },
                    child: Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      interactive: true,
                      thickness: 6.0,
                      radius: const Radius.circular(8.0),
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        padding: const EdgeInsets.all(16),
                        cacheExtent: 3000.0,
                        itemCount: viewModel.hadists.length,
                        itemBuilder: (context, index) {
                          final hadist = viewModel.hadists[index];
                          return RepaintBoundary(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Number / Copy row
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: colorScheme.secondary
                                              .withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          'No. ${hadist.number}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.secondary,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.copy_rounded,
                                          size: 20,
                                        ),
                                        tooltip: 'Salin Hadits',
                                        onPressed: () {
                                          Clipboard.setData(
                                            ClipboardData(
                                              text:
                                                  'Hadits ${widget.book.name} No. ${hadist.number}\n\n'
                                                  '${hadist.arab}\n\n'
                                                  'Artinya: "${hadist.translation}"',
                                            ),
                                          );
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Hadits berhasil disalin ke papan klip',
                                              ),
                                              duration: Duration(seconds: 1),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Arabic script
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      hadist.arab,
                                      style: GoogleFonts.amiri(
                                        fontSize: 22,
                                        height: 2.2,
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSurface,
                                      ),
                                      textAlign: TextAlign.right,
                                      textDirection: TextDirection.rtl,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Divider(color: Colors.grey.shade200),
                                  const SizedBox(height: 12),

                                  // Indonesian translation
                                  Text(
                                    hadist.translation,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      height: 1.6,
                                      color: colorScheme.onSurface.withOpacity(
                                        0.85,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
          ),

          // Pagination Bottom Controls
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: _currentPage > 1 ? _goToPreviousPage : null,
                ),
                Text(
                  'Hal $_currentPage dari $_totalPages',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded),
                  onPressed: _currentPage < _totalPages ? _goToNextPage : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
