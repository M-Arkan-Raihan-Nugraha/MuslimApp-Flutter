import 'package:flutter/material.dart';
import '../models/asmaul_husna_response.dart';
import '../repositories/asmaul_husna_repository.dart';

class AsmaulHusnaViewModel extends ChangeNotifier {
  final AsmaulHusnaRepository _repository = AsmaulHusnaRepository();

  List<AsmaulHusna> names = [];
  bool isLoading = false;
  String? error;

  Future<void> fetchAsmaulHusna() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      names = await _repository.getAsmaulHusna();
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
