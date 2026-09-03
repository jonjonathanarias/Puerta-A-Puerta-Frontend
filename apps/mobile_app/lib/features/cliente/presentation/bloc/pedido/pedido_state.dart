import 'package:equatable/equatable.dart';

abstract class PedidoState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PedidoInitial extends PedidoState {}
class PedidoLoading extends PedidoState {}
class PedidoExitoso extends PedidoState {
  final String? pedidoId; // Agrega esta propiedad

  PedidoExitoso({this.pedidoId});
}

class PedidoError extends PedidoState {
  final String mensaje;

  PedidoError({required this.mensaje});

  @override
  List<Object?> get props => [mensaje];
}