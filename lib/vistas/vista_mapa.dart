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

class VistaMapa extends StatefulWidget {
  final ClimaApiServicio servicio;
  final VoidCallback onVerDetalles;

  const VistaMapa({
    super.key,
    required this.servicio,
    required this.onVerDetalles,
  });

  @override
  State<VistaMapa> createState() => _VistaMapaState();
}

class _VistaMapaState extends State<VistaMapa> {
  final _mapController = MapController();
  bool _consultando = false;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _consultarClimaCentro() async {
    final centro = _mapController.camera.center;
    final latitud = centro.latitude;
    final longitud = centro.longitude;
    final nombre =
        'Ubicación seleccionada '
        '(${latitud.toStringAsFixed(2)}, ${longitud.toStringAsFixed(2)})';

    setState(() => _consultando = true);

    try {
      final clima = await widget.servicio.obtenerClima(
        latitud: latitud,
        longitud: longitud,
        nombreLugar: nombre,
      );

      if (!mounted) return;
      setState(() => _consultando = false);
      _mostrarResultado(clima);
    } catch (error) {
      if (!mounted) return;
      setState(() => _consultando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _mostrarResultado(ClimaModelo clima) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (contextoModal) => _ResumenClimaMapa(
        clima: clima,
        onVerDetalles: () {
          Navigator.pop(contextoModal);
          _verDetalles(clima);
        },
      ),
    );
  }

  void _verDetalles(ClimaModelo clima) {
    context.read<ClimaBloc>().add(
      ConsultarClimaPorCoordenadasEvent(
        latitud: clima.latitud,
        longitud: clima.longitud,
        nombreLugar: clima.nombreLugar,
      ),
    );
    widget.onVerDetalles();
  }

  void _cambiarZoom(double cambio) {
    final camara = _mapController.camera;
    _mapController.move(camara.center, camara.zoom + cambio);
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
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(19.4326, -99.1332),
              initialZoom: 6.0,
              minZoom: 2.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app_clima',
              ),
            ],
          ),
          const _MarcadorCentro(),
          const _GuiaMapa(),
          _BotonesZoom(onZoom: _cambiarZoom),
          _botonConsulta(),
        ],
      ),
    );
  }

  Widget _botonConsulta() {
    return Positioned(
      bottom: 24,
      left: 20,
      right: 20,
      child: ElevatedButton.icon(
        onPressed: _consultando ? null : _consultarClimaCentro,
        icon: _consultando
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
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
    );
  }
}

class _MarcadorCentro extends StatelessWidget {
  const _MarcadorCentro();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Transform.translate(
          offset: const Offset(0, -22),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_on, size: 48, color: Colors.redAccent),
              Icon(Icons.circle, size: 8, color: Colors.black45),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuiaMapa extends StatelessWidget {
  const _GuiaMapa();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withAlpha(235),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
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
    );
  }
}

class _BotonesZoom extends StatelessWidget {
  final ValueChanged<double> onZoom;

  const _BotonesZoom({required this.onZoom});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 100,
      child: Column(
        children: [
          FloatingActionButton.small(
            heroTag: 'zoom_in',
            onPressed: () => onZoom(1),
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'zoom_out',
            onPressed: () => onZoom(-1),
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}

class _ResumenClimaMapa extends StatelessWidget {
  final ClimaModelo clima;
  final VoidCallback onVerDetalles;

  const _ResumenClimaMapa({required this.clima, required this.onVerDetalles});

  @override
  Widget build(BuildContext context) {
    final icono = ClimaTraductor.obtenerIcono(clima.codigoClima);
    final descripcion = ClimaTraductor.obtenerDescripcion(clima.codigoClima);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(51), blurRadius: 16),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '$descripcion • ${clima.temperatura.round()}°C (Sensación ${clima.sensacionTermica.toStringAsFixed(1)}°C)',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          MonitoClimaWidget(clima: clima),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onVerDetalles,
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
  }
}
