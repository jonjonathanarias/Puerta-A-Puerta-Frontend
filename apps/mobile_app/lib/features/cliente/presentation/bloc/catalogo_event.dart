abstract class PedidoEvent {}

abstract class CatalogoEvent {}

class CargarProductosEvent extends CatalogoEvent {
  final String localId;

  CargarProductosEvent({required this.localId});
}

class CrearPedidoEvent extends PedidoEvent {
  final String localId;
  final List<Map<String, dynamic>> items;
  final String direccionEntrega;
  final double montoTotal;
  final String? observaciones;

  CrearPedidoEvent({
    required this.localId,
    required this.items,
    required this.direccionEntrega,
    required this.montoTotal,
    this.observaciones,
  });
}

