import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../api_config.dart';
import '../firebase_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return ApiClient(auth: auth);
});

/// Centralized API client for making HTTP requests
class ApiClient {
  late final Dio _dio;
  final FirebaseAuth? _auth;
  
  static const String baseUrl = ApiConfig.baseUrl;

  ApiClient({FirebaseAuth? auth, String? customBaseUrl}) : _auth = auth {
    _dio = Dio(
      BaseOptions(
        baseUrl: customBaseUrl ?? baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add Auth token interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final user = _auth?.currentUser;
            if (user != null) {
              final token = await user.getIdToken();
              options.headers['Authorization'] = 'Bearer $token';
            }
          } catch (e) {
            debugPrint('[ApiClient] Error getting auth token: $e');
          }
          return handler.next(options);
        },
      ),
    );

    // Add logging interceptor for debugging
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => debugPrint('[API] $obj'),
      ),
    );
  }

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle Dio errors and convert to user-friendly messages
  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException('Connection timeout. Please check your internet connection.');
      
      case DioExceptionType.connectionError:
        return ApiException(
          'Cannot connect to server. Please ensure the backend is running at $baseUrl',
        );
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        return ApiException(
          'Server error (${statusCode ?? 'unknown'}). Please try again later.',
        );
      
      case DioExceptionType.cancel:
        return ApiException('Request cancelled.');
      
      default:
        return ApiException('An unexpected error occurred: ${error.message}');
    }
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  
  ApiException(this.message);
  
  @override
  String toString() => message;
}
