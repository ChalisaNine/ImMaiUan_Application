import 'package:flutter/material.dart';
import '../activity_level_options.dart';
import '../models/allergy_option.dart';
import '../services/auth_service.dart';

class ProfileSetupProvider extends ChangeNotifier {
  final AuthService _authService;

  ProfileSetupProvider(this._authService);

  // State
  String? _gender;
  String? _activityLevel;
  double? _height;
  double? _weight;
  String? _goal;
  double? _targetWeight;
  int? _durationMonths;
  List<AllergyOption> _allergies = [];
  String? _name;
  String? _dob; // MM/DD/YYYY

  bool _isLoading = false;
  String? _error;

  // Getters
  String? get gender => _gender;
  String? get activityLevel => _activityLevel;
  double? get height => _height;
  double? get weight => _weight;
  String? get goal => _goal;
  double? get targetWeight => _targetWeight;
  int? get durationMonths => _durationMonths;
  List<AllergyOption> get allergies => _allergies;
  String? get name => _name;
  String? get dob => _dob;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Setters
  void setGender(String value) {
    _gender = value;
    notifyListeners();
  }

  void setActivityLevel(String value) {
    _activityLevel = normalizeActivityLevel(value) ?? value;
    notifyListeners();
  }

  void setBodyStats(double height, double weight) {
    _height = height;
    _weight = weight;
    notifyListeners();
  }

  void setGoal(String value) {
    _goal = value;
    notifyListeners();
  }

  void setTargetWeight(double? value) {
    _targetWeight = value;
    notifyListeners();
  }

  void setDurationMonths(int? value) {
    _durationMonths = value;
    notifyListeners();
  }

  void setAllergies(List<AllergyOption> value) {
    _allergies = value;
    notifyListeners();
  }

  Future<List<AllergyOption>> fetchAllergyOptions() {
    return _authService.getAllergyOptions();
  }

  void setPersonalInfo(String name, String dob) {
    _name = name;
    _dob = dob;
    notifyListeners();
  }

  // Submit
  Future<bool> submitProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = {
        "gender": _gender,
        "activity_level": _activityLevel,
        "height": _height,
        "weight": _weight,
        "goal": _goal,
        "target_weight": _targetWeight,
        "duration_months": _durationMonths,
        "allergy_ids": _allergies.map((allergy) => allergy.id).toList(),
        "allergies": _allergies.map((allergy) => allergy.name).toList(),
        "name": _name,
        "dob": _dob,
      };

      await _authService.setupProfile(data);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
