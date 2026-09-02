import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../cliente/domain/entities/producto.dart';
import '../../../cliente/presentation/bloc/catalogo_bloc.dart';
import '../../../cliente/presentation/bloc/catalogo_event.dart';
import '../../../cliente/presentation/bloc/catalogo_state.dart';
import '../../../cliente/presentation/pages/checkout_page.dart';

class CatalogoPage extends StatefulWidget {
  const CatalogoPage({super.key});

  @override
  State<CatalogoPage> createState() => _CatalogoPageState();
}

class _CatalogoPageState extends State<CatalogoPage> {
  // Almacena localmente las cantidades seleccionadas: {productoId: cantidad}
  final Map<String, int> _carrito = {};

  @override
  void initState() {
    super.initState();
    // Dispara la carga de productos al iniciar la vista
    context.read<CatalogoBloc>().add(CargarProductosEvent());
  }

  void _incrementar(String id) {
    setState(() {
      _carrito[id] = (_carrito[id] ?? 0) + 1;
    });
  }

  void _decrementar(String id) {
    if ((_carrito[id] ?? 0) > 0) {
      setState(() {
        _carrito[id] = _carrito[id]! - 1;
        if (_carrito[id] == 0) {
          _carrito.remove(id);
        }
      });
    }
  }

  int get _totalItems => _carrito.values.fold(0, (sum, item) => sum + item);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Productos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],
      ),
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
                  Text(
                    'Error: ${state.meassage}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<CatalogoBloc>().add(CargarProductosEvent()),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is CatalogoLoaded) {
            if (state.productos.isEmpty) {
              return const Center(child: Text('No hay productos disponibles.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.productos.length,
              itemBuilder: (context, index) {
                final producto = state.productos[index];
                final cantidad = _carrito[producto.id] ?? 0;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent.shade100,
                      child: Text(
                        producto.nombre.isNotEmpty ? producto.nombre[0].toUpperCase() : 'P',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      producto.nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(producto.descripcion),
                        const SizedBox(height: 4),
                        Text(
                          '\$${producto.precio.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (cantidad > 0) ...[
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                            onPressed: () => _decrementar(producto.id),
                          ),
                          Text(
                            '$cantidad',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
                          onPressed: () => _incrementar(producto.id),
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
        color: Colors.blueAccent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Items seleccionados: $_totalItems',
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blueAccent,
              ),
              onPressed: () async {
                final state = context.read<CatalogoBloc>().state;
                if (state is CatalogoLoaded) {
                  final Map<Producto, int> carritoDetalle = {};

                  _carrito.forEach((id, cantidad) {
                    final producto = state.productos.firstWhere((p) => p.id == id);
                    carritoDetalle[producto] = cantidad;
                  });

                  final seEnvioPedido = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => CheckoutPage(carrito: carritoDetalle),
                    ),
                  );

                  if (seEnvioPedido == true) {
                    setState(() {
                      _carrito.clear();
                    });
                  }
                }
              },
              child: const Text('VER PEDIDO'),
            ),
          ],
        ),
      )
          : null,
    );
  }
}