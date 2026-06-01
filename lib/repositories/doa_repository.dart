import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/doa_response.dart';
import '../services/cache_service.dart';

class DoaRepository {
  final String baseUrl = 'https://equran.id/api/doa';
  static const String cacheKeyAllDoa = 'cache_doa_all';

  Future<List<DoaResponse>> getAllDoa() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List dataList;
        if (decoded is List) {
          dataList = decoded;
        } else if (decoded is Map && decoded['data'] is List) {
          dataList = decoded['data'];
        } else {
          throw Exception('Format data tidak valid');
        }
        
        // Save to cache
        await CacheService.saveCache(cacheKeyAllDoa, dataList);
        
        return dataList.map((e) => DoaResponse.fromJson(e)).toList();
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to cache
      final cachedData = await CacheService.getCache(cacheKeyAllDoa);
      if (cachedData != null && cachedData is List) {
        return cachedData.map((e) => DoaResponse.fromJson(e)).toList();
      }
      throw Exception('Gagal memuat data doa dan tidak ada data offline tersedia.');
    }
  }
}