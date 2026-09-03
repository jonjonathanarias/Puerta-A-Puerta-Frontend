import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/producto.dart';

// Eventos
abstract class CarritoEvent {}

class AgregarProductoEvent extends CarritoEvent {
  final Producto producto;
  AgregarProductoEvent(this.producto);
}

class RemoverProductoEvent extends CarritoEvent {
  final Producto producto;
  RemoverProductoEvent(this.producto);
}

class LimpiarCarritoEvent extends CarritoEvent {}

// Estado
class CarritoState {
  final Map<Producto, int> items;

  CarritoState({this.items = const {}});

  int get totalItems => items.values.fold(0, (sum, count) => sum + count);

  double get montoTotal =>
      items.entries.fold(0, (sum, e) => sum + (e.key.precio * e.value));
}

// BLoC
class CarritoBloc extends Bloc<CarritoEvent, CarritoState> {
  CarritoBloc() : super(CarritoState()) {
    on<AgregarProductoEvent>((event, emit) {
      final nuevosItems = Map<Producto, int>.from(state.items);
      nuevosItems[event.producto] = (nuevosItems[event.producto] ?? 0) + 1;
      emit(CarritoState(items: nuevosItems));
    });

    on<RemoverProductoEvent>((event, emit) {
      final nuevosItems = Map<Producto, int>.from(state.items);
      if (nuevosItems.containsKey(event.producto)) {
        if (nuevosItems[event.producto]! > 1) {
          nuevosItems[event.producto] = nuevosItems[event.producto]! - 1;
        } else {
          nuevosItems.remove(event.producto);
        }
        emit(CarritoState(items: nuevosItems));
      }
    });

    on<LimpiarCarritoEvent>((event, emit) {
      emit(CarritoState(items: const {}));
    });
  }
}