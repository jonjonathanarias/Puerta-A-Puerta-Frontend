import 'package:dio/dio.dart';
import '../models/producto_model.dart';

abstract class ClienteRemoteDataSource {
  Future<List<ProductoModel>> getProductos();
  Future<void> crearPedido(List<Map<String, dynamic>> items);
}

class ClienteRemoteDataSourceImpl implements ClienteRemoteDataSource {
  final Dio dio;

  ClienteRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ProductoModel>> getProductos() async {
    try {
      final response = await dio.get('/api/v1/productos');
      final list = response.data as List;
      return list.map((e) => ProductoModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al cargar productos');
    }
  }

  @override
  Future<void> crearPedido(List<Map<String, dynamic>> items) async {
    try {
      await dio.post(
        '/api/v1/pedidos',
        data: {'items': items},
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al realizar el pedido');
    }
  }
}