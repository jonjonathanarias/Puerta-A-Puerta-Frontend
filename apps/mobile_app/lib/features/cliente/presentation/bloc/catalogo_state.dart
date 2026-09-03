import '../../domain/entities/producto.dart';

abstract class CatalogoState {}

class CatalogoInitial extends CatalogoState {}

class CatalogoLoading extends CatalogoState {}

class CatalogoLoaded extends CatalogoState {
  final List<Producto> productos;

  CatalogoLoaded({required this.productos});
}

class CatalogoError extends CatalogoState {
  final String mensaje;

  CatalogoError({required this.mensaje});
}