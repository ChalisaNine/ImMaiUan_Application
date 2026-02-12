import 'package:flutter/material.dart';
import 'package:immaiua_app/services/auth_service.dart';

class MealProvider extends ChangeNotifier {
  final AuthService _authService;

  MealProvider(this._authService);

  List<dynamic> _meals = [];
  List<dynamic> _foodList = [];
  Map<String, dynamic>? _dailySummary;
  bool _isLoading = false;
  String? _error;

  List<dynamic> get meals => _meals;
  List<dynamic> get foodList => _foodList;
  Map<String, dynamic>? get dailySummary => _dailySummary;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Flattened list of food items from all meals today
  List<Map<String, dynamic>> get todayItems {
    final List<Map<String, dynamic>> items = [];
    for (var meal in _meals) {
      if (meal['items'] != null) {
        for (var item in meal['items']) {
          items.add({
            'name': item['food_name'],
            'calories': item['calories'],
            'meal_type': meal['meal_type'],
            'time': meal['meal_time'],
            'quantity': item['quantity'],
          });
        }
      }
    }
    return items;
  }

  Future<void> fetchMeals(String date) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.getMeals(date);
      if (response.statusCode == 200) {
        _meals = response.data;
      } else {
        _error = "Failed to load meals";
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchFoods() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.getFoodList();
      if (response.statusCode == 200) {
        _foodList = response.data;
      } else {
        _error = "Failed to load food list";
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDailySummary(String date) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.getDailySummary(date);
      if (response.statusCode == 200) {
        _dailySummary = response.data;
      } else {
        _error = "Failed to load daily summary";
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Calculate total calories consumed today
  int get totalCalories {
    int total = 0;
    for (var item in todayItems) {
      total += (item['calories'] as num).toInt();
    }
    return total;
  }
}
