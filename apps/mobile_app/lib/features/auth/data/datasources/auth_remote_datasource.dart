import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthRemoteDataSource {
  Future<String> login(String email, String password);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  final FlutterSecureStorage storage;

  AuthRemoteDataSourceImpl({required this.dio, required this.storage});

  @override
  Future<String> login(String email, String password) async {
    try {
      final response = await dio.post(
        '/api/v1/auth/login',
        data: {'email': email, 'password': password},
      );

      final token = response.data['token'] as String;
      await storage.write(key: 'jwt_token', value: token);
      return token;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error de autenticación');
    }
  }

  @override
  Future<void> logout() async {
    await storage.delete(key: 'jwt_token');
  }
}