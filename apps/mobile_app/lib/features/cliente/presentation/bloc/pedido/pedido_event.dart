import 'package:equatable/equatable.dart';

abstract class PedidoEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CrearPedidoEvent extends PedidoEvent {
  final String localId;
  final List<Map<String, dynamic>> items;

  CrearPedidoEvent({
    required this.localId,
    required this.items,
  });

  @override
  List<Object?> get props => [localId, items];
}