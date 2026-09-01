import 'package:equatable/equatable.dart';

class Producto extends Equatable {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String? imagenUrl;

  const Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    this.imagenUrl,
  });

  @override
  List<Object?> get props => [id, nombre, descripcion, precio, imagenUrl];
}