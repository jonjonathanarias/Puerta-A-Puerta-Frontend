import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/producto.dart';
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
  final Map<Producto, int> _carrito = {};

  @override
  void initState() {
    super.initState();
    context.read<CatalogoBloc>().add(CargarProductosEvent(localId: widget.localId));
  }

  void _incrementarProducto(Producto producto) {
    setState(() {
      _carrito[producto] = (_carrito[producto] ?? 0) + 1;
    });
  }

  void _decrementarProducto(Producto producto) {
    if (!_carrito.containsKey(producto)) return;
    setState(() {
      if (_carrito[producto]! > 1) {
        _carrito[producto] = _carrito[producto]! - 1;
      } else {
        _carrito.remove(producto);
      }
    });
  }

  int get _totalItems => _carrito.values.fold(0, (sum, count) => sum + count);

  double get _montoTotal =>
      _carrito.entries.fold(0, (sum, entry) => sum + (entry.key.precio * entry.value));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ClienteAppBar(
        titulo: 'Catálogo de Productos',
        accionesAdicionales: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: _totalItems > 0 ? _irAlCheckout : null,
              ),
              if (_totalItems > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: CircleAvatar(
                    radius: 9,
                    backgroundColor: Colors.redAccent,
                    child: Text(
                      '$_totalItems',
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
                final cantidad = _carrito[prod] ?? 0;

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
                            onPressed: () => _decrementarProducto(prod),
                          ),
                          Text('$cantidad', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: Colors.blueAccent),
                          onPressed: () => _incrementarProducto(prod),
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
      bottomNavigationBar: _totalItems > 0
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
                Text('Items: $_totalItems', style: const TextStyle(color: Colors.grey)),
                Text(
                  '\$${_montoTotal.toStringAsFixed(2)}',
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
  }

  void _irAlCheckout() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CheckoutPage(
          localId: widget.localId,
          itemsCarrito: _carrito,
        ),
      ),
    );
  }
}