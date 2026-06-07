import 'package:flutter/material.dart';
import 'package:muslim_app/views/kiblat_page.dart';
import 'package:muslim_app/views/settings_page.dart';

import 'home_page.dart';
import 'quran_page.dart';
import 'doa_page.dart';
import 'shalat_page.dart';
import 'sunnah_shalat_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  static final ValueNotifier<int> tabIndex = ValueNotifier(0);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final pages = const [
    HomePage(),
    ShalatPage(),
    SunnahShalatPage(),
    QuranPage(),
    DoaPage(),
    KiblatPage(),
    SettingsPage(),
  ];

  // Map pages index to bottom nav index (or -1 if not in nav)
  int _getBottomNavIndex(int pageIndex) {
    switch (pageIndex) {
      case 0: return 0; // Home
      case 1: return 1; // Shalat
      case 2: return -1; // Sunnah - not in bottom nav
      case 3: return 2; // Quran
      case 4: return 3; // Doa
      case 5: return -1; // Kiblat - not in bottom nav
      case 6: return 4; // Settings
      default: return 0;
    }
  }

  // Map bottom nav index to pages index
  int _getPageIndex(int navIndex) {
    switch (navIndex) {
      case 0: return 0; // Home
      case 1: return 1; // Shalat
      case 2: return 3; // Quran
      case 3: return 4; // Doa
      case 4: return 6; // Settings
      default: return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: MainPage.tabIndex,
      builder: (_, index, __) {
        return Scaffold(
          body: IndexedStack(
            index: index,
            children: pages,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _getBottomNavIndex(index) >= 0 ? _getBottomNavIndex(index) : 0,
              onTap: (i) => MainPage.tabIndex.value = _getPageIndex(i),
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              unselectedItemColor: const Color(0xFF999999),
              selectedFontSize: 11,
              unselectedFontSize: 10,
              iconSize: 24,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(
                    _getBottomNavIndex(index) == 0 ? Icons.home_rounded : Icons.home_outlined,
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    _getBottomNavIndex(index) == 1 ? Icons.access_time_filled : Icons.access_time,
                  ),
                  label: 'Shalat',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    _getBottomNavIndex(index) == 2 ? Icons.menu_book_rounded : Icons.menu_book,
                  ),
                  label: 'Al-Quran',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    _getBottomNavIndex(index) == 3 ? Icons.favorite_rounded : Icons.favorite_border,
                  ),
                  label: 'Doa',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    _getBottomNavIndex(index) == 4 ? Icons.settings : Icons.settings_outlined,
                  ),
                  label: 'Setting',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
