import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/shalat_schedule_response.dart';
import '../services/cache_service.dart';

class ShalatRepository {
  final http.Client _client;
  static const String cacheKeyCities = 'cache_shalat_cities';
  
  ShalatRepository({http.Client? client}) : _client = client ?? http.Client();

  // Get list of cities with caching
  Future<List<Map<String, dynamic>>> getCityList() async {
    final url = Uri.parse('https://api.myquran.com/v2/sholat/kota/semua');
    
    try {
      final res = await _client.get(url);

      if (res.statusCode == 429) {
        throw Exception('Terlalu banyak permintaan. Silakan tunggu beberapa saat dan coba lagi.');
      }

      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}: gagal ambil data kota');
      }

      final Map<String, dynamic> jsonMap = json.decode(res.body);
      if (jsonMap['status'] != true) {
        throw Exception(jsonMap['message'] ?? 'API status = false');
      }

      final List<dynamic> data = jsonMap['data'] ?? [];
      final cityList = data.map((e) => {
        'id': e['id'],
        'lokasi': e['lokasi'],
      }).toList();
      
      // Save to cache (valid for 30 days)
      await CacheService.saveCache(cacheKeyCities, cityList);
      
      return cityList;
    } catch (e) {
      // Fallback to cache (even if old)
      final cachedData = await CacheService.getCache(cacheKeyCities, maxAge: const Duration(days: 90));
      if (cachedData != null && cachedData is List) {
        return cachedData.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      throw Exception('Gagal memuat data kota dan tidak ada data offline tersedia.');
    }
  }

  Future<ShalatScheduleResponse> getMonthlySchedule({
    required int cityId,
    required int year,
    required int month,
  }) async {
    final cacheKey = 'cache_shalat_schedule_${cityId}_${year}_$month';
    final url = Uri.parse('https://api.myquran.com/v2/sholat/jadwal/$cityId/$year/$month');

    try {
      final res = await _client.get(url);

      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}: gagal ambil data');
      }

      final Map<String, dynamic> jsonMap = json.decode(res.body);
      
      // Save to cache
      await CacheService.saveCache(cacheKey, jsonMap);

      final parsed = ShalatScheduleResponse.fromJson(jsonMap);
      if (!parsed.status) {
        throw Exception(parsed.message ?? 'API status = false');
      }

      return parsed;
    } catch (e) {
      // Fallback to cache
      final cachedData = await CacheService.getCache(cacheKey, maxAge: const Duration(days: 30));
      if (cachedData != null && cachedData is Map<String, dynamic>) {
        return ShalatScheduleResponse.fromJson(cachedData);
      }
      throw Exception('Gagal memuat jadwal shalat dan tidak ada data offline tersedia.');
    }
  }
}