import 'package:dio/dio.dart';

/// Centralized API client for making HTTP requests
class ApiClient {
  late final Dio _dio;
  
  // TODO: Update this URL based on where your backend is running
  // For Android emulator: use http://10.0.2.2:8000
  // For iOS simulator: use http://localhost:8000
  // For physical device: use your computer's IP address (e.g., http://192.168.1.100:8000)
  static const String baseUrl = 'http://localhost:8000';

  ApiClient({String? customBaseUrl}) {
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

    // Add logging interceptor for debugging
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => print('[API] $obj'),
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
