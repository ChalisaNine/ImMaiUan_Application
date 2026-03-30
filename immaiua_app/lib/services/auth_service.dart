import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import '../models/allergy_option.dart';

class AuthService {
  late Dio _dio;
  Dio get dio => _dio;
  PersistCookieJar? _cookieJar;

  PersistCookieJar? get cookieJar => _cookieJar;

  static const String _envBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get _defaultHost {
    if (kIsWeb) return '127.0.0.1';
    if (Platform.isAndroid) return '10.0.2.2';
    return '127.0.0.1';
  }

  static String get _baseUrl {
    if (_envBaseUrl.isNotEmpty) return _envBaseUrl;
    final ipAddress = (dotenv.env['IP_ADDRESS'] ?? '').trim();
    final apiPort = dotenv.env['API_PORT'] ?? '5001';
    final host = ipAddress.isNotEmpty ? ipAddress : _defaultHost;
    return 'http://$host:$apiPort';
  }

  AuthService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) => status! < 500,
      ),
    );
  }

  Future<void> init() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final appDocPath = appDocDir.path;
    debugPrint('Cookie Jar Path: $appDocPath/.cookies/');
    _cookieJar = PersistCookieJar(
      storage: FileStorage('$appDocPath/.cookies/'),
    );
    _dio.interceptors.add(CookieManager(_cookieJar!));

    try {
      final cookies = await _cookieJar!.loadForRequest(Uri.parse(_baseUrl));
      debugPrint('Initial cookies loaded: ${cookies.length}');
    } catch (e) {
      debugPrint('Error loading cookies: $e');
    }
  }

  Future<Response> setupProfile(Map<String, dynamic> data) async {
    try {
      return await _dio.post('/register/setup-profile', data: data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getProfile() async {
    try {
      return await _dio.get('/profile/');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<AllergyOption>> getAllergyOptions() async {
    try {
      final response = await _dio.get('/profile/allergies/options');
      final rawAllergies = response.data['allergies'] as List<dynamic>? ?? [];
      return rawAllergies
          .whereType<Map<String, dynamic>>()
          .map(AllergyOption.fromJson)
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> updateAllergies(List<int> allergyIds) async {
    try {
      return await _dio.put(
        '/profile/allergies',
        data: {'allergy_ids': allergyIds},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> updateProfile(Map<String, dynamic> data) async {
    try {
      return await _dio.put('/profile/', data: data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getGoal() async {
    try {
      return await _dio.get('/profile/goal');
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> updateGoal({
    required String goalType,
    double? targetWeight,
    int? durationMonths,
  }) async {
    try {
      return await _dio.put(
        '/profile/goal',
        data: {
          'goal_type': goalType,
          if (targetWeight != null) 'target_weight': targetWeight,
          if (durationMonths != null) 'duration_months': durationMonths,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> updateMacroPercentages({
    required int carbPercent,
    required int proteinPercent,
    required int fatPercent,
    int? calorieTarget,
  }) async {
    try {
      return await _dio.post(
        '/profile/calculate-macros',
        data: {
          'carb_percent': carbPercent,
          'protein_percent': proteinPercent,
          'fat_percent': fatPercent,
          if (calorieTarget != null) 'calorie_target': calorieTarget,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getMeals(String date) async {
    try {
      return await _dio.get('/meals/', queryParameters: {'date': date});
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getDailySummary(String date) async {
    try {
      return await _dio.get(
        '/meals/daily-summary',
        queryParameters: {'date': date},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getWeeklyAnalytics(String date) async {
    try {
      return await _dio.get(
        '/analytics/weekly',
        queryParameters: {'date': date},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getMonthlyAnalytics(String date) async {
    try {
      return await _dio.get(
        '/analytics/monthly',
        queryParameters: {'date': date},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getFoodList({
    int? limit,
    int? offset,
    String? search,
    int? categoryId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (categoryId != null) queryParams['category_id'] = categoryId;

      return await _dio.get(
        '/meals/foods',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getCategories() async {
    try {
      return await _dio.get('/meals/categories');
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getFoodDetails(int foodId) async {
    try {
      return await _dio.get('/meals/food/$foodId');
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> login(String email, String password) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    debugPrint('Login response: ${response.statusCode}');

    try {
      if (_cookieJar != null) {
        final cookies = await _cookieJar!.loadForRequest(Uri.parse(_baseUrl));
        debugPrint('Cookies after login: ${cookies.length}');
      } else {
        debugPrint('CookieJar not initialized yet.');
      }
    } catch (e) {
      debugPrint('Failed to inspect cookies: $e');
    }
    return response;
  }

  Future<Response> register(
    String email,
    String password,
    String ageGroup,
  ) async {
    return await _dio.post(
      '/auth/register',
      data: {'email': email, 'password': password, 'age_group': ageGroup},
    );
  }

  Future<Response> logout() async {
    try {
      final response = await _dio.post('/auth/logout');
      await _cookieJar?.deleteAll();
      return response;
    } catch (e) {
      await _cookieJar?.deleteAll();
      rethrow;
    }
  }

  Future<Response> logFood(Map<String, dynamic> data) async {
    try {
      return await _dio.post('/meals/logfood', data: data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> logFoodV2(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/meals/logfood-v2', data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> logFoodAI(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/meals/logfood-ai', data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteMeal(int mealId) async {
    try {
      await _dio.delete('/meals/$mealId');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteMealItem(int mealItemId) async {
    try {
      await _dio.delete('/meals/items/$mealItemId');
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> checkAuthStatus() async {
    try {
      final response = await _dio.get(
        '/auth/me',
        options: Options(receiveTimeout: const Duration(seconds: 5)),
      );
      debugPrint('checkAuthStatus response: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('checkAuthStatus error: $e');
      return false;
    }
  }

  Future<bool> checkFavorite(int foodId) async {
    try {
      final response = await _dio.get('/meals/favorites/check/$foodId');
      return response.data['is_favorite'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> toggleFavorite(int foodId) async {
    try {
      final response = await _dio.post('/meals/favorites/toggle/$foodId');
      return response.data['is_favorite'] == true;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getFavorites() async {
    try {
      return await _dio.get('/meals/favorites');
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getMenus() async {
    try {
      return await _dio.get('/meals/menus');
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> createMenu({
    required String name,
    String? description,
    int? categoryId,
    double? kcal,
    double? protein,
    double? fat,
    double? carb,
    double? sugar,
    double? sodium,
    double? portionQty,
    String? portionUnit,
  }) async {
    try {
      final data = {
        'name': name.trim(),
        if (description != null && description.isNotEmpty)
          'description': description.trim(),
        if (categoryId != null) 'category_id': categoryId,
        if (kcal != null) 'kcal': kcal,
        if (protein != null) 'protein': protein,
        if (fat != null) 'fat': fat,
        if (carb != null) 'carb': carb,
        if (sugar != null) 'sugar': sugar,
        if (sodium != null) 'sodium': sodium,
        if (portionQty != null) 'portion_qty': portionQty,
        if (portionUnit != null && portionUnit.isNotEmpty)
          'portion_unit': portionUnit,
      };

      return await _dio.post('/meals/menus', data: data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> editMenu({
    required int menuId,
    required String name,
    String? description,
    int? categoryId,
    double? kcal,
    double? protein,
    double? fat,
    double? carb,
    double? sugar,
    double? sodium,
    double? portionQty,
    String? portionUnit,
  }) async {
    try {
      final data = {
        'name': name.trim(),
        if (description != null && description.isNotEmpty)
          'description': description.trim(),
        if (categoryId != null) 'category_id': categoryId,
        if (kcal != null) 'kcal': kcal,
        if (protein != null) 'protein': protein,
        if (fat != null) 'fat': fat,
        if (carb != null) 'carb': carb,
        if (sugar != null) 'sugar': sugar,
        if (sodium != null) 'sodium': sodium,
        if (portionQty != null) 'portion_qty': portionQty,
        if (portionUnit != null && portionUnit.isNotEmpty)
          'portion_unit': portionUnit,
      };

      return await _dio.put('/meals/menus/$menuId', data: data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteMenu(int menuId) async {
    try {
      await _dio.delete('/meals/menus/$menuId');
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getDaySummary(DateTime date) async {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    try {
      return await _dio.get(
        '/meals/day-summary',
        queryParameters: {'date': dateStr},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> addCustomFood(Map<String, dynamic> data) async {
    try {
      return await _dio.post('/meals/custom-food', data: data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> analyzeImage(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      return await _dio.post('/ai/analyze', data: formData);
    } catch (e) {
      rethrow;
    }
  }
}
