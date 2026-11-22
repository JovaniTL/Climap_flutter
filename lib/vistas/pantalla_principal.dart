import 'package:flutter/material.dart';
import 'vista_clima_principal.dart';
import 'vista_comparacion.dart';
import 'vista_mapa.dart';

/// Contenedor principal de la aplicación con barra de navegación adaptable
/// (NavigationBar para móviles y NavigationRail para tablets o pantallas anchas).
class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  int _indiceActual = 0;

  void _cambiarPestana(int nuevoIndice) {
    setState(() {
      _indiceActual = nuevoIndice;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pantallas = [
      const VistaClimaPrincipal(),
      const VistaComparacion(),
      VistaMapa(onCambiarTab: _cambiarPestana),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final esPantallaAncha = constraints.maxWidth >= 720;

        if (esPantallaAncha) {
          // Diseño adaptable para Tablets y Pantallas Grandes (Menú Lateral)
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
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
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.wb_sunny_outlined),
                      selectedIcon: Icon(Icons.wb_sunny_rounded),
                      label: Text('Clima'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.compare_arrows_outlined),
                      selectedIcon: Icon(Icons.compare_arrows_rounded),
                      label: Text('Comparar'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.map_outlined),
                      selectedIcon: Icon(Icons.map_rounded),
                      label: Text('Mapa'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: IndexedStack(
                    index: _indiceActual,
                    children: pantallas,
                  ),
                ),
              ],
            ),
          );
        }

        // Diseño para Celulares (Barra de Navegación Inferior)
        return Scaffold(
          body: IndexedStack(
            index: _indiceActual,
            children: pantallas,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _indiceActual,
            onDestinationSelected: _cambiarPestana,
            elevation: 3,
            destinations: const [
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
            ],
          ),
        );
      },
    );
  }
}

