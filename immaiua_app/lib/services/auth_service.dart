import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';

class AuthService {
  late Dio _dio;
  Dio get dio => _dio;
  PersistCookieJar? _cookieJar;

  PersistCookieJar? get cookieJar => _cookieJar;

  // Optional override: flutter run --dart-define=API_BASE_URL=http://<ip>:5000
  static const String _envBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  static String get _baseUrl {
    if (_envBaseUrl.isNotEmpty) return _envBaseUrl;
    if (Platform.isAndroid) return 'http://10.0.2.2:5000';
    if (Platform.isIOS) return 'http://127.0.0.1:5000';
    return 'http://127.0.0.1:5000';
  }

  AuthService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 120),
        receiveTimeout: const Duration(seconds: 120),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) {
          return status! < 500; // Let 4xx pass through so we can handle them
        },
      ),
    );
  }

  Future<void> init() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    print("📂 Cookie Jar Path: $appDocPath/.cookies/"); // DEBUG
    _cookieJar = PersistCookieJar(
      storage: FileStorage("$appDocPath/.cookies/"),
    );
    _dio.interceptors.add(CookieManager(_cookieJar!));

    // DEBUG: Print loaded cookies
    try {
      final cookies = await _cookieJar!.loadForRequest(Uri.parse(_baseUrl));
      print("🍪 Initial Cookies loaded: $cookies");
    } catch (e) {
      print("🍪 Error loading cookies: $e");
    }
  }

  Future<Response> setupProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/register/setup-profile', data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getProfile() async {
    try {
      final response = await _dio.get('/profile/');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/profile/', data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getGoal() async {
    try {
      final response = await _dio.get('/profile/goal');
      return response;
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
      final response = await _dio.put(
        '/profile/goal',
        data: {
          'goal_type': goalType,
          if (targetWeight != null) 'target_weight': targetWeight,
          if (durationMonths != null) 'duration_months': durationMonths,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> updateMacroPercentages({
    required int carbPercent,
    required int proteinPercent,
    required int fatPercent,
  }) async {
    try {
      final response = await _dio.post(
        '/profile/calculate-macros',
        data: {
          'carb_percent': carbPercent,
          'protein_percent': proteinPercent,
          'fat_percent': fatPercent,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getMeals(String date) async {
    try {
      final response = await _dio.get(
        '/meals/',
        queryParameters: {'date': date},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getDailySummary(String date) async {
    try {
      final response = await _dio.get(
        '/meals/daily-summary',
        queryParameters: {'date': date},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getWeeklyAnalytics(String date) async {
    try {
      final response = await _dio.get(
        '/analytics/weekly',
        queryParameters: {'date': date},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getMonthlyAnalytics(String date) async {
    try {
      final response = await _dio.get(
        '/analytics/monthly',
        queryParameters: {'date': date},
      );
      return response;
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

      final response = await _dio.get(
        '/meals/foods',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getCategories() async {
    try {
      final response = await _dio.get('/meals/categories');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getFoodDetails(int foodId) async {
    try {
      final response = await _dio.get('/meals/food/$foodId');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> login(String email, String password) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    // DEBUG
    print("📥 Login Response: ${response.statusCode} - ${response.data}");

    // Safety check for cookieJar
    try {
      if (_cookieJar != null) {
        final cookies = await _cookieJar!.loadForRequest(Uri.parse(_baseUrl));
        print("🍪 Cookies after login: $cookies");
      } else {
        print("⚠️ CookieJar not initialized yet.");
      }
    } catch (e) {
      print("⚠️ Failed to load/print cookies: $e");
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
    // Call API first while cookies are present
    try {
      final response = await _dio.post('/auth/logout');
      // Clear cookies locally
      await _cookieJar?.deleteAll();
      return response;
    } catch (e) {
      // Even if API fails, clear cookies
      await _cookieJar?.deleteAll();
      rethrow;
    }
  }

  Future<Response> logFood(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/meals/logfood', data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> checkAuthStatus() async {
    try {
      final response = await _dio.get('/auth/me');
      print("🕵️ checkAuthStatus Response: ${response.statusCode}"); // DEBUG
      return response.statusCode == 200;
    } catch (e) {
      print("❌ checkAuthStatus Error: $e"); // DEBUG
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
      final response = await _dio.get('/meals/favorites');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getMenus() async {
    try {
      final response = await _dio.get('/meals/menus');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> createMenu(String name, {String? description}) async {
    try {
      final response = await _dio.post(
        '/meals/menus',
        data: {
          'name': name,
          if (description != null && description.isNotEmpty)
            'description': description,
        },
      );
      return response;
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
      final response = await _dio.get(
        '/meals/day-summary',
        queryParameters: {'date': dateStr},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> addCustomFood(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/meals/custom-food', data: data);
      return response;
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

      final response = await _dio.post('/ai/analyze', data: formData);

      return response;
    } catch (e) {
      rethrow;
    }
  }
}
