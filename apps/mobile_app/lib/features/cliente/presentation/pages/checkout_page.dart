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

  const CheckoutPage({
    super.key,
    required this.localId,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _direccionController = TextEditingController();
  final _observacionesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _cargandoUbicacion = false;

  // Historial simulado de direcciones guardadas del cliente
  final List<String> _historicoDirecciones = [
    'Av. Siempreviva 742',
    'Calle Falsa 123',
    'Oficina Centro, Piso 4 B',
  ];

  @override
  void dispose() {
    _direccionController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  // Método para obtener la ubicación GPS y convertirla a dirección
  Future<void> _obtenerUbicacionActual() async {
    setState(() => _cargandoUbicacion = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('El servicio de ubicación está desactivado.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permisos de ubicación denegados.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Los permisos de ubicación están denegados permanentemente.');
      }

      // Obtener la posición GPS
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;

          // Construimos la dirección de forma segura sin forzar nulos
          final List<String> partesDireccion = [];
          if (place.street != null && place.street!.isNotEmpty) {
            partesDireccion.add(place.street!);
          }
          if (place.locality != null && place.locality!.isNotEmpty) {
            partesDireccion.add(place.locality!);
          }

          final direccionFinal = partesDireccion.isNotEmpty
              ? partesDireccion.join(', ')
              : 'Ubicación GPS (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})';

          setState(() {
            _direccionController.text = direccionFinal;
          });
        } else {
          setState(() {
            _direccionController.text =
            'Ubicación GPS (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})';
          });
        }
      } catch (_) {
        // Si la geocodificación inversa falla (común en entorno desktop/desarrollo)
        setState(() {
          _direccionController.text =
          'Ubicación GPS (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _cargandoUbicacion = false);
    }
  }

  // Modal para seleccionar una dirección del historial
  void _mostrarHistoricoDirecciones() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Seleccionar Dirección Guardada',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _historicoDirecciones.length,
                  itemBuilder: (context, index) {
                    final dir = _historicoDirecciones[index];
                    return ListTile(
                      leading: const Icon(Icons.history, color: Colors.blueAccent),
                      title: Text(dir),
                      onTap: () {
                        setState(() {
                          _direccionController.text = dir;
                        });
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // checkout_page.dart

  void _confirmarPedido(CarritoState carritoState) {
    if (_formKey.currentState?.validate() ?? false) {
      // 1. Armamos los items respetando el DTO del backend
      final itemsPayload = carritoState.items.entries.map((e) {
        return {
          'productoId': e.key.id,
          'cantidad': e.value,
        };
      }).toList();

      // 2. Disparamos el evento con los campos correctos
      context.read<PedidoBloc>().add(
        CrearPedidoEvent(
          localId: widget.localId,
          direccionEntrega: _direccionController.text.trim(),
          notas: _observacionesController.text.trim(),
          items: itemsPayload,
          // Opcional: si guardaste las coordenadas GPS al presionar "Mi Ubicación"
          // latitud: _latitudActual,
          // longitud: _longitudActual,
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
            if (carritoState.items.isEmpty) {
              return const Center(child: Text('El carrito está vacío'));
            }

            return Padding(
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
                        children: carritoState.items.entries
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

                    // Opciones rápidas de selección (GPS e Histórico)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _cargandoUbicacion ? null : _obtenerUbicacionActual,
                            icon: _cargandoUbicacion
                                ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                                : const Icon(Icons.my_location),
                            label: const Text('Mi Ubicación'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _mostrarHistoricoDirecciones,
                            icon: const Icon(Icons.history),
                            label: const Text('Historial'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Campo de entrada libre / manual
                    TextFormField(
                      controller: _direccionController,
                      decoration: const InputDecoration(
                        labelText: 'Dirección de Entrega',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on_outlined),
                        hintText: 'Ingresa una dirección o selecciona una arriba',
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
                      builder: (context, pedidoState) {
                        if (pedidoState is PedidoLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => _confirmarPedido(carritoState),
                          child: Text(
                            'FINALIZAR PEDIDO (\$${carritoState.montoTotal.toStringAsFixed(2)})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
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