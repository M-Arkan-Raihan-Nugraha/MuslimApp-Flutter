import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class RamadhanNotesPage extends StatefulWidget {
  const RamadhanNotesPage({super.key});

  @override
  State<RamadhanNotesPage> createState() => _RamadhanNotesPageState();
}

class _RamadhanNotesPageState extends State<RamadhanNotesPage> {
  // Shalat Wajib checkboxes
  final Map<String, bool> _shalatWajib = {
    'Subuh': false,
    'Dzuhur': false,
    'Ashar': false,
    'Maghrib': false,
    'Isya': false,
  };

  // Shalat Tarawih
  String _tarawihOption = 'Tidak shalat';
  final List<String> _tarawihOptions = [
    'Tidak shalat',
    '11 rakaat',
    '23 rakaat',
  ];

  // Ceramah inputs
  final TextEditingController _penceramahCtrl = TextEditingController();
  String _ceramahType = 'Kuliah Subuh';
  final List<String> _ceramahTypes = [
    'Kuliah Subuh',
    'Sanlat',
    'Belajar Mandiri',
  ];
  final TextEditingController _ringkasanCtrl = TextEditingController();

  // Infaq inputs
  final TextEditingController _infaqCtrl = TextEditingController();
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  String _formatCurrency(String value) {
    final cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanValue.isEmpty) return '';
    final number = int.tryParse(cleanValue) ?? 0;
    return _currencyFormat.format(number);
  }

  void _onInfaqChanged(String value) {
    final formatted = _formatCurrency(value);
    _infaqCtrl.value = _infaqCtrl.value.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  // ignore: unused_element
  String _getRawInfaq() {
    return _infaqCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
  }

  int get completedShalat => _shalatWajib.values.where((v) => v).length;

  @override
  void dispose() {
    _penceramahCtrl.dispose();
    _ringkasanCtrl.dispose();
    _infaqCtrl.dispose();
    super.dispose();
  }

  void _showSummary() {
    final progress = completedShalat / 5;
    final progressPercentage = (progress * 100).toStringAsFixed(0);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with gradient
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withOpacity(0.85),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.summarize_rounded,
                        size: 48,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ringkasan Ibadah Hari Ini',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Shalat Wajib Card
                      _buildSummaryCard(
                        icon: Icons.access_time_filled_rounded,
                        title: 'Shalat Wajib',
                        child: Column(
                          children: [
                            // Progress bar
                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.primary,
                              ),
                              minHeight: 12,
                            ),
                            const SizedBox(height: 10),
                            
                            // Stats row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$completedShalat dari 5 shalat',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '$progressPercentage%',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            
                            // Prayer badges
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: _shalatWajib.entries.map((entry) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: entry.value
                                        ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: entry.value
                                          ? Theme.of(context).colorScheme.primary
                                          : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        entry.value
                                            ? Icons.check_circle_rounded
                                            : Icons.radio_button_unchecked_rounded,
                                        size: 14,
                                        color: entry.value
                                            ? Theme.of(context).colorScheme.primary
                                            : Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        entry.key,
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: entry.value
                                              ? Theme.of(context).colorScheme.primary
                                              : Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Tarawih Card
                      _buildSummaryCard(
                        icon: Icons.nights_stay_rounded,
                        title: 'Shalat Tarawih',
                        child: Row(
                          children: [
                            Icon(
                              _tarawihOption == 'Tidak shalat'
                                  ? Icons.cancel_rounded
                                  : Icons.check_circle_rounded,
                              size: 20,
                              color: _tarawihOption == 'Tidak shalat'
                                  ? Theme.of(context).colorScheme.error
                                  : Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _tarawihOption,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _tarawihOption == 'Tidak shalat'
                                    ? Theme.of(context).colorScheme.error
                                    : Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Ceramah Card (if filled)
                      if (_penceramahCtrl.text.isNotEmpty || _ringkasanCtrl.text.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildSummaryCard(
                          icon: Icons.menu_book_rounded,
                          title: 'Ceramah / Kajian',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_penceramahCtrl.text.isNotEmpty) ...[
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person_rounded,
                                      size: 16,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Penceramah: ',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        _penceramahCtrl.text,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.category_rounded,
                                      size: 16,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Tipe: ',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    Text(
                                      _ceramahType,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (_ringkasanCtrl.text.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Divider(),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.notes_rounded,
                                      size: 16,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        _ringkasanCtrl.text,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Infaq Card (if filled)
                if (_infaqCtrl.text.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildSummaryCard(
                    icon: Icons.volunteer_activism_rounded,
                    title: 'Infaq & Sedekah',
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.secondary.withOpacity(0.15),
                          ),
                          child: Icon(
                            Icons.payments_rounded,
                            size: 24,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Infaq Hari Ini',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _infaqCtrl.text.isNotEmpty
                                    ? _infaqCtrl.text
                                    : 'Rp 0',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.check_circle_rounded,
                          size: 24,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ],
                
                // Close button
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.check_circle_rounded),
                      label: Text('Alhamdulillah'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Catatan Ramadhan',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.summarize_rounded),
            onPressed: _showSummary,
            tooltip: 'Lihat Ringkasan',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Shalat Wajib Section
          _buildSectionCard(
            context,
            icon: Icons.access_time_filled_rounded,
            title: 'Shalat Wajib',
            child: Column(
              children: _shalatWajib.entries.map((entry) {
                return CheckboxListTile(
                  title: Text(
                    entry.key,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  value: entry.value,
                  onChanged: (value) {
                    setState(() {
                      _shalatWajib[entry.key] = value ?? false;
                    });
                  },
                  activeColor: colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Progress indicator
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: completedShalat / 5,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                  minHeight: 8,
                ),
                const SizedBox(height: 8),
                Text(
                  '$completedShalat dari 5 shalat wajib',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Shalat Tarawih Section
          _buildSectionCard(
            context,
            icon: Icons.nights_stay_rounded,
            title: 'Shalat Tarawih',
            child: Column(
              children: _tarawihOptions.map((option) {
                return RadioListTile<String>(
                  title: Text(
                    option,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  value: option,
                  groupValue: _tarawihOption,
                  onChanged: (value) {
                    setState(() {
                      _tarawihOption = value!;
                    });
                  },
                  activeColor: colorScheme.primary,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Ceramah Section
          _buildSectionCard(
            context,
            icon: Icons.menu_book_rounded,
            title: 'Ceramah / Kajian',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Penceramah input
                TextField(
                  controller: _penceramahCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nama Penceramah',
                    prefixIcon: const Icon(Icons.person_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                const SizedBox(height: 16),

                // Ceramah type dropdown
                DropdownButtonFormField<String>(
                  value: _ceramahType,
                  decoration: InputDecoration(
                    labelText: 'Tipe Ceramah',
                    prefixIcon: const Icon(Icons.category_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _ceramahTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(
                        type,
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _ceramahType = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Ringkasan ceramah
                TextField(
                  controller: _ringkasanCtrl,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Ringkasan Ceramah',
                    alignLabelWithHint: true,
                    prefixIcon: const Icon(Icons.notes_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  style: GoogleFonts.poppins(fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Infaq Section
          _buildSectionCard(
            context,
            icon: Icons.volunteer_activism_rounded,
            title: 'Infaq & Sedekah',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 18,
                        color: colorScheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Catat infaq dan sedekah hari ini',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _infaqCtrl,
                  keyboardType: TextInputType.number,
                  onChanged: _onInfaqChanged,
                  decoration: InputDecoration(
                    labelText: 'Jumlah Infaq',
                    hintText: 'Contoh: 50.000',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: colorScheme.secondary.withOpacity(0.05),
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Reset button
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _shalatWajib.updateAll((key, value) => false);
                _tarawihOption = 'Tidak shalat';
                _penceramahCtrl.clear();
                _ceramahType = 'Kuliah Subuh';
                _ringkasanCtrl.clear();
                _infaqCtrl.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Catatan hari ini direset'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.refresh_rounded),
            label: Text('Reset Catatan Hari Ini'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
