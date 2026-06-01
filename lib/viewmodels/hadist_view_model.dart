import 'package:flutter/material.dart';
import '../models/hadist_book_response.dart';
import '../models/hadist_detail_response.dart';
import '../repositories/hadist_repository.dart';

class HadistViewModel extends ChangeNotifier {
  final HadistRepository _repository = HadistRepository();

  List<HadistBook> books = [];
  List<HadistDetail> hadists = [];
  bool isLoadingBooks = false;
  bool isLoadingHadists = false;
  String? error;

  Future<void> fetchBooks() async {
    isLoadingBooks = true;
    error = null;
    notifyListeners();

    try {
      books = await _repository.getBooks();
    } catch (e) {
      error = e.toString();
    }

    isLoadingBooks = false;
    notifyListeners();
  }

  Future<void> fetchHadists(String bookId, int start, int end) async {
    isLoadingHadists = true;
    error = null;
    hadists = [];
    notifyListeners();

    try {
      hadists = await _repository.getHadists(bookId, start, end);
    } catch (e) {
      error = e.toString();
    }

    isLoadingHadists = false;
    notifyListeners();
  }
}
