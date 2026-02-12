import 'package:flutter/material.dart';
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
  List<String> _allergies = [];
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
  List<String> get allergies => _allergies;
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
    _activityLevel = value;
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

  void setAllergies(List<String> value) {
    _allergies = value;
    notifyListeners();
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
        "allergies": _allergies,
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
