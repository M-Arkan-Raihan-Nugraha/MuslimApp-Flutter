import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/asmaul_husna_response.dart';
import '../services/cache_service.dart';

class AsmaulHusnaRepository {
  final String url = 'https://asmaul-husna-api.vercel.app/api/all';
  static const String cacheKey = 'cache_asmaul_husna';

  Future<List<AsmaulHusna>> getAsmaulHusna() async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final List data = body['data'] ?? [];
        
        // Save to cache
        await CacheService.saveCache(cacheKey, data);
        
        return data.map((e) => AsmaulHusna.fromJson(e)).toList();
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to cache
      final cachedData = await CacheService.getCache(cacheKey);
      if (cachedData != null && cachedData is List) {
        return cachedData.map((e) => AsmaulHusna.fromJson(e)).toList();
      }
      throw Exception('Gagal memuat Asmaul Husna dan tidak ada data offline.');
    }
  }
}
