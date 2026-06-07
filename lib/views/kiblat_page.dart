import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

class KiblatPage extends StatefulWidget {
  const KiblatPage({super.key});

  @override
  State<KiblatPage> createState() => _KiblatPageState();
}

class _KiblatPageState extends State<KiblatPage> {
  PermissionStatus? _permissionStatus;
  Position? _location;
  double? _qiblaAngle;
  String? _error;

  // Koordinat Ka'bah
  static const double _kaabaLatitude = 21.4225;
  static const double _kaabaLongitude = 39.8262;

  @override
  void initState() {
    super.initState();
    _checkPermissionStatus();
  }

  // --- 1. Manajemen Izin & Lokasi ---

  Future<void> _checkPermissionStatus() async {
    final status = await Permission.location.status;
    if (mounted) {
      setState(() => _permissionStatus = status);
      if (status.isGranted) {
        _getLocation();
      }
    }
  }

  Future<void> _requestPermission() async {
    final status = await Permission.location.request();
    if (mounted) {
      setState(() {
        _permissionStatus = status;
      });
      if (status.isGranted) {
        _getLocation();
      }
    }
  }

  Future<void> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled && mounted) {
      setState(() {
        _error = 'Layanan lokasi (GPS) tidak aktif. Harap aktifkan untuk melanjutkan.';
      });
      return;
    }

    setState(() {
      _error = null;
      _location = null;
      _qiblaAngle = null;
    });
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 20),
      );
      if (mounted) {
        setState(() {
          _location = position;
          _qiblaAngle =
              _calculateQiblaAngle(position.latitude, position.longitude);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e is TimeoutException
              ? "Gagal mendapatkan lokasi: Waktu habis. Pastikan sinyal GPS Anda kuat."
              : "Gagal mendapatkan lokasi. Pastikan izin dan layanan lokasi sudah benar.";
        });
      }
    }
  }

  // --- 2. Kalkulasi ---

  double _calculateQiblaAngle(double lat, double lon) {
    final lonRad = _toRadians(lon);
    final latRad = _toRadians(lat);
    final kaabaLonRad = _toRadians(_kaabaLongitude);
    final kaabaLatRad = _toRadians(_kaabaLatitude);

    final dLon = kaabaLonRad - lonRad;
    final y = math.sin(dLon);
    final x = math.cos(latRad) * math.tan(kaabaLatRad) -
        math.sin(latRad) * math.cos(dLon);
    final angle = math.atan2(y, x);

    return (_toDegrees(angle) + 360) % 360;
  }

  double _toRadians(double degrees) => degrees * (math.pi / 180.0);
  double _toDegrees(double radians) => radians * (180.0 / math.pi);

  // --- 3. UI Build ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Arah Kiblat',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final colorScheme = Theme.of(context).colorScheme;

    if (_permissionStatus == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Memuat...',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }
    if (_permissionStatus!.isDenied) {
      return _buildPermissionUI(
        'Izin Lokasi Diperlukan',
        'Untuk menentukan arah kiblat, aplikasi ini memerlukan akses ke lokasi Anda.',
        'Berikan Izin',
        _requestPermission,
      );
    }
    if (_permissionStatus!.isPermanentlyDenied) {
      return _buildPermissionUI(
        'Izin Lokasi Dinonaktifkan',
        'Anda telah menonaktifkan izin lokasi secara permanen. Harap buka pengaturan aplikasi untuk mengaktifkannya.',
        'Buka Pengaturan',
        openAppSettings,
      );
    }
    if (_error != null) {
      return _buildInfoUI('Terjadi Kesalahan', _error!, 'Coba Lagi', _getLocation);
    }
    if (!_permissionStatus!.isGranted ||
        _location == null ||
        _qiblaAngle == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Sedang mendapatkan lokasi Anda...',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildInfoUI(
            'Error Kompas',
            'Tidak dapat membaca sensor kompas. Coba kalibrasi dengan menggerakkan ponsel membentuk angka 8.',
            'Coba Lagi',
            _checkPermissionStatus,
          );
        }
        if (!snapshot.hasData) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Mengkalibrasi kompas...',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );
        }

        double? heading = snapshot.data!.heading;
        if (heading == null) {
          return _buildInfoUI(
            'Sensor Tidak Ditemukan',
            'Perangkat ini tidak memiliki sensor kompas.',
            'OK',
            () {},
          );
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Posisikan ponsel Anda secara mendatar',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                QiblaCompass(heading: heading, qiblaAngle: _qiblaAngle!),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
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
                        '${_qiblaAngle!.toStringAsFixed(1)}°',
                        style: GoogleFonts.poppins(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'dari arah Utara',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: colorScheme.onPrimary.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        color: colorScheme.secondary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Lat: ${_location?.latitude.toStringAsFixed(3)}, Lon: ${_location?.longitude.toStringAsFixed(3)}",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPermissionUI(
    String title,
    String message,
    String buttonText,
    VoidCallback onPressed,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_off_rounded,
            size: 64,
            color: colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onPressed,
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoUI(
    String title,
    String message,
    String buttonText,
    VoidCallback onPressed,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: colorScheme.error.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onPressed,
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}

// --- 4. Widget Kompas ---

class QiblaCompass extends StatelessWidget {
  final double heading;
  final double qiblaAngle;

  const QiblaCompass({
    super.key,
    required this.heading,
    required this.qiblaAngle,
  });

  double _toRadians(double degrees) => degrees * (math.pi / 180.0);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final double qiblaIndicatorAngle = _toRadians(qiblaAngle - heading);

    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring with shadow
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
          // Inner gradient ring
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withOpacity(0.1),
                  colorScheme.primary.withOpacity(0.05),
                ],
              ),
            ),
          ),
          // Rotating compass dial
          Transform.rotate(
            angle: _toRadians(-heading),
            child: CustomPaint(
              size: const Size.square(280),
              painter: _CompassDialPainter(colorScheme: colorScheme),
            ),
          ),
          // Qibla direction indicator (mosque icon)
          Transform.rotate(
            angle: qiblaIndicatorAngle,
            child: SizedBox(
              width: 280,
              height: 280,
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.primary,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/icon/app_icon.png',
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
          // Center dot
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.primary,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
          ),
          // North indicator arrow
          Positioned(
            top: 8,
            child: Icon(
              Icons.arrow_drop_up_rounded,
              size: 40,
              color: Colors.red.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

// --- 5. Painter Kustom untuk Dial Kompas ---

class _CompassDialPainter extends CustomPainter {
  final ColorScheme colorScheme;

  _CompassDialPainter({required this.colorScheme});

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);

    // Draw tick marks

    for (int i = 0; i < 360; i += 5) {
      final double angle = (i - 90) * (math.pi / 180);
      final bool isMajor = i % 90 == 0;
      final bool isMinor = i % 30 == 0;
      final double tickLength = isMajor ? 18 : (isMinor ? 12 : 6);

      final Offset start = center +
          Offset(
            math.cos(angle) * (radius - 10),
            math.sin(angle) * (radius - 10),
          );
      final Offset end = center +
          Offset(
            math.cos(angle) * (radius - 10 - tickLength),
            math.sin(angle) * (radius - 10 - tickLength),
          );

      canvas.drawLine(
        start,
        end,
        Paint()
          ..color = isMajor
              ? colorScheme.primary
              : colorScheme.onSurface.withOpacity(0.4)
          ..strokeWidth = isMajor ? 2.5 : (isMinor ? 1.5 : 1),
      );
    }

    // Draw direction labels
    for (int i = 0; i < 360; i += 15) {
      final double angle = (i - 90) * (math.pi / 180);
      final double textRadius = radius - 35;

      String label;
      TextStyle style;

      if (i % 90 == 0) {
        label = (i == 0) ? 'N' : (i == 90) ? 'E' : (i == 180) ? 'S' : 'W';
        style = GoogleFonts.poppins(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        );
      } else if (i % 45 == 0) {
        label = (i == 45) ? 'NE' : (i == 135) ? 'SE' : (i == 225) ? 'SW' : 'NW';
        style = GoogleFonts.poppins(
          color: colorScheme.onSurface.withOpacity(0.7),
          fontWeight: FontWeight.w600,
          fontSize: 12,
        );
      } else {
        continue;
      }

      final TextPainter textPainter = TextPainter(
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        text: TextSpan(text: label, style: style),
      );
      textPainter.layout();

      final Offset textOffset = center +
          Offset(
            math.cos(angle) * textRadius - textPainter.width / 2,
            math.sin(angle) * textRadius - textPainter.height / 2,
          );

      textPainter.paint(canvas, textOffset);
    }
  }

  @override
  bool shouldRepaint(_CompassDialPainter oldDelegate) {
    return oldDelegate.colorScheme != colorScheme;
  }
}
