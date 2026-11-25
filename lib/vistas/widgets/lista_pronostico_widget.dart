import 'package:flutter/material.dart';

import '../../modelos/pronostico_modelo.dart';
import '../../utilidades/clima_traductor.dart';

class ListaPronosticoWidget extends StatelessWidget {
  final List<PronosticoDiaModelo> pronostico;

  const ListaPronosticoWidget({super.key, required this.pronostico});

  @override
  Widget build(BuildContext context) {
    if (pronostico.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 20,
              color: Colors.blueAccent,
            ),
            SizedBox(width: 8),
            Text(
              'Pronóstico Próximos Días',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 145,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: pronostico.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              return _TarjetaDia(dia: pronostico[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _TarjetaDia extends StatelessWidget {
  final PronosticoDiaModelo dia;

  const _TarjetaDia({required this.dia});

  @override
  Widget build(BuildContext context) {
    final icono = ClimaTraductor.obtenerIcono(dia.codigoClima);

    return Container(
      width: 105,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            dia.nombreDia,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Icon(icono, size: 30, color: Colors.blueAccent),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${dia.tempMaxima.round()}°',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${dia.tempMinima.round()}°',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
          if (dia.probabilidadLluvia > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.water_drop, size: 12, color: Colors.cyan),
                const SizedBox(width: 2),
                Text(
                  '${dia.probabilidadLluvia}%',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.cyan,
                  ),
                ),
              ],
            )
          else
            const Text(
              'Seco',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
        ],
      ),
    );
  }
}
