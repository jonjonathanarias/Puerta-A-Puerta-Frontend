import '../../domain/entities/producto.dart';
import '../../domain/repositories/cliente_repository.dart';
import '../datasources/cliente_remote_datasource.dart';

class ClienteRepositoryImpl implements ClienteRepository {
  final ClienteRemoteDataSource remoteDataSource;

  ClienteRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Producto>> getProductos() async {
    return await remoteDataSource.getProductos();
  }

  @override
  Future<void> crearPedido(List<Map<String, dynamic>> items) async {
    return await remoteDataSource.crearPedido(items);
  }
}