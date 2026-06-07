import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../viewmodels/shalat_view_model.dart';
import 'shalat_detail_page.dart';

class ShalatPage extends StatefulWidget {
  const ShalatPage({super.key});

  @override
  State<ShalatPage> createState() => _ShalatPageState();
}

class _ShalatPageState extends State<ShalatPage> {
  final ScrollController _scrollController = ScrollController();
  int get cityId => context.read<ShalatViewModel>().selectedCityId;
  String get cityName => context.read<ShalatViewModel>().selectedCityName;
  late int year;
  late int month;
  List<Map<String, dynamic>> cityList = [];
  bool isLoadingCities = false;

  final List<String> monthNames = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    year = now.year;
    month = now.month;
    // Load city list and schedule with delay to avoid rate limiting
    _loadInitialData();
  }

  bool _hasLoadedInitialData = false;

  Future<void> _loadInitialData() async {
    if (_hasLoadedInitialData) return;
    
    // First load city list
    if (cityList.isEmpty) {
      await _loadCityList();
    }
    
    // Then fetch schedule with a delay to avoid rate limiting
    if (mounted && !_hasLoadedInitialData) {
      _hasLoadedInitialData = true;
      // Add delay to prevent HTTP 429 rate limiting
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        await _fetchScheduleWithRetry();
      }
    }
  }

  Future<void> _fetchScheduleWithRetry({int retryCount = 0}) async {
    try {
      final vm = context.read<ShalatViewModel>();
      await vm.fetchMonthlySchedule(
        cityId: cityId,
        year: year,
        month: month,
      );
      
      // If still loading and has error, retry with delay
      if (mounted && vm.error != null && retryCount < 3) {
        final delay = Duration(seconds: (retryCount + 1) * 2);
        await Future.delayed(delay);
        if (mounted) {
          await _fetchScheduleWithRetry(retryCount: retryCount + 1);
        }
      }
    } catch (e) {
      // Retry on exception
      if (mounted && retryCount < 3) {
        final delay = Duration(seconds: (retryCount + 1) * 2);
        await Future.delayed(delay);
        if (mounted) {
          await _fetchScheduleWithRetry(retryCount: retryCount + 1);
        }
      }
    }
  }

  Future<void> _loadCityList() async {
    setState(() => isLoadingCities = true);
    try {
      final cities = await context.read<ShalatViewModel>().repository.getCityList();
      if (mounted) {
        setState(() {
          cityList = cities;
          isLoadingCities = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoadingCities = false);
        // Show error but don't block UI
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat daftar kota: $e'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showMonthYearPicker() {
    showDialog(
      context: context,
      builder: (context) {
        int tempYear = year;
        int tempMonth = month;
        
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                'Pilih Bulan & Tahun',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Year selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () {
                            setDialogState(() => tempYear--);
                          },
                        ),
                        Text(
                          '$tempYear',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () {
                            setDialogState(() => tempYear++);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Month grid
                    GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 2,
                      ),
                      itemCount: 12,
                      itemBuilder: (context, index) {
                        final monthIndex = index + 1;
                        final isSelected = tempMonth == monthIndex;
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() => tempMonth = monthIndex);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              monthNames[index].substring(0, 3),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Batal',
                    style: GoogleFonts.poppins(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      year = tempYear;
                      month = tempMonth;
                    });
                    context.read<ShalatViewModel>().fetchMonthlySchedule(
                      cityId: cityId,
                      year: year,
                      month: month,
                    );
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCityPicker() {
    if (cityList.isEmpty) {
      _loadCityList();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Memuat daftar kota...'),
          duration: Duration(seconds: 1),
        ),
      );
    }
    
    showDialog(
      context: context,
      builder: (context) {
        final vm = context.read<ShalatViewModel>();
        return _CityPickerDialog(
          cityList: cityList,
          currentCityId: vm.selectedCityId,
          onCitySelected: (int selectedCityId, String selectedCityName) {
            vm.selectCity(selectedCityId, selectedCityName);
            vm.fetchMonthlySchedule(
              cityId: selectedCityId,
              year: year,
              month: month,
            );
          },
        );
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only fetch data if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<ShalatViewModel>();
      // Only fetch if no data exists and hasn't been loaded yet
      if (vm.schedules.isEmpty && !_hasLoadedInitialData) {
        _hasLoadedInitialData = true;
        _fetchScheduleWithRetry();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ShalatViewModel>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Jadwal Shalat',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            // City and month in one row
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // City picker
                Expanded(
                  child: GestureDetector(
                    onTap: _showCityPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 11,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              cityName.length > 20 ? '${cityName.substring(0, 20)}...' : cityName,
                              style: GoogleFonts.poppins(
                                fontSize: 9,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withOpacity(0.9),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // Month picker
                Expanded(
                  child: GestureDetector(
                    onTap: _showMonthYearPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_month,
                            size: 11,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${monthNames[month - 1]} $year',
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        flexibleSpace: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Container(),
        ),
      ),
      body: vm.isLoading
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
                    'Memuat data jadwal shalat...',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : vm.error != null
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
                          'Gagal memuat data',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${vm.error}',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await vm.fetchMonthlySchedule(
                      cityId: cityId,
                      year: year,
                      month: month,
                    );
                  },
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    interactive: true,
                    thickness: 6.0,
                    radius: const Radius.circular(8.0),
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      padding: const EdgeInsets.all(16),
                      itemCount: vm.schedules.length,
                    itemBuilder: (_, i) {
                      final d = vm.schedules[i];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ShalatDetailPage(
                                shalatDaySchedule: d,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
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
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: colorScheme.primary.withOpacity(0.1),
                                    ),
                                    child: Icon(
                                      Icons.calendar_today_rounded,
                                      size: 20,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      d.tanggal,
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 16,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              _buildPrayerTimeRow(
                                'Subuh',
                                d.subuh,
                                context,
                                showIcon: true,
                              ),
                              const SizedBox(height: 8),
                              _buildPrayerTimeRow(
                                'Dzuhur',
                                d.dzuhur,
                                context,
                              ),
                              const SizedBox(height: 8),
                              _buildPrayerTimeRow(
                                'Ashar',
                                d.ashar,
                                context,
                              ),
                              const SizedBox(height: 8),
                              _buildPrayerTimeRow(
                                'Maghrib',
                                d.maghrib,
                                context,
                              ),
                              const SizedBox(height: 8),
                              _buildPrayerTimeRow(
                                'Isya',
                                d.isya,
                                context,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  ),
                ),
    );
  }

  Widget _buildPrayerTimeRow(
    String label,
    String value,
    BuildContext context, {
    bool showIcon = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    IconData? prayerIcon;
    if (showIcon) {
      prayerIcon = Icons.wb_sunny_rounded;
    }

    return Row(
      children: [
        if (prayerIcon != null) ...[
          Icon(
            prayerIcon,
            size: 16,
            color: colorScheme.secondary,
          ),
          const SizedBox(width: 8),
        ] else
          const SizedBox(width: 24),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorScheme.secondary,
            ),
          ),
        ),
      ],
    );
  }
}

// City Picker Dialog Widget dengan Search
class _CityPickerDialog extends StatefulWidget {
  final List<Map<String, dynamic>> cityList;
  final int currentCityId;
  final Function(int, String) onCitySelected;

  const _CityPickerDialog({
    required this.cityList,
    required this.currentCityId,
    required this.onCitySelected,
  });

  @override
  State<_CityPickerDialog> createState() => _CityPickerDialogState();
}

class _CityPickerDialogState extends State<_CityPickerDialog> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredCities = widget.cityList.where((city) {
      return city['lokasi'].toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return AlertDialog(
      title: Text(
        'Pilih Kota/Kabupaten',
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: SizedBox(
        width: 400,
        height: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari kota...',
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: widget.cityList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            'Memuat daftar kota...',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : filteredCities.isEmpty
                      ? Center(
                          child: Text(
                            'Kota tidak ditemukan',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredCities.length,
                          itemBuilder: (context, index) {
                            final city = filteredCities[index];
                            // Convert to int to avoid type mismatch
                            final cityId = city['id'] is String 
                                ? int.parse(city['id']) 
                                : city['id'] as int;
                            final isSelected = widget.currentCityId == cityId;
                            return ListTile(
                              title: Text(
                                city['lokasi'],
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                              trailing: isSelected
                                  ? Icon(
                                      Icons.check_circle,
                                      color: Theme.of(context).colorScheme.primary,
                                    )
                                  : null,
                              onTap: () {
                                widget.onCitySelected(cityId, city['lokasi']);
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Batal',
            style: GoogleFonts.poppins(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
