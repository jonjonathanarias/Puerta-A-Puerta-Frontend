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
        final Map<String, dynamic> payload = {
          'localId': event.localId,
          'direccionEntrega': event.direccionEntrega,
          'items': event.items,
          if (event.notas != null && event.notas!.trim().isNotEmpty)
            'notas': event.notas!.trim(),
          if (event.latitud != null) 'latitud': event.latitud,
          if (event.longitud != null) 'longitud': event.longitud,
        };

        final pedidoId = await clienteRepository.crearPedido(payload);
        emit(PedidoExitoso(pedidoId: pedidoId));
      } catch (e) {
        emit(PedidoError(mensaje: e.toString().replaceAll('Exception: ', '')));
      }
    });
  }
}