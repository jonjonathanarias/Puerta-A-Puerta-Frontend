import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Core
import 'core/api/api_client.dart';

// Features: Auth
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';

// Features: Cliente
import 'features/cliente/data/datasources/cliente_remote_datasource.dart';
import 'features/cliente/data/repositories/cliente_repository_impl.dart';
import 'features/cliente/domain/repositories/cliente_repository.dart';
import 'features/cliente/presentation/bloc/catalogo_bloc.dart';
import 'features/cliente/presentation/bloc/pedido/pedido_bloc.dart';
import 'features/cliente/presentation/pages/locales_page.dart';

// Features: Repartidor
import 'features/repartidor/presentation/pages/hoja_ruta_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  const storage = FlutterSecureStorage();

  // Cliente HTTP centralizado (contiene Dio + Interceptores JWT)
  final apiClient = ApiClient();

  // Auth Data Source & Repository
  final authDataSource = AuthRemoteDataSourceImpl(
    dio: apiClient.dio,
    storage: storage,
  );
  final authRepository = AuthRepositoryImpl(remoteDataSource: authDataSource);

  // Cliente Data Source & Repository
  final clienteDataSource = ClienteRemoteDataSourceImpl(apiClient: apiClient);
  final clienteRepository = ClienteRepositoryImpl(remoteDataSource: clienteDataSource);

  runApp(
    MyApp(
      authRepository: authRepository,
      clienteRepository: clienteRepository,
      storage: storage,
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthRepositoryImpl authRepository;
  final ClienteRepository clienteRepository;
  final FlutterSecureStorage storage;

  const MyApp({
    super.key,
    required this.authRepository,
    required this.clienteRepository,
    required this.storage,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ClienteRepository>.value(
          value: clienteRepository,
        ),
        RepositoryProvider<AuthRepositoryImpl>.value(
          value: authRepository,
        ),
      ],
      child: MultiBlocProvider(
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
          BlocProvider(
            create: (context) => PedidoBloc(
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
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                return state.role == 'repartidor'
                    ? const HojaRutaPage()
                    : const LocalesPage();
              }
              if (state is AuthLoading) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              return const LoginPage();
            },
          ),
        ),
      ),
    );
  }
}