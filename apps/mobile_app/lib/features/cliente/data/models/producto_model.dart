import '../../domain/entities/producto.dart';

class ProductoModel extends Producto {
  const ProductoModel({
    required super.id,
    required super.nombre,
    required super.descripcion,
    required super.precio,
    super.imagenUrl,
  });

  factory ProductoModel.fromJson(Map<String, dynamic> json) {
    return ProductoModel(
      id: json['id'].toString(),
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      precio: (json['precio'] as num).toDouble(),
      imagenUrl: json['imagenUrl'],
    );
  }
}