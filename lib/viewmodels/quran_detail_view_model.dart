import 'package:flutter/material.dart';
import '../models/quran_surat_detail_response.dart';
import '../repositories/quran_repository.dart';

class QuranDetailViewModel extends ChangeNotifier {
  final QuranRepository _repository = QuranRepository();

  QuranSuratDetailResponse? detail;
  bool isLoading = false;

  Future<void> fetchDetail(int nomor) async {
    isLoading = true;
    notifyListeners();

    detail = await _repository.getSuratDetail(nomor);

    isLoading = false;
    notifyListeners();
  }
}
