import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String role; // 'cliente', 'repartidor', 'comercio'

  const User({
    required this.id,
    required this.email,
    required this.role,
  });

  @override
  List<Object?> get props => [id, email, role];
}