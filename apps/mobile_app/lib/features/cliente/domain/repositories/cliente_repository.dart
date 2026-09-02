import '../entities/producto.dart';

abstract class ClienteRepository {
  Future<List<dynamic>> getLocalesCercanos({
    required double lat,
    required double lng,
  });
  Future<List<Producto>> getProductosPorLocal(String localId);
  Future<void> crearPedido(Map<String, dynamic> pedidoPayload);
}