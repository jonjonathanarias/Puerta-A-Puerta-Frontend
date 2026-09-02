import 'package:equatable/equatable.dart';

abstract class CatalogoEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CargarProductosEvent extends CatalogoEvent {
  final String localId;

  CargarProductosEvent({required this.localId});

  @override
  List<Object?> get props => [localId];
}