import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/cliente_repository.dart';
import 'pedido_event.dart';
import 'pedido_state.dart';

class PedidoBloc extends Bloc<PedidoEvent, PedidoState> {
  final ClienteRepository clienteRepository;

  PedidoBloc({required this.clienteRepository}) : super(PedidoInitial()) {
    on<CrearPedidoEvent>((event, emit) async {
      emit(PedidoLoading());
      try {
        final payload = {
          'localId': event.localId,
          'direccionEntrega': event.direccionEntrega,
          'notas': event.notas,
          'items': event.items,
          if (event.latitud != null) 'latitud': event.latitud,
          if (event.longitud != null) 'longitud': event.longitud,
        };

        await clienteRepository.crearPedido(payload);
        emit(PedidoExitoso(pedidoId: 'N/A'));
      } catch (e) {
        emit(PedidoError(mensaje: e.toString().replaceAll('Exception: ', '')));
      }
    });
  }
}