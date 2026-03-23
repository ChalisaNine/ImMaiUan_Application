import 'package:flutter/material.dart';
import '../models/allergy_option.dart';
import '../services/auth_service.dart';

class UserProvider extends ChangeNotifier {
  final AuthService _authService;

  UserProvider(this._authService);

  Map<String, dynamic>? _profile;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.getProfile();
      if (response.statusCode == 200) {
        _profile = response.data;
      } else {
        _error = "Failed to load profile";
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _authService.updateProfile(data);
      if (response.statusCode == 200) {
        // Refresh profile data
        await fetchProfile();
        return true;
      }
      _error = "Update failed";
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateGoal({
    required String goalType,
    double? targetWeight,
    int? durationMonths,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _authService.updateGoal(
        goalType: goalType,
        targetWeight: targetWeight,
        durationMonths: durationMonths,
      );
      if (response.statusCode == 200) {
        await fetchProfile();
        return true;
      }
      _error = response.data?['error']?.toString() ?? "Goal update failed";
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<AllergyOption>> fetchAllergyOptions() {
    return _authService.getAllergyOptions();
  }

  Future<bool> updateAllergies(List<int> allergyIds) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _authService.updateAllergies(allergyIds);
      if (response.statusCode == 200) {
        await fetchProfile();
        return true;
      }
      _error = response.data?['error']?.toString() ?? "Allergy update failed";
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
