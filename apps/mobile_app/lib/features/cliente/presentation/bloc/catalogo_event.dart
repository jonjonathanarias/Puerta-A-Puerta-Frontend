import 'package:equatable/equatable.dart';

abstract class CatalogoEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CargarProductosEvent extends CatalogoEvent {}