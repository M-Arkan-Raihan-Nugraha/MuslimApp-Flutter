import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../viewmodels/auth_view_model.dart';

class RamadhanNotesPage extends StatefulWidget {
  const RamadhanNotesPage({super.key});

  @override
  State<RamadhanNotesPage> createState() => _RamadhanNotesPageState();
}

class _RamadhanNotesPageState extends State<RamadhanNotesPage> {
  final ScrollController _scrollController = ScrollController();
  final FirestoreService _firestoreService = FirestoreService();
  bool _localeReady = false;
  bool _isLoading = false;

  // Selected date for the note
  DateTime _selectedDate = DateTime.now();

  // Track whether note is saved (read-only mode)
  bool _isNoteSaved = false;

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

  // ── HELPERS ───────────────────────────────────────────────────────────

  String get _dateKey => DateFormat('yyyy-MM-dd').format(_selectedDate);
  String get _prefsKey => 'ramadhan_note_$_dateKey';

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

  int get completedShalat => _shalatWajib.values.where((v) => v).length;

  /// Build a Map from the current form state
  Map<String, dynamic> _buildNoteData() {
    return {
      'shalatWajib': Map<String, bool>.from(_shalatWajib),
      'tarawihOption': _tarawihOption,
      'penceramah': _penceramahCtrl.text,
      'ceramahType': _ceramahType,
      'ringkasan': _ringkasanCtrl.text,
      'infaq': _infaqCtrl.text,
      'date': _dateKey,
    };
  }

  /// Populate form fields from a data map
  void _populateFromData(Map<String, dynamic> data) {
    if (data['shalatWajib'] != null) {
      final saved = Map<String, dynamic>.from(data['shalatWajib']);
      for (final key in _shalatWajib.keys) {
        _shalatWajib[key] = saved[key] == true;
      }
    }
    _tarawihOption = data['tarawihOption'] as String? ?? 'Tidak shalat';
    _penceramahCtrl.text = data['penceramah'] as String? ?? '';
    _ceramahType = data['ceramahType'] as String? ?? 'Kuliah Subuh';
    _ringkasanCtrl.text = data['ringkasan'] as String? ?? '';
    _infaqCtrl.text = data['infaq'] as String? ?? '';
  }

  /// Clear all form fields to defaults
  void _clearForm() {
    _shalatWajib.updateAll((key, value) => false);
    _tarawihOption = 'Tidak shalat';
    _penceramahCtrl.clear();
    _ceramahType = 'Kuliah Subuh';
    _ringkasanCtrl.clear();
    _infaqCtrl.clear();
  }

  /// Convert Firestore document map to standard JSON-encodable map
  Map<String, dynamic> _makeEncodable(Map<String, dynamic> data) {
    final copy = Map<String, dynamic>.from(data);
    copy.forEach((key, value) {
      if (value is Timestamp) {
        copy[key] = value.toDate().toIso8601String();
      } else if (value is Map) {
        copy[key] = _makeEncodable(Map<String, dynamic>.from(value));
      }
    });
    return copy;
  }

  // ── LIFECYCLE ─────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID').then((_) {
      if (mounted) setState(() => _localeReady = true);
    });
    _loadNote();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _penceramahCtrl.dispose();
    _ringkasanCtrl.dispose();
    _infaqCtrl.dispose();
    super.dispose();
  }

  // ── CRUD OPERATIONS ───────────────────────────────────────────────────

  /// READ: Load note for the selected date
  Future<void> _loadNote() async {
    setState(() => _isLoading = true);

    try {
      // 1. Try loading from SharedPreferences (offline-first)
      final prefs = await SharedPreferences.getInstance();
      final localJson = prefs.getString(_prefsKey);

      if (localJson != null) {
        final data = jsonDecode(localJson) as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            _populateFromData(data);
            _isNoteSaved = true;
          });
        }
      } else {
        // 2. Try loading from Firestore (if logged in)
        if (mounted) {
          final authVm = Provider.of<AuthViewModel>(context, listen: false);
          if (authVm.isLoggedIn) {
            final doc = await _firestoreService.getNote(
              authVm.user!.uid,
              _dateKey,
            );
            if (doc.exists && doc.data() != null) {
              final data = doc.data()!;
              final encodableData = _makeEncodable(data);
              // Cache locally for offline access
              await prefs.setString(_prefsKey, jsonEncode(encodableData));
              if (mounted) {
                setState(() {
                  _populateFromData(encodableData);
                  _isNoteSaved = true;
                });
              }
            } else {
              if (mounted) {
                setState(() {
                  _clearForm();
                  _isNoteSaved = false;
                });
              }
            }
          } else {
            if (mounted) {
              setState(() {
                _clearForm();
                _isNoteSaved = false;
              });
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading note: $e');
      if (mounted) {
        setState(() {
          _clearForm();
          _isNoteSaved = false;
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// CREATE / UPDATE: Save note to local + cloud
  Future<void> _saveNote() async {
    final noteData = _buildNoteData();

    try {
      // 1. Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonEncode(noteData));

      // 2. Save to Firestore (if logged in)
      if (mounted) {
        final authVm = Provider.of<AuthViewModel>(context, listen: false);
        if (authVm.isLoggedIn) {
          await _firestoreService.saveNote(
            authVm.user!.uid,
            _dateKey,
            noteData,
          );
        }
      }

      if (mounted) {
        setState(() => _isNoteSaved = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Catatan berhasil disimpan!',
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving note: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal menyimpan catatan',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// DELETE: Remove note from local + cloud
  Future<void> _resetNote() async {
    try {
      // 1. Remove from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKey);

      // 2. Remove from Firestore (if logged in)
      if (mounted) {
        final authVm = Provider.of<AuthViewModel>(context, listen: false);
        if (authVm.isLoggedIn) {
          await _firestoreService.deleteNote(authVm.user!.uid, _dateKey);
        }
      }

      if (mounted) {
        setState(() {
          _isNoteSaved = false;
          _clearForm();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Catatan hari ini direset',
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error resetting note: $e');
    }
  }

  // ── READ-ONLY SUMMARY VIEW ──────────────────────────────────────────
  Widget _buildReadOnlyView(ColorScheme colorScheme) {
    final progress = completedShalat / 5;
    final progressPercentage = (progress * 100).toStringAsFixed(0);

    return Column(
      children: [
        // Status banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.green.shade600,
                Colors.green.shade400,
              ],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Catatan sudah tersimpan',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(
                        'Edit Catatan?',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      content: Text(
                        'Apakah kamu ingin mengedit catatan hari ini?',
                        style: GoogleFonts.poppins(fontSize: 13),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text('Batal'),
                        ),
                        FilledButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            setState(() {
                              _isNoteSaved = false;
                            });
                          },
                          child: Text('Edit'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.edit_rounded, size: 16, color: Colors.white70),
                label: Text(
                  'Edit',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Shalat Wajib Summary Card
        _buildSectionCard(
          context,
          icon: Icons.access_time_filled_rounded,
          title: 'Shalat Wajib',
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                  minHeight: 10,
                ),
              ),
              const SizedBox(height: 10),
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$progressPercentage%',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _shalatWajib.entries.map((entry) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: entry.value
                          ? colorScheme.primary.withOpacity(0.15)
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: entry.value
                            ? colorScheme.primary
                            : colorScheme.outline.withOpacity(0.3),
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
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          entry.key,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: entry.value
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
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

        // Tarawih Summary Card
        _buildSectionCard(
          context,
          icon: Icons.nights_stay_rounded,
          title: 'Shalat Tarawih',
          child: Row(
            children: [
              Icon(
                _tarawihOption == 'Tidak shalat'
                    ? Icons.cancel_rounded
                    : Icons.check_circle_rounded,
                size: 22,
                color: _tarawihOption == 'Tidak shalat'
                    ? colorScheme.error
                    : colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Text(
                _tarawihOption,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _tarawihOption == 'Tidak shalat'
                      ? colorScheme.error
                      : colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Ceramah Summary Card
        _buildSectionCard(
          context,
          icon: Icons.menu_book_rounded,
          title: 'Ceramah / Kajian',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReadOnlyRow(
                Icons.person_rounded,
                'Penceramah',
                _penceramahCtrl.text.isNotEmpty ? _penceramahCtrl.text : '-',
                colorScheme,
              ),
              const SizedBox(height: 8),
              _buildReadOnlyRow(
                Icons.category_rounded,
                'Tipe',
                _ceramahType,
                colorScheme,
              ),
              if (_ringkasanCtrl.text.isNotEmpty) ...[
                const Divider(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.notes_rounded,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ringkasan',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _ringkasanCtrl.text,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Infaq Summary Card
        _buildSectionCard(
          context,
          icon: Icons.volunteer_activism_rounded,
          title: 'Infaq & Sedekah',
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.secondary.withOpacity(0.15),
                ),
                child: Icon(
                  Icons.payments_rounded,
                  size: 24,
                  color: colorScheme.secondary,
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
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _infaqCtrl.text.isNotEmpty ? _infaqCtrl.text : 'Rp 0',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.check_circle_rounded,
                size: 24,
                color: colorScheme.primary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildReadOnlyRow(
    IconData icon,
    String label,
    String value,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ── EDIT FORM VIEW ──────────────────────────────────────────────────
  Widget _buildEditFormView(ColorScheme colorScheme) {
    return Column(
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
        const SizedBox(height: 16),

        // Action buttons: Simpan + Reset side by side
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _saveNote,
                icon: const Icon(Icons.save_rounded),
                label: Text(
                  'Simpan',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _resetNote,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(
                  'Reset',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              interactive: true,
              thickness: 6.0,
              radius: const Radius.circular(8.0),
              child: ListView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: const EdgeInsets.all(16),
                children: [
                  // Day Picker
                  _buildDatePicker(colorScheme),
                  const SizedBox(height: 16),
                  if (_isNoteSaved)
                    _buildReadOnlyView(colorScheme)
                  else
                    _buildEditFormView(colorScheme),
                ],
              ),
            ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Pilih Tanggal Catatan',
      cancelText: 'Batal',
      confirmText: 'Pilih',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _clearForm();
        _isNoteSaved = false;
      });
      // Load note for the newly selected date
      _loadNote();
    }
  }

  Widget _buildDatePicker(ColorScheme colorScheme) {
    final dateFormatFull = _localeReady
        ? DateFormat('EEEE, d MMMM yyyy', 'id_ID')
        : DateFormat('dd/MM/yyyy');
    final isToday = DateUtils.isSameDay(_selectedDate, DateTime.now());

    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary,
              colorScheme.primary.withOpacity(0.85),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isToday ? 'Hari Ini' : 'Tanggal Dipilih',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateFormatFull.format(_selectedDate),
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.edit_calendar_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Ubah',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
