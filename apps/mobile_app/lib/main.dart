import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'core/api/dio_client.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/pages/login_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  const storage = FlutterSecureStorage();

  final dioClient = DioClient(
    storage: storage,
    baseUrl: 'http://localhost:3000',
  );

  final authDataSource = AuthRemoteDataSourceImpl(
    dio: dioClient.dio,
    storage: storage,
  );
  final authRepository = AuthRepositoryImpl(remoteDataSource: authDataSource);

  runApp(
    MyApp(
      authRepository: authRepository,
      storage: storage,
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthRepositoryImpl authRepository;
  final FlutterSecureStorage storage;

  const MyApp({
    super.key,
    required this.authRepository,
    required this.storage,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(
        authRepository: authRepository,
        storage: storage, // <-- Pases la instancia de storage requerida
      )..add(AuthCheckRequested()), // <-- Verifica si ya existe token al iniciar
      child: MaterialApp(
        title: 'Puerta a Puerta',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
          useMaterial3: true,
        ),
        home: const LoginPage(),
      ),
    );
  }
}