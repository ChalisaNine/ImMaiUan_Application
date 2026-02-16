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

  // Base URL for Android Emulator (10.0.2.2) or iOS Simulator (127.0.0.1)
  // Adjust this based on where the Flask server is running.
  // Assuming localhost for now, but for Android emulator use 10.0.2.2
  static const String _baseUrl = 'http://127.0.0.1:5000';

  AuthService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
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

  Future<Response> getFoodList({
    int? limit,
    int? offset,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _dio.get(
        '/meals/foods',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
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
}
