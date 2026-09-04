import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/cliente_repository.dart';
import '../widgets/cliente_app_bar.dart';

class MisPedidosPage extends StatefulWidget {
  const MisPedidosPage({super.key});

  @override
  State<MisPedidosPage> createState() => _MisPedidosPageState();
}

class _MisPedidosPageState extends State<MisPedidosPage> {
  bool _cargando = true;
  String? _error;
  List<dynamic> _pedidos = [];

  @override
  void initState() {
    super.initState();
    _cargarPedidos();
  }

  Future<void> _cargarPedidos() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final repository = context.read<ClienteRepository>();
      final result = await repository.getMisPedidos();
      if (mounted) {
        setState(() {
          _pedidos = result;
          _cargando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _cargando = false;
        });
      }
    }
  }

  Color _obtenerColorEstado(String? estado) {
    switch (estado?.toLowerCase()) {
      case 'creado':
      case 'recibido':
        return Colors.orange;
      case 'en_preparacion':
        return Colors.blue;
      case 'en_camino':
        return Colors.purple;
      case 'entregado':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ClienteAppBar(titulo: 'Mis Pedidos'),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _cargarPedidos,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_pedidos.isEmpty) {
      return const Center(child: Text('No tienes pedidos registrados.'));
    }

    return RefreshIndicator(
      onRefresh: _cargarPedidos,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _pedidos.length,
        itemBuilder: (context, index) {
          final pedido = _pedidos[index];
          final estado = pedido['estado'] ?? 'creado';
          final id = pedido['id'] ?? 'N/A';
          final monto = pedido['monto_total'] ?? '0.00';
          final direccion = pedido['direccion_entrega'] ?? 'Sin dirección';

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _obtenerColorEstado(estado).withOpacity(0.2),
                child: Icon(
                  Icons.local_shipping,
                  color: _obtenerColorEstado(estado),
                ),
              ),
              title: Text(
                'Pedido #${id.toString().substring(0, 8)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('$direccion\nTotal: \$$monto'),
              isThreeLine: true,
              trailing: Chip(
                label: Text(
                  estado.toString().toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
                backgroundColor: _obtenerColorEstado(estado),
              ),
            ),
          );
        },
      ),
    );
  }
}