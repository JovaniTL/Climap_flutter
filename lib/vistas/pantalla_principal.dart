import 'package:flutter/material.dart';

import '../servicios/clima_api_servicio.dart';
import 'vista_clima_principal.dart';
import 'vista_comparacion.dart';
import 'vista_mapa.dart';

class PantallaPrincipal extends StatefulWidget {
  final ClimaApiServicio servicio;

  const PantallaPrincipal({super.key, required this.servicio});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  static const _destinos = [
    NavigationDestination(
      icon: Icon(Icons.wb_sunny_outlined),
      selectedIcon: Icon(Icons.wb_sunny_rounded),
      label: 'Clima',
    ),
    NavigationDestination(
      icon: Icon(Icons.compare_arrows_outlined),
      selectedIcon: Icon(Icons.compare_arrows_rounded),
      label: 'Comparar',
    ),
    NavigationDestination(
      icon: Icon(Icons.map_outlined),
      selectedIcon: Icon(Icons.map_rounded),
      label: 'Mapa',
    ),
  ];

  int _indiceActual = 0;

  void _cambiarPestana(int indice) {
    setState(() => _indiceActual = indice);
  }

  @override
  Widget build(BuildContext context) {
    final contenido = IndexedStack(
      index: _indiceActual,
      children: [
        const VistaClimaPrincipal(),
        const VistaComparacion(),
        VistaMapa(
          servicio: widget.servicio,
          onVerDetalles: () => _cambiarPestana(0),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 720) {
          return Scaffold(
            body: Row(
              children: [
                _menuLateral(context),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: contenido),
              ],
            ),
          );
        }

        return Scaffold(
          body: contenido,
          bottomNavigationBar: NavigationBar(
            selectedIndex: _indiceActual,
            onDestinationSelected: _cambiarPestana,
            elevation: 3,
            destinations: _destinos,
          ),
        );
      },
    );
  }

  Widget _menuLateral(BuildContext context) {
    return NavigationRail(
      selectedIndex: _indiceActual,
      onDestinationSelected: _cambiarPestana,
      labelType: NavigationRailLabelType.all,
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Icon(
          Icons.cloud_circle_rounded,
          size: 42,
          color: Theme.of(context).primaryColor,
        ),
      ),
      destinations: [
        for (final destino in _destinos)
          NavigationRailDestination(
            icon: destino.icon,
            selectedIcon: destino.selectedIcon,
            label: Text(destino.label),
          ),
      ],
    );
  }
}
