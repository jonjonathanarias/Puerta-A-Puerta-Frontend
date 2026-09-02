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
        await clienteRepository.crearPedido(event.items);
        emit(PedidoExitoso());
      } catch (e) {
        emit(PedidoError(mensaje: e.toString().replaceAll('Exception: ', '')));
      }
    });
  }
}