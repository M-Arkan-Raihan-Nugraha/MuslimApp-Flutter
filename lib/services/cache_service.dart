import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const Duration _defaultMaxAge = Duration(days: 7);

  /// Menyimpan data cache dalam bentuk JSON string beserta timestamp
  static Future<void> saveCache(String key, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheData = {
      'timestamp': DateTime.now().toIso8601String(),
      'data': data,
    };
    await prefs.setString(key, json.encode(cacheData));
  }

  /// Membaca data cache, jika belum expired
  static Future<dynamic> getCache(String key, {Duration maxAge = _defaultMaxAge}) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheString = prefs.getString(key);

    if (cacheString == null) return null;

    try {
      final cacheData = json.decode(cacheString);
      final timestamp = DateTime.parse(cacheData['timestamp']);
      final data = cacheData['data'];

      // Cek apakah cache sudah expired
      if (DateTime.now().difference(timestamp) > maxAge) {
        // Hapus cache yang expired
        await prefs.remove(key);
        return null;
      }

      return data;
    } catch (e) {
      // Jika format invalid, hapus data cache
      await prefs.remove(key);
      return null;
    }
  }

  /// Menghapus cache secara spesifik
  static Future<void> removeCache(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
