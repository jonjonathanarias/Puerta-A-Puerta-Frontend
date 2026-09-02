import 'package:equatable/equatable.dart';
import '../../domain/entities/producto.dart';

abstract class CatalogoState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CatalogoInitial extends CatalogoState {}

class CatalogoLoading extends CatalogoState {}

class CatalogoLoaded extends CatalogoState {
  final List<Producto> productos; // Usa la entidad de dominio

  CatalogoLoaded({required this.productos});

  @override
  List<Object?> get props => [productos];
}

class CatalogoError extends CatalogoState {
  final String mensaje;

  CatalogoError({required this.mensaje});

  @override
  List<Object?> get props => [mensaje];
}