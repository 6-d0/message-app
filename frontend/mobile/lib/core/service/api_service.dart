import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio();
  static String? baseurl;
  String? _jwtToken;
  bool get hasToken => _jwtToken != null;
  String? _refreshToken;
  static ApiService? _instance;

  static ApiService get instance {
    _instance ??= ApiService();
    return _instance!;
  }

  ApiService() {
    _dio.options.baseUrl = '$baseurl';
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.headers = {
      'Content-Type': 'application/json',
    };

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_jwtToken != null) {
          options.headers['Authorization'] = 'Bearer $_jwtToken';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          try {
            await _refreshJwtToken();
            final options = error.requestOptions;
            options.headers['Authorization'] = 'Bearer $_jwtToken';
            final response = await _dio.fetch(options);
            return handler.resolve(response);
          } catch (e) {
            return handler.reject(error);
          }
        }
        return handler.next(error);
      },
    ));
  }

  void setTokens(String jwtToken, String refreshToken) {
    _jwtToken = jwtToken;
    _refreshToken = refreshToken;
    _dio.options.headers['Authorization'] = 'Bearer $jwtToken';
  }

  Future<void> _refreshJwtToken() async {
    if (_refreshToken == null) {
      throw Exception('Refresh token is null');
    }
    try {
      final response = await _dio.post('/auth/refresh/', data: {
        'refresh': _refreshToken,
      });
      _jwtToken = response.data['access'];
      _refreshToken = response.data['refresh'];
      _dio.options.headers['Authorization'] = 'Bearer $_jwtToken';
    } catch (e) {
      throw Exception('Failed to refresh token');
    }
  }

  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Response> post(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Response> put(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return response;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Response> delete(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.delete(endpoint, data: data);
      return response;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      return 'Erreur ${error.response?.statusCode}: ${error.response?.data}';
    } else {
      return 'Erreur réseau: ${error.message}';
    }
  }
}