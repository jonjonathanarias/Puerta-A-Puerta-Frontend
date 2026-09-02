import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/producto.dart';
import '../bloc/pedido/pedido_bloc.dart';
import '../bloc/pedido/pedido_event.dart';
import '../bloc/pedido/pedido_state.dart';

class CheckoutPage extends StatelessWidget {
  final Map<Producto, int> carrito;

  const CheckoutPage({super.key, required this.carrito});

  double get _totalPagar {
    return carrito.entries.fold(
      0.0,
          (sum, entry) => sum + (entry.key.precio * entry.value),
    );
  }

  void _confirmarPedido(BuildContext context) {
    final itemsPayload = carrito.entries.map((entry) {
      return {
        'productoId': entry.key.id,
        'cantidad': entry.value,
        'precioUnitario': entry.key.precio,
      };
    }).toList();

    context.read<PedidoBloc>().add(CrearPedidoEvent(items: itemsPayload));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen del Pedido'),
      ),
      body: BlocListener<PedidoBloc, PedidoState>(
        listener: (context, state) {
          if (state is PedidoExitoso) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Pedido enviado con éxito!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(true); // Retorna true para limpiar el carrito en la pantalla anterior
          } else if (state is PedidoError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.mensaje}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: carrito.length,
                  itemBuilder: (context, index) {
                    final producto = carrito.keys.elementAt(index);
                    final cantidad = carrito[producto]!;

                    return ListTile(
                      title: Text(producto.nombre),
                      subtitle: Text('Cantidad: $cantidad x \$${producto.precio.toStringAsFixed(2)}'),
                      trailing: Text(
                        '\$${(producto.precio * cantidad).toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '\$${_totalPagar.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              BlocBuilder<PedidoBloc, PedidoState>(
                builder: (context, state) {
                  if (state is PedidoLoading) {
                    return const CircularProgressIndicator();
                  }

                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _confirmarPedido(context),
                      child: const Text('CONFIRMAR Y ENVIAR PEDIDO', style: TextStyle(fontSize: 16)),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}