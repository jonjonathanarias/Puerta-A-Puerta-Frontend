import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../domain/entities/producto.dart';
import '../../domain/repositories/cliente_repository.dart';
import '../datasources/cliente_remote_datasource.dart';

class ClienteRepositoryImpl implements ClienteRepository {
  final ClienteRemoteDataSource remoteDataSource;
  final ApiClient apiClient;

  ClienteRepositoryImpl({
    required this.remoteDataSource,
    required this.apiClient,
  });

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
  Future<String> crearPedido(Map<String, dynamic> pedidoPayload) async {
    try {
      final response = await apiClient.dio.post('/pedidos', data: pedidoPayload);
      // Retornamos el ID generado por el backend
      return response.data['data']['id'];
    } on DioException catch (e) {
      final mensajeError = e.response?.data?['mensaje'] ??
          e.response?.data?['message'] ??
          'Error al registrar el pedido';
      throw Exception(mensajeError);
    }
  }

  @override
  Future<List<dynamic>> getMisPedidos() async {
    try {
      // Hace el GET a /api/v1/pedidos y la API filtra automáticamente por el JWT
      final response = await apiClient.dio.get('/pedidos');
      return response.data['data'] as List<dynamic>;
    } on DioException catch (e) {
      final msg = e.response?.data?['mensaje'] ?? 'Error al obtener pedidos';
      throw Exception(msg);
    }
  }
}