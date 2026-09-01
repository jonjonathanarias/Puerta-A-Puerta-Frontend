import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/cliente_repository.dart';
import 'catalogo_event.dart';
import 'catalogo_state.dart';

class CatalogoBloc extends Bloc<CatalogoEvent, CatalogoState> {
  final ClienteRepository clienteRepository;

  CatalogoBloc({required this.clienteRepository}) : super(CatalogoInitial()) {
    on<CargarProductosEvent>((event, emit) async {
      emit(CatalogoLoading());
      try {
        final productos = await clienteRepository.getProductos();
        emit(CatalogoLoaded(productos: productos));
      } catch (e) {
        emit(CatalogoError(meassage: e.toString().replaceAll('Exception: ', '')));
      }
    });
  }
}