import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/catalogo_bloc.dart';
import '../bloc/catalogo_event.dart';
import '../bloc/catalogo_state.dart';

class CatalogoPage extends StatefulWidget {
  final String localId;

  const CatalogoPage({super.key, required this.localId});

  @override
  State<CatalogoPage> createState() => _CatalogoPageState();
}

class _CatalogoPageState extends State<CatalogoPage> {
  @override
  void initState() {
    super.initState();
    context.read<CatalogoBloc>().add(CargarProductosEvent(localId: widget.localId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catálogo de Productos')),
      body: BlocBuilder<CatalogoBloc, CatalogoState>(
        builder: (context, state) {
          if (state is CatalogoLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CatalogoError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.mensaje),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      context.read<CatalogoBloc>().add(
                        CargarProductosEvent(localId: widget.localId),
                      );
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is CatalogoLoaded) {
            final productos = state.productos;
            if (productos.isEmpty) {
              return const Center(child: Text('No hay productos disponibles'));
            }

            return ListView.builder(
              itemCount: productos.length,
              itemBuilder: (context, index) {
                final prod = productos[index];
                return ListTile(
                  title: Text(prod.nombre),
                  subtitle: Text('\$${prod.precio}'),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}