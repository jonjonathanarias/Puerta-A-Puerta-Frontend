import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/producto.dart';
import '../bloc/pedido/pedido_bloc.dart';
import '../bloc/pedido/pedido_event.dart';
import '../bloc/pedido/pedido_state.dart';
import '../widgets/cliente_app_bar.dart';

class CheckoutPage extends StatefulWidget {
  final String localId;
  final Map<Producto, int> itemsCarrito;

  const CheckoutPage({
    super.key,
    required this.localId,
    required this.itemsCarrito,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _direccionController = TextEditingController();
  final _observacionesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _direccionController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  double get _montoTotal => widget.itemsCarrito.entries
      .fold(0, (sum, entry) => sum + (entry.key.precio * entry.value));

  void _confirmarPedido() {
    if (_formKey.currentState?.validate() ?? false) {
      final itemsPayload = widget.itemsCarrito.entries.map((e) {
        return {
          'producto_id': e.key.id,
          'cantidad': e.value,
          'precio_unitario': e.key.precio,
        };
      }).toList();

      // Disparar el evento con los parámetros explícitos
      context.read<PedidoBloc>().add(
        CrearPedidoEvent(
          localId: widget.localId,
          items: itemsPayload,
          direccionEntrega: _direccionController.text.trim(),
          observaciones: _observacionesController.text.trim(),
          montoTotal: _montoTotal,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ClienteAppBar(titulo: 'Confirmar Pedido'),
      body: BlocListener<PedidoBloc, PedidoState>(
        listener: (context, state) {
          if (state is PedidoExitoso) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Pedido registrado con éxito!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (state is PedidoError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensaje),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const Text(
                  'Resumen de Productos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: widget.itemsCarrito.entries
                        .map(
                          (entry) => ListTile(
                        title: Text(entry.key.nombre),
                        subtitle: Text('Cantidad: ${entry.value}'),
                        trailing: Text(
                          '\$${(entry.key.precio * entry.value).toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                        .toList(),
                  ),
                ),
                const Divider(height: 32),
                const Text(
                  'Datos de Entrega',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _direccionController,
                  decoration: const InputDecoration(
                    labelText: 'Dirección de Entrega',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  validator: (val) =>
                  val == null || val.isEmpty ? 'Ingresa una dirección' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _observacionesController,
                  decoration: const InputDecoration(
                    labelText: 'Observaciones (Opcional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.notes),
                  ),
                ),
                const SizedBox(height: 32),
                BlocBuilder<PedidoBloc, PedidoState>(
                  builder: (context, state) {
                    if (state is PedidoLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _confirmarPedido,
                      child: Text(
                        'FINALIZAR PEDIDO (\$${_montoTotal.toStringAsFixed(2)})',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}