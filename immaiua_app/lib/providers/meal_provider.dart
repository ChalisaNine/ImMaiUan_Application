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

  // Pagination state
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _offset = 0;
  final int _limit = 20;
  String _searchQuery = '';

  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String get searchQuery => _searchQuery;

  Future<void> fetchFoods({bool reset = false, String? search}) async {
    // Handle search query changes
    if (search != null && search != _searchQuery) {
      _searchQuery = search;
      reset = true; // Reset pagination when search changes
    }

    // Reset pagination if requested
    if (reset) {
      _offset = 0;
      _foodList = [];
      _hasMore = true;
    }

    // Prevent multiple simultaneous requests
    if (_isLoading || _isLoadingMore || !_hasMore) return;

    // Set appropriate loading state
    if (_offset == 0) {
      _isLoading = true;
    } else {
      _isLoadingMore = true;
    }
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.getFoodList(
        limit: _limit,
        offset: _offset,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Handle the new response structure with pagination metadata
        if (data is Map && data.containsKey('foods')) {
          final foods = data['foods'] as List;

          if (reset) {
            _foodList = foods;
          } else {
            _foodList.addAll(foods);
          }

          _hasMore = data['has_more'] ?? false;
          _offset += foods.length;
        } else {
          // Fallback for old response format (backwards compatibility)
          if (reset) {
            _foodList = data;
          } else {
            _foodList.addAll(data);
          }
          _hasMore = false; // No more data if using old format
        }

        _error = null;
      } else {
        _error = "Failed to load food list";
        _hasMore = false;
      }
    } catch (e) {
      _error = e.toString();
      _hasMore = false;
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Clear search and reset list
  void clearSearch() {
    if (_searchQuery.isNotEmpty) {
      _searchQuery = '';
      fetchFoods(reset: true);
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
