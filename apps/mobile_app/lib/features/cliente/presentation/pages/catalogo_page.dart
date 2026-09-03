import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/producto.dart';
import '../bloc/carrito_bloc.dart';
import '../bloc/catalogo_bloc.dart';
import '../bloc/catalogo_event.dart';
import '../bloc/catalogo_state.dart';
import '../widgets/cliente_app_bar.dart';
import 'checkout_page.dart';

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

  void _irAlCheckout() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CheckoutPage(localId: widget.localId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CarritoBloc, CarritoState>(
      builder: (context, carritoState) {
        return Scaffold(
          appBar: ClienteAppBar(
            titulo: 'Catálogo de Productos',
            accionesAdicionales: [
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: carritoState.totalItems > 0 ? _irAlCheckout : null,
                  ),
                  if (carritoState.totalItems > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: CircleAvatar(
                        radius: 9,
                        backgroundColor: Colors.redAccent,
                        child: Text(
                          '${carritoState.totalItems}',
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          body: BlocBuilder<CatalogoBloc, CatalogoState>(
            builder: (context, state) {
              if (state is CatalogoLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is CatalogoError) {
                return Center(child: Text(state.mensaje));
              }

              if (state is CatalogoLoaded) {
                if (state.productos.isEmpty) {
                  return const Center(child: Text('No hay productos disponibles'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: state.productos.length,
                  itemBuilder: (context, index) {
                    final prod = state.productos[index];
                    final cantidad = carritoState.items[prod] ?? 0;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(prod.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('\$${prod.precio.toStringAsFixed(2)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (cantidad > 0) ...[
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                                onPressed: () {
                                  context.read<CarritoBloc>().add(RemoverProductoEvent(prod));
                                },
                              ),
                              Text('$cantidad', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, color: Colors.blueAccent),
                              onPressed: () {
                                context.read<CarritoBloc>().add(AgregarProductoEvent(prod));
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }

              return const SizedBox.shrink();
            },
          ),
          bottomNavigationBar: carritoState.totalItems > 0
              ? Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Items: ${carritoState.totalItems}', style: const TextStyle(color: Colors.grey)),
                    Text(
                      '\$${carritoState.montoTotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _irAlCheckout,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Ver Pedido'),
                ),
              ],
            ),
          )
              : null,
        );
      },
    );
  }
}