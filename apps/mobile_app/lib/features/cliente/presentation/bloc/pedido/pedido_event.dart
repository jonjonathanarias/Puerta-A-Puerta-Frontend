abstract class PedidoEvent {}

class CrearPedidoEvent extends PedidoEvent {
  final String localId;
  final List<Map<String, dynamic>> items;
  final String direccionEntrega;
  final String? observaciones;
  final double montoTotal;

  CrearPedidoEvent({
    required this.localId,
    required this.items,
    required this.direccionEntrega,
    required this.montoTotal,
    this.observaciones,
  });
}