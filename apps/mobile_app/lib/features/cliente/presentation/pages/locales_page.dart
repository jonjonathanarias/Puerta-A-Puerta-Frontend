import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/cliente_repository.dart';
import '../widgets/cliente_app_bar.dart';
import 'catalogo_page.dart';

class LocalesPage extends StatefulWidget {
  const LocalesPage({super.key});

  @override
  State<LocalesPage> createState() => _LocalesPageState();
}

class _LocalesPageState extends State<LocalesPage> {
  bool _cargando = true;
  String? _error;
  List<dynamic> _locales = [];

  @override
  void initState() {
    super.initState();
    _cargarLocales();
  }

  Future<void> _cargarLocales() async {
    if (!mounted) return;

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final repository = context.read<ClienteRepository>();

      // Coordenadas corregidas (Córdoba): latitud -31.416, longitud -64.185
      final result = await repository.getLocalesCercanos(
        lat: -31.416,
        lng: -64.185,
      );

      if (!mounted) return;

      setState(() {
        _locales = result;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _cargando = false;
      });
    }
  }

  // En locales_page.dart
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ClienteAppBar(
        titulo: 'Locales Disponibles',
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _cargarLocales,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_locales.isEmpty) {
      return const Center(
        child: Text(
          'No hay locales disponibles en tu zona',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _locales.length,
      itemBuilder: (context, index) {
        final local = _locales[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.store),
            ),
            title: Text(
              local['nombre'] ?? 'Local sin nombre',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(local['direccion'] ?? 'Sin dirección'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CatalogoPage(localId: local['id']),
                ),
              );
            },
          ),
        );
      },
    );
  }
}