import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../bloc/carrito_bloc.dart';
import '../bloc/pedido/pedido_bloc.dart';
import '../bloc/pedido/pedido_event.dart';
import '../bloc/pedido/pedido_state.dart';
import '../pages/pedido_confirmado_page.dart';
import '../widgets/cliente_app_bar.dart';

class CheckoutPage extends StatefulWidget {
  final String localId;

  const CheckoutPage({super.key, required this.localId});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _direccionController = TextEditingController();
  final _observacionesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _cargandoUbicacion = false;
  double? _latitudActual;
  double? _longitudActual;

  final List<String> _historicoDirecciones = [
    'Av. General Paz 250, Córdoba',
    'Av. Colón 1234, Córdoba',
    'Pueyrredón 500, Córdoba',
  ];

  @override
  void dispose() {
    _direccionController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  Future<void> _obtenerUbicacionGPS() async {
    setState(() => _cargandoUbicacion = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('El GPS está desactivado.');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permiso de ubicación denegado.');
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _latitudActual = position.latitude;
      _longitudActual = position.longitude;

      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          _direccionController.text =
              '${place.street ?? ''}, ${place.locality ?? ''}'.trim();
        }
      } catch (_) {
        _direccionController.text =
        'Ubicación GPS (${position.latitude.toStringAsFixed(3)}, ${position.longitude.toStringAsFixed(3)})';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _cargandoUbicacion = false);
    }
  }

  Future<void> _confirmarPedido(CarritoState carritoState) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final direccion = _direccionController.text.trim();

    // Si las coordenadas son nulas (porque se escribió la dirección), intentamos geocodificar
    if (_latitudActual == null || _longitudActual == null) {
      try {
        final locations = await locationFromAddress(direccion);
        if (locations.isNotEmpty) {
          _latitudActual = locations.first.latitude;
          _longitudActual = locations.first.longitude;
        }
      } catch (_) {
        // Fallback predeterminado (Centro de Córdoba) si la dirección escrita no da coordenadas
        _latitudActual = -31.416;
        _longitudActual = -64.185;
      }
    }

    final itemsPayload = carritoState.items.entries.map((e) {
      return {
        'productoId': e.key.id,
        'cantidad': e.value,
      };
    }).toList();

    if (!mounted) return;

    context.read<PedidoBloc>().add(
      CrearPedidoEvent(
        localId: widget.localId,
        direccionEntrega: direccion,
        notas: _observacionesController.text.trim().isNotEmpty
            ? _observacionesController.text.trim()
            : null,
        items: itemsPayload,
        latitud: _latitudActual,
        longitud: _longitudActual,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ClienteAppBar(titulo: 'Confirmar Pedido'),
      body: BlocListener<PedidoBloc, PedidoState>(
        listener: (context, state) {
          if (state is PedidoExitoso) {
            context.read<CarritoBloc>().add(LimpiarCarritoEvent());
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => PedidoConfirmadoPage(
                  pedidoId: state.pedidoId ?? 'N/A',
                ),
              ),
                  (route) => route.isFirst,
            );
          } else if (state is PedidoError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensaje),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        child: BlocBuilder<CarritoBloc, CarritoState>(
          builder: (context, carritoState) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Resumen de Productos',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Card(
                      child: Column(
                        children: carritoState.items.entries
                            .map((e) => ListTile(
                          title: Text(e.key.nombre),
                          subtitle: Text('Cantidad: ${e.value}'),
                          trailing: Text(
                            '\$${(e.key.precio * e.value).toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                        ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Datos de Entrega',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _cargandoUbicacion
                                ? null
                                : _obtenerUbicacionGPS,
                            icon: const Icon(Icons.my_location),
                            label: const Text('Mi Ubicación'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (_) => ListView(
                                  shrinkWrap: true,
                                  children: _historicoDirecciones
                                      .map((d) => ListTile(
                                    title: Text(d),
                                    onTap: () {
                                      setState(() {
                                        _direccionController.text = d;
                                        _latitudActual = null;
                                        _longitudActual = null;
                                      });
                                      Navigator.pop(context);
                                    },
                                  ))
                                      .toList(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.history),
                            label: const Text('Historial'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _direccionController,
                      decoration: const InputDecoration(
                        labelText: 'Dirección de Entrega',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Ingresa una dirección'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _observacionesController,
                      decoration: const InputDecoration(
                        labelText: 'Observaciones (Opcional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.notes),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                        onPressed: () => _confirmarPedido(carritoState),
                        child: Text(
                          'FINALIZAR PEDIDO (\$${carritoState.montoTotal.toStringAsFixed(2)})',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}