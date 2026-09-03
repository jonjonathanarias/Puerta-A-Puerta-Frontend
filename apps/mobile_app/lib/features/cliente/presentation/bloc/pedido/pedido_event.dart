// pedido_event.dart

abstract class PedidoEvent {}

class CrearPedidoEvent extends PedidoEvent {
  final String localId;
  final String direccionEntrega;
  final String? notas;
  final List<Map<String, dynamic>> items;
  final double? latitud;
  final double? longitud;

  CrearPedidoEvent({
    required this.localId,
    required this.direccionEntrega,
    this.notas,
    required this.items,
    this.latitud,
    this.longitud,
  });
}