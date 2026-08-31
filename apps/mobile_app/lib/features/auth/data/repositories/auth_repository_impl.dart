import 'package:puerta_a_puerta_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:puerta_a_puerta_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<String> login(String email, String password) async {
    return await remoteDataSource.login(email, password);
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
  }
}