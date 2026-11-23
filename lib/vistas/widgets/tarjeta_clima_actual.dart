import 'package:flutter/material.dart';
import '../../modelos/clima_modelo.dart';
import '../../utilidades/clima_traductor.dart';

/// Tarjeta principal con el clima actual, gradiente temático e información central.
class TarjetaClimaActual extends StatelessWidget {
  final ClimaModelo clima;

  const TarjetaClimaActual({super.key, required this.clima});

  @override
  Widget build(BuildContext context) {
    final colores = ClimaTraductor.obtenerGradienteFondo(
      clima.codigoClima,
      esDeDia: clima.esDeDia,
    );
    final icono = ClimaTraductor.obtenerIcono(
      clima.codigoClima,
      esDeDia: clima.esDeDia,
    );
    final descripcion = ClimaTraductor.obtenerDescripcion(
      clima.codigoClima,
      esDeDia: clima.esDeDia,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colores,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colores.first.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Nombre de la ubicación
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, color: Colors.white, size: 20),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  clima.nombreLugar,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Icono y Temperatura grande
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icono, size: 68, color: Colors.white),
              const SizedBox(width: 16),
              Text(
                '${clima.temperatura.round()}°',
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Descripción en español
          Text(
            descripcion,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),

          // Sensación térmica
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Sensación térmica: ${clima.sensacionTermica.toStringAsFixed(1)} °C',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

