import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../bloc/clima_bloc.dart';
import '../bloc/clima_event.dart';
import '../modelos/clima_modelo.dart';
import '../servicios/clima_api_servicio.dart';
import '../utilidades/clima_traductor.dart';
import 'widgets/monito_clima_widget.dart';

/// Vista de mapa interactivo con punto de mira central y botón flotante
/// para consultar el clima en cualquier lugar del mundo.
class VistaMapa extends StatefulWidget {
  final Function(int)? onCambiarTab;

  const VistaMapa({super.key, this.onCambiarTab});

  @override
  State<VistaMapa> createState() => _VistaMapaState();
}

class _VistaMapaState extends State<VistaMapa> {
  late final MapController _mapController;
  late final ClimaApiServicio _servicio;
  bool _consultando = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _servicio = ClimaApiServicio();
  }

  @override
  void dispose() {
    _mapController.dispose();
    _servicio.cerrar();
    super.dispose();
  }

  /// Obtiene las coordenadas del centro del mapa y consulta su clima
  Future<void> _consultarClimaCentro() async {
    final centro = _mapController.camera.center;
    final lat = centro.latitude;
    final lon = centro.longitude;

    setState(() => _consultando = true);

    try {
      final clima = await _servicio.obtenerClima(
        latitud: lat,
        longitud: lon,
        nombreLugar: 'Ubicación seleccionada (${lat.toStringAsFixed(2)}, ${lon.toStringAsFixed(2)})',
      );

      if (!mounted) return;
      setState(() => _consultando = false);

      _mostrarResultadoModal(clima);
    } catch (e) {
      if (!mounted) return;
      setState(() => _consultando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _mostrarResultadoModal(ClimaModelo clima) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final icono = ClimaTraductor.obtenerIcono(
          clima.codigoClima,
          esDeDia: clima.esDeDia,
        );
        final descripcion = ClimaTraductor.obtenerDescripcion(
          clima.codigoClima,
          esDeDia: clima.esDeDia,
        );

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(ctx).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 16,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(icono, size: 36, color: Colors.blueAccent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          clima.nombreLugar,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '$descripcion • ${clima.temperatura.round()}°C (Sensación ${clima.sensacionTermica.toStringAsFixed(1)}°C)',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Monito temático
              MonitoClimaWidget(clima: clima),
              const SizedBox(height: 12),
              // Botón para ver en la pantalla principal
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  // Notificar al BLoC principal para que cargue esta ubicación
                  context.read<ClimaBloc>().add(
                        ConsultarClimaPorCoordenadasEvent(
                          latitud: clima.latitud,
                          longitud: clima.longitud,
                          nombreLugar: clima.nombreLugar,
                        ),
                      );
                  // Cambiar a la pestaña 0 (Vista Principal)
                  widget.onCambiarTab?.call(0);
                },
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Ver todos los detalles en Pantalla Principal'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar Clima en el Mapa'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 1. Mapa interactivo de OpenStreetMap
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(19.4326, -99.1332), // Centrado en México
              initialZoom: 6.0,
              minZoom: 2.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.climap_flutter',
              ),
            ],
          ),

          // 2. Punto de mira central fijo (Marcador que no se mueve)
          IgnorePointer(
            child: Center(
              child: Transform.translate(
                offset: const Offset(0, -22),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 48,
                      color: Colors.redAccent,
                    ),
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Indicador de ayuda superior
          Positioned(
            top: 16,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor.withOpacity(0.92),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.touch_app_rounded, color: Colors.blueAccent, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Desliza el mapa hasta el punto deseado y pulsa el botón.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. Botones de Zoom flotantes a la derecha
          Positioned(
            right: 16,
            bottom: 100,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'zoom_in',
                  onPressed: () {
                    final zoom = _mapController.camera.zoom;
                    _mapController.move(_mapController.camera.center, zoom + 1);
                  },
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'zoom_out',
                  onPressed: () {
                    final zoom = _mapController.camera.zoom;
                    _mapController.move(_mapController.camera.center, zoom - 1);
                  },
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),

          // 5. Botón principal flotante para consultar el clima del centro
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: ElevatedButton.icon(
              onPressed: _consultando ? null : _consultarClimaCentro,
              icon: _consultando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.my_location_rounded),
              label: Text(
                _consultando
                    ? 'Consultando coordenadas...'
                    : 'Consultar clima en este punto',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

