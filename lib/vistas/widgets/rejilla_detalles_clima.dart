import 'package:flutter/material.dart';

import '../../modelos/clima_modelo.dart';

class RejillaDetallesClima extends StatelessWidget {
  final ClimaModelo clima;

  const RejillaDetallesClima({super.key, required this.clima});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detalles Atmosféricos',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ItemDetalle(
                icono: Icons.water_drop_rounded,
                colorIcono: Colors.blueAccent,
                etiqueta: 'Humedad',
                valor: '${clima.humedad}%',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ItemDetalle(
                icono: Icons.umbrella_rounded,
                colorIcono: Colors.cyan,
                etiqueta: 'Prob. de lluvia',
                valor: '${clima.probabilidadLluvia}%',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ItemDetalle(
                icono: Icons.air_rounded,
                colorIcono: Colors.teal,
                etiqueta: 'Viento',
                valor: '${clima.velocidadViento.toStringAsFixed(1)} km/h',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ItemDetalle(
                icono: Icons.speed_rounded,
                colorIcono: Colors.deepOrangeAccent,
                etiqueta: 'Presión atm.',
                valor: '${clima.presionAtmosferica.toStringAsFixed(0)} hPa',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ItemDetalle extends StatelessWidget {
  final IconData icono;
  final Color colorIcono;
  final String etiqueta;
  final String valor;

  const _ItemDetalle({
    required this.icono,
    required this.colorIcono,
    required this.etiqueta,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorIcono.withAlpha(31),
              shape: BoxShape.circle,
            ),
            child: Icon(icono, color: colorIcono, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  etiqueta,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
