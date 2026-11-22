import 'package:flutter/material.dart';
import '../../modelos/clima_modelo.dart';

/// Widget que muestra la ilustración temática del "Monito Climático"
/// adaptándose a la temperatura y las condiciones meteorológicas actuales.
class MonitoClimaWidget extends StatelessWidget {
  final ClimaModelo clima;

  const MonitoClimaWidget({super.key, required this.clima});

  @override
  Widget build(BuildContext context) {
    // Determinar la categoría y detalles visuales del monito
    final datosMonito = _obtenerDatosMonito(clima);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: datosMonito.colorFondo.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: datosMonito.colorFondo.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Ilustración o Avatar gráfico del Monito
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  datosMonito.colorFondo.withValues(alpha: 0.8),
                  datosMonito.colorFondo,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: datosMonito.colorFondo.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Intenta cargar la imagen si el usuario la agregó a assets, o muestra la ilustración de iconos
                Image.asset(
                  datosMonito.rutaImagenAsset,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback visualmente atractivo con iconos temáticos
                    return Icon(
                      datosMonito.iconoPrincipal,
                      size: 46,
                      color: Colors.white,
                    );
                  },
                ),
                // Pequeño badge con accesorio en la esquina
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
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
          ),
          const SizedBox(width: 16),
          // Descripción y mensaje del Monito
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: datosMonito.colorFondo.withValues(alpha: 0.2),
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  datosMonito.descripcion,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Evalúa las condiciones para elegir la ilustración adecuada
  _DatosMonito _obtenerDatosMonito(ClimaModelo clima) {
    // 1. Tormenta o Lluvia
    if (clima.probabilidadLluvia >= 40 || (clima.codigoClima >= 51 && clima.codigoClima <= 82)) {
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

    // 2. Clima Caluroso
    if (clima.temperatura >= 26.0) {
      return const _DatosMonito(
        etiquetaEstado: 'Día Caluroso ☀️',
        tituloAccion: 'Monito poniéndose protector solar',
        descripcion: 'Aplicándose crema solar FPS 50+, usando gafas oscuras y bebiendo agua fresca.',
        iconoPrincipal: Icons.wb_sunny_rounded,
        iconoAccesorio: Icons.sanitizer_rounded, // Representa el bote de protector
        colorFondo: Colors.orange,
        rutaImagenAsset: 'assets/imagenes/caluroso.png',
      );
    }

    // 3. Clima Frío
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

    // 4. Viento Fuerte
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

    // 5. Clima Templado Agradable
    return const _DatosMonito(
      etiquetaEstado: 'Clima Agradable 🌤️',
      tituloAccion: 'Monito paseando relajado',
      descripcion: 'Disfrutando de una temperatura perfecta para caminar al aire libre.',
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

