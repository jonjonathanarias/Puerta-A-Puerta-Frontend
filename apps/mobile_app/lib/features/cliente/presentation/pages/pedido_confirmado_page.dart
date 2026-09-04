import 'package:flutter/material.dart';

class PedidoConfirmadoPage extends StatelessWidget {
  final String pedidoId;
  final String? nombreCliente;

  const PedidoConfirmadoPage({
    super.key,
    required this.pedidoId,
    this.nombreCliente,
  });

  @override
  Widget build(BuildContext context) {
    final cliente = (nombreCliente != null && nombreCliente!.isNotEmpty)
        ? nombreCliente
        : 'Cliente';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estado del Pedido'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 90,
              ),
              const SizedBox(height: 16),
              Text(
                '¡El pedido de $cliente ha sido recibido!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Código: ${pedidoId.length > 8 ? pedidoId.substring(0, 8) : pedidoId}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // Timeline de estados del pedido
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: const [
                      _EstadoItem(
                        titulo: 'Pedido Recibido',
                        completado: true,
                        activo: true,
                      ),
                      _EstadoItem(
                        titulo: 'En Preparación',
                        completado: false,
                        activo: false,
                      ),
                      _EstadoItem(
                        titulo: 'En Camino',
                        completado: false,
                        activo: false,
                      ),
                      _EstadoItem(
                        titulo: 'Entregado',
                        completado: false,
                        activo: false,
                        esUltimo: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 12),
                ),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Volver al Inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EstadoItem extends StatelessWidget {
  final String titulo;
  final bool completado;
  final bool activo;
  final bool esUltimo;

  const _EstadoItem({
    required this.titulo,
    required this.completado,
    required this.activo,
    this.esUltimo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            Icon(
              completado ? Icons.check_circle : Icons.radio_button_unchecked,
              color: completado ? Colors.blueAccent : Colors.grey,
            ),
            if (!esUltimo)
              Container(
                width: 2,
                height: 24,
                color: completado ? Colors.blueAccent : Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 12),
        Text(
          titulo,
          style: TextStyle(
            fontWeight: activo ? FontWeight.bold : FontWeight.normal,
            color: activo ? Colors.black : Colors.grey[600],
          ),
        ),
      ],
    );
  }
}