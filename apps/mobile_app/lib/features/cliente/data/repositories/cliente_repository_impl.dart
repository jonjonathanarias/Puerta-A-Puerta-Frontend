import '../../domain/entities/producto.dart';
import '../../domain/repositories/cliente_repository.dart';
import '../datasources/cliente_remote_datasource.dart';

class ClienteRepositoryImpl implements ClienteRepository {
  final ClienteRemoteDataSource remoteDataSource;

  ClienteRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Producto>> getProductosPorLocal(String localId) async {
    return await remoteDataSource.getProductosPorLocal(localId);
  }

  @override
  Future<List<dynamic>> getLocalesCercanos({
    required double lat,
    required double lng,
  }) async {
    return await remoteDataSource.getLocalesCercanos(lat: lat, lng: lng);
  }

  @override
  Future<void> crearPedido(Map<String, dynamic> pedidoPayload) async {
    await remoteDataSource.crearPedido(pedidoPayload);
  }
}