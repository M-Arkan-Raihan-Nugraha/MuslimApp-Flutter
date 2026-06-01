import 'package:flutter/material.dart';
import '../models/doa_response.dart';
import '../repositories/doa_repository.dart';

class DoaViewModel extends ChangeNotifier {
  final DoaRepository _repository = DoaRepository();

  List<DoaResponse> doaList = [];
  bool isLoading = false;
  String? error;

  Future<void> fetchDoa() async {
    isLoading = true;
    notifyListeners();

    try {
      doaList = await _repository.getAllDoa();
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
