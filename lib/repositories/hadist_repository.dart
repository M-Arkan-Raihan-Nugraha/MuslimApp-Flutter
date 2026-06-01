import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/hadist_book_response.dart';
import '../models/hadist_detail_response.dart';
import '../services/cache_service.dart';

class HadistRepository {
  final String baseUrl = 'https://api.hadith.gading.dev';
  static const String cacheKeyAllBooks = 'cache_hadist_books';

  Future<List<HadistBook>> getBooks() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/books'));

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final List data = body['data'] ?? [];
        
        // Save to cache
        await CacheService.saveCache(cacheKeyAllBooks, data);
        
        return data.map((e) => HadistBook.fromJson(e)).toList();
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to cache
      final cachedData = await CacheService.getCache(cacheKeyAllBooks);
      if (cachedData != null && cachedData is List) {
        return cachedData.map((e) => HadistBook.fromJson(e)).toList();
      }
      throw Exception('Gagal memuat daftar kitab hadits dan tidak ada data offline.');
    }
  }

  Future<List<HadistDetail>> getHadists(String bookId, int start, int end) async {
    final cacheKey = 'cache_hadist_${bookId}_${start}_$end';
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/books/$bookId?range=$start-$end'),
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final Map<String, dynamic> data = body['data'] ?? {};
        final List hadistsList = data['hadiths'] ?? [];
        
        // Save to cache
        await CacheService.saveCache(cacheKey, hadistsList);
        
        return hadistsList.map((e) => HadistDetail.fromJson(e)).toList();
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to cache
      final cachedData = await CacheService.getCache(cacheKey);
      if (cachedData != null && cachedData is List) {
        return cachedData.map((e) => HadistDetail.fromJson(e)).toList();
      }
      throw Exception('Gagal memuat daftar hadits untuk range $start-$end.');
    }
  }
}
