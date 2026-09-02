import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../models/producto_model.dart';

abstract class ClienteRemoteDataSource {
  Future<List<ProductoModel>> getProductosPorLocal(String localId);
  Future<List<dynamic>> getLocalesCercanos({
    required double lat,
    required double lng,
  });
  Future<void> crearPedido(Map<String, dynamic> pedidoPayload);
}

class ClienteRemoteDataSourceImpl implements ClienteRemoteDataSource {
  final ApiClient apiClient;

  ClienteRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ProductoModel>> getProductosPorLocal(String localId) async {
    try {
      final response = await apiClient.dio.get('/locales/$localId/productos');

      if (response.statusCode == 200) {
        final List<dynamic> productosJson = response.data['data']['productos'];

        return productosJson
            .map((json) => ProductoModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Error al obtener productos');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error al obtener productos del local',
      );
    }
  }

  @override
  Future<List<dynamic>> getLocalesCercanos({
    required double lat,
    required double lng,
  }) async {
    try {
      final response = await apiClient.dio.get(
        '/locales/cercanos',
        queryParameters: {'lat': lat, 'lng': lng},
      );

      if (response.statusCode == 200) {
        return response.data['data']['locales'] ?? [];
      } else {
        throw Exception('Error al obtener locales cercanos');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error al conectar con el servidor',
      );
    }
  }

  @override
  Future<void> crearPedido(Map<String, dynamic> pedidoPayload) async {
    try {
      await apiClient.dio.post('/pedidos', data: pedidoPayload);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error al registrar el pedido',
      );
    }
  }
}