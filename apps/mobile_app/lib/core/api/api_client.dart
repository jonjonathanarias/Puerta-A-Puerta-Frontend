import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static const String baseUrl = 'http://10.0.2.2:3000/api/v1'; // 10.0.2.2 es el localhost para el emulador de Android Studio
  final Dio dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    headers: {'accept': '*/*', 'Content-Type': 'application/json'},
  ));
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiClient() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'jwt_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            // Manejar expiración de sesión si es necesario
          }
          return handler.next(e);
        },
      ),
    );
  }
}