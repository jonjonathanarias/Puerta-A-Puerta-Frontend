import '../entities/producto.dart';

abstract class ClienteRepository {
  Future<List<Producto>> getProductos();
  Future<void> crearPedido(List<Map<String, dynamic>> items);
}