import 'package:flutter/foundation.dart';

import '../models/shalat_schedule_response.dart';
import '../repositories/shalat_repository.dart';

class ShalatViewModel extends ChangeNotifier{
  final ShalatRepository _repo;
  ShalatViewModel(this._repo);

  bool _isLoading = false;
  String? _error;
  List<ShalatDaySchedule> _schedule = [];

  int _selectedCityId = 1206; // Default Cianjur
  String _selectedCityName = 'Kabupaten Cianjur, Jawa Barat';

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ShalatDaySchedule> get schedules => _schedule;
  ShalatRepository get repository => _repo;

  int get selectedCityId => _selectedCityId;
  String get selectedCityName => _selectedCityName;

  void selectCity(int id, String name) {
    _selectedCityId = id;
    _selectedCityName = name;
    notifyListeners();
  }

  Future<void> fetchMonthlySchedule({
    required int cityId,
    required int year,
    required int month,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _repo.getMonthlySchedule(
        cityId: cityId, 
        year: year, 
        month: month
      );
      _schedule = res.schedules;
    } catch (e) {
      _error = e.toString();
      _schedule = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}