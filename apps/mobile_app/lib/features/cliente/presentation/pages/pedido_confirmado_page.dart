import 'package:flutter/material.dart';

class PedidoConfirmadoPage extends StatelessWidget {
  final String pedidoId;
  final String estadoInicial; // Ej: 'PENDIENTE'

  const PedidoConfirmadoPage({
    super.key,
    required this.pedidoId,
    this.estadoInicial = 'PENDIENTE',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estado del Pedido'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 100,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            Text(
              '¡Pedido #$pedidoId recibido!',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildStep('Pedido Recibido', true),
                    _buildDivider(),
                    _buildStep('En Preparación', false),
                    _buildDivider(),
                    _buildStep('En Camino', false),
                    _buildDivider(),
                    _buildStep('Entregado', false),
                  ],
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Volver al Inicio'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String title, bool isCompleted) {
    return Row(
      children: [
        Icon(
          isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isCompleted ? Colors.blueAccent : Colors.grey,
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
            color: isCompleted ? Colors.black : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.only(left: 11),
      height: 20,
      width: 2,
      color: Colors.grey.shade300,
    );
  }
}