import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'core/api/dio_client.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/pages/login_page.dart';

import 'features/cliente/data/datasources/cliente_remote_datasource.dart';
import 'features/cliente/data/repositories/cliente_repository_impl.dart';
import 'features/cliente/presentation/bloc/catalogo_bloc.dart';

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

  // Instancias para Cliente
  final clienteDataSource = ClienteRemoteDataSourceImpl(dio: dioClient.dio);
  final clienteRepository = ClienteRepositoryImpl(remoteDataSource: clienteDataSource);

  runApp(
    MyApp(
      authRepository: authRepository,
      clienteRepository: clienteRepository,
      storage: storage,    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthRepositoryImpl authRepository;
  final ClienteRepositoryImpl clienteRepository;
  final FlutterSecureStorage storage;

  const MyApp({
    super.key,
    required this.authRepository,
    required this.clienteRepository,
    required this.storage,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            authRepository: authRepository,
            storage: storage,
          )..add(AuthCheckRequested()),
        ),
        BlocProvider(
          create: (context) => CatalogoBloc(
            clienteRepository: clienteRepository,
          ),
        ),
      ],
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