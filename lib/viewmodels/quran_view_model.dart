import 'package:flutter/material.dart';
import '../models/quran_surat_response.dart';
import '../repositories/quran_repository.dart';

class QuranViewModel extends ChangeNotifier {
  final QuranRepository _repository = QuranRepository();

  List<QuranSuratResponse> suratList = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchAllSurat() async {
    isLoading = true;
    notifyListeners();

    try {
      suratList = await _repository.getAllSurat();
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
