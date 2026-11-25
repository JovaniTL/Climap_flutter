import 'package:flutter/material.dart';

import '../../modelos/clima_modelo.dart';

class MonitoClimaWidget extends StatelessWidget {
  final ClimaModelo clima;

  const MonitoClimaWidget({super.key, required this.clima});

  @override
  Widget build(BuildContext context) {
    final datosMonito = _obtenerDatosMonito(clima);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: datosMonito.colorFondo.withAlpha(31),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: datosMonito.colorFondo.withAlpha(77),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          _ilustracion(datosMonito),
          const SizedBox(width: 16),
          Expanded(child: _mensaje(context, datosMonito)),
        ],
      ),
    );
  }

  Widget _ilustracion(_DatosMonito datosMonito) {
    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: datosMonito.colorFondo.withAlpha(115),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: datosMonito.colorFondo.withAlpha(64),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              datosMonito.rutaImagenAsset,
              width: 92,
              height: 92,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        datosMonito.colorFondo.withAlpha(204),
                        datosMonito.colorFondo,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Icon(
                    datosMonito.iconoPrincipal,
                    size: 46,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(51),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                datosMonito.iconoAccesorio,
                size: 16,
                color: datosMonito.colorFondo,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mensaje(BuildContext context, _DatosMonito datosMonito) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: datosMonito.colorFondo.withAlpha(51),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            datosMonito.etiquetaEstado,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: datosMonito.colorFondo,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          datosMonito.tituloAccion,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          datosMonito.descripcion,
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).textTheme.bodyMedium?.color
                ?.withAlpha(204),
          ),
        ),
      ],
    );
  }

  _DatosMonito _obtenerDatosMonito(ClimaModelo clima) {
    if (clima.probabilidadLluvia >= 40 ||
        (clima.codigoClima >= 51 && clima.codigoClima <= 82) ||
        clima.codigoClima >= 95) {
      return const _DatosMonito(
        etiquetaEstado: 'Día Lluvioso 🌧️',
        tituloAccion: 'Monito con paraguas e impermeable',
        descripcion: 'Preparado con botas de lluvia y paraguas para no mojarse en el camino.',
        iconoPrincipal: Icons.umbrella_rounded,
        iconoAccesorio: Icons.water_drop_rounded,
        colorFondo: Colors.indigo,
        rutaImagenAsset: 'assets/imagenes/lluvioso.png',
      );
    }

    if (clima.temperatura >= 26.0) {
      return const _DatosMonito(
        etiquetaEstado: 'Día Caluroso ☀️',
        tituloAccion: 'Monito poniéndose protector solar',
        descripcion: 'Aplicándose crema solar FPS 50+, usando gafas oscuras y bebiendo agua fresca.',
        iconoPrincipal: Icons.wb_sunny_rounded,
        iconoAccesorio: Icons.sanitizer_rounded,
        colorFondo: Colors.orange,
        rutaImagenAsset: 'assets/imagenes/caluroso.png',
      );
    }

    if (clima.temperatura < 15.0) {
      return const _DatosMonito(
        etiquetaEstado: 'Día Frío ❄️',
        tituloAccion: 'Monito bien abrigado',
        descripcion: 'Con gorro de lana, bufanda gruesa y una taza de chocolate caliente.',
        iconoPrincipal: Icons.ac_unit_rounded,
        iconoAccesorio: Icons.coffee_rounded,
        colorFondo: Colors.teal,
        rutaImagenAsset: 'assets/imagenes/frio.png',
      );
    }

    if (clima.velocidadViento >= 22.0) {
      return const _DatosMonito(
        etiquetaEstado: 'Día Ventoso 💨',
        tituloAccion: 'Monito sujetando su sombrero',
        descripcion: 'Ráfagas de aire fresco agitando su bufanda mientras camina con cuidado.',
        iconoPrincipal: Icons.air_rounded,
        iconoAccesorio: Icons.navigation_rounded,
        colorFondo: Colors.blueGrey,
        rutaImagenAsset: 'assets/imagenes/viento.png',
      );
    }

    return const _DatosMonito(
      etiquetaEstado: 'Clima Agradable 🌤️',
      tituloAccion: 'Monito paseando relajado',
      descripcion:
          'Disfrutando de una temperatura perfecta para caminar al aire libre.',
      iconoPrincipal: Icons.directions_walk_rounded,
      iconoAccesorio: Icons.favorite_rounded,
      colorFondo: Colors.green,
      rutaImagenAsset: 'assets/imagenes/templado.png',
    );
  }
}

class _DatosMonito {
  final String etiquetaEstado;
  final String tituloAccion;
  final String descripcion;
  final IconData iconoPrincipal;
  final IconData iconoAccesorio;
  final Color colorFondo;
  final String rutaImagenAsset;

  const _DatosMonito({
    required this.etiquetaEstado,
    required this.tituloAccion,
    required this.descripcion,
    required this.iconoPrincipal,
    required this.iconoAccesorio,
    required this.colorFondo,
    required this.rutaImagenAsset,
  });
}
