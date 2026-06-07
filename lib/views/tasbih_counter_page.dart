import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class TasbihCounterPage extends StatefulWidget {
  const TasbihCounterPage({super.key});

  @override
  State<TasbihCounterPage> createState() => _TasbihCounterPageState();
}

class _TasbihCounterPageState extends State<TasbihCounterPage> {
  int _count = 0;
  int _target = 33;
  final List<int> _targets = [33, 99, 100];

  void _increment() {
    // Prevent incrementing if already reached target
    if (_count >= _target) {
      return;
    }

    setState(() {
      _count++;
      if (_count >= _target) {
        // Strong vibration sequence when target reached
        HapticFeedback.heavyImpact();
        Future.delayed(const Duration(milliseconds: 150), () {
          HapticFeedback.heavyImpact();
        });
        Future.delayed(const Duration(milliseconds: 300), () {
          HapticFeedback.heavyImpact();
        });
        // Show completion dialog after vibration
        Future.delayed(const Duration(milliseconds: 450), () {
          if (mounted) {
            _showCompletionDialog();
          }
        });
      } else {
        // Light vibration on each count
        HapticFeedback.mediumImpact();
      }
    });
  }

  void _reset() {
    setState(() {
      _count = 0;
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Alhamdulillah!',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Anda telah menyelesaikan $_target tasbih',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Tutup',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = _count / _target;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tasbih Counter',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  // Target selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _targets.map((target) {
                      final isSelected = target == _target;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _target = target;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$target',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 40),
                  // Count display
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary.withOpacity(0.85),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$_count',
                          style: GoogleFonts.poppins(
                            fontSize: 56,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                        Text(
                          '/ $_target',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: colorScheme.onPrimary.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Progress bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  // Controls
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Reset button
                        GestureDetector(
                          onTap: _reset,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colorScheme.surfaceContainerHighest,
                            ),
                            child: Icon(
                              Icons.refresh_rounded,
                              size: 28,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 32),
                        // Count button
                        GestureDetector(
                          onTap: _count >= _target ? null : _increment,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: _count >= _target
                                  ? LinearGradient(
                                      colors: [
                                        colorScheme.surfaceContainerHighest,
                                        colorScheme.surfaceContainerHighest,
                                      ],
                                    )
                                  : LinearGradient(
                                      colors: [
                                        colorScheme.primary,
                                        colorScheme.primary.withOpacity(0.85),
                                      ],
                                    ),
                              boxShadow: _count >= _target
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: colorScheme.primary.withOpacity(0.3),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                            ),
                            child: Icon(
                              _count >= _target ? Icons.check_rounded : Icons.add_rounded,
                              size: 48,
                              color: _count >= _target
                                  ? colorScheme.onSurfaceVariant
                                  : colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ],
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
}
