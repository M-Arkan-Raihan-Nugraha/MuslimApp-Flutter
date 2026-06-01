import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quran_surat_response.dart';
import '../models/quran_surat_detail_response.dart';
import '../services/cache_service.dart';

class QuranRepository {
  final String baseUrl = 'https://equran.id/api/v2/surat';
  static const String cacheKeyAllSurat = 'cache_quran_all_surat';
  
  // Helper to convert tempatTurun to classification
  String _getSuratClassification(String tempatTurun) {
    if (tempatTurun.toLowerCase().contains('mekkah') || 
        tempatTurun.toLowerCase().contains('mekah')) {
      return 'Makkiyah';
    } else if (tempatTurun.toLowerCase().contains('madinah')) {
      return 'Madaniyah';
    }
    return tempatTurun;
  }

  Future<List<QuranSuratResponse>> getAllSurat() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      final body = json.decode(response.body);
      final List<dynamic> data = body['data'];
      
      // Convert tempatTurun to Makkiyah/Madaniyah
      final result = data.map((e) {
        final modifiedJson = Map<String, dynamic>.from(e);
        modifiedJson['tempatTurun'] = _getSuratClassification(e['tempatTurun']);
        return QuranSuratResponse.fromJson(modifiedJson);
      }).toList();
      
      // Save to cache
      await CacheService.saveCache(cacheKeyAllSurat, data);
      
      return result;
    } catch (e) {
      // Return cache if offline
      final cachedData = await CacheService.getCache(cacheKeyAllSurat);
      if (cachedData != null && cachedData is List) {
        return cachedData.map((e) {
          final modifiedJson = Map<String, dynamic>.from(e);
          modifiedJson['tempatTurun'] = _getSuratClassification(e['tempatTurun']);
          return QuranSuratResponse.fromJson(modifiedJson);
        }).toList();
      }
      throw Exception('Gagal memuat Al-Quran dan tidak ada data offline tersedia. Pastikan perangkat Anda terhubung ke internet.');
    }
  }

  Future<QuranSuratDetailResponse> getSuratDetail(int nomor) async {
    final cacheKey = 'cache_quran_surat_$nomor';
    
    try {
      final response = await http.get(Uri.parse('$baseUrl/$nomor'));
      final body = json.decode(response.body);
      final data = body['data'];
      
      // Save to cache
      await CacheService.saveCache(cacheKey, data);
      
      // Convert tempatTurun to Makkiyah/Madaniyah
      final modifiedData = Map<String, dynamic>.from(data);
      modifiedData['tempatTurun'] = _getSuratClassification(data['tempatTurun']);
      
      return QuranSuratDetailResponse.fromJson(modifiedData);
    } catch (e) {
      // Return cache if offline
      final cachedData = await CacheService.getCache(cacheKey);
      if (cachedData != null) {
        final modifiedData = Map<String, dynamic>.from(cachedData);
        modifiedData['tempatTurun'] = _getSuratClassification(cachedData['tempatTurun']);
        return QuranSuratDetailResponse.fromJson(modifiedData);
      }
      throw Exception('Gagal memuat detail surat dan tidak ada data offline tersedia.');
    }
  }
}
