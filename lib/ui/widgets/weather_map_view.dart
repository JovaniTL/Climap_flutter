import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../blocs/weather/weather_bloc.dart';
import '../../blocs/weather/weather_event.dart';
import '../../blocs/weather/weather_state.dart';

class WeatherMapView extends StatefulWidget {
  const WeatherMapView({super.key});

  @override
  State<WeatherMapView> createState() => _WeatherMapViewState();
}

class _WeatherMapViewState extends State<WeatherMapView> {
  final MapController _mapController = MapController();

  static const LatLng _initialCenter = LatLng(19.4326, -100.3587);
  static const double _initialZoom = 7.5;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return BlocListener<WeatherBloc, WeatherState>(
      listenWhen: (previous, current) =>
          previous.selectedLatitude != current.selectedLatitude ||
          previous.selectedLongitude != current.selectedLongitude,
      listener: (context, state) {
        if (state.hasSelectedArea) {
          _mapController.move(
            LatLng(state.selectedLatitude!, state.selectedLongitude!),
            _mapController.camera.zoom < 9 ? 10.5 : _mapController.camera.zoom,
          );
        }
      },
      child: BlocBuilder<WeatherBloc, WeatherState>(
        builder: (context, state) {
          final hasArea = state.hasSelectedArea;

          final centerPoint = hasArea
              ? LatLng(state.selectedLatitude!, state.selectedLongitude!)
              : _initialCenter;

          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: _initialZoom,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.doubleTapZoom,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.weather_app',
              ),

              if (hasArea) ...[
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: centerPoint,
                      radius: state.selectionRadiusMeters,
                      useRadiusInMeter: true,
                      color: scheme.primary.withOpacity(0.22),
                      borderColor: scheme.primary,
                      borderStrokeWidth: 2.5,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: centerPoint,
                      width: 44,
                      height: 44,
                      child: Icon(
                        Icons.location_pin,
                        size: 40,
                        color: scheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
