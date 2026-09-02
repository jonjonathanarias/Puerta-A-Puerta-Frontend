import 'package:equatable/equatable.dart';

abstract class PedidoEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CrearPedidoEvent extends PedidoEvent {
  final List<Map<String, dynamic>> items;

  CrearPedidoEvent({required this.items});

  @override
  List<Object?> get props => [items];
}