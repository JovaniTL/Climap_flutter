import 'package:flutter/material.dart';

import '../modelos/clima_modelo.dart';
import '../modelos/recomendacion_modelo.dart';

class RecomendadorClima {
  RecomendadorClima._();

  static List<RecomendacionModelo> generarRecomendaciones(ClimaModelo clima) {
    final List<RecomendacionModelo> recomendaciones = [];

    if (clima.probabilidadLluvia >= 40 ||
        (clima.codigoClima >= 51 && clima.codigoClima <= 82)) {
      recomendaciones.add(
        const RecomendacionModelo(
          titulo: 'Lleva paraguas o impermeable',
          descripcion: 'Hay alta probabilidad de precipitaciones. Lleva contigo protección contra el agua y cuida tu calzado.',
          icono: Icons.umbrella_rounded,
          color: Colors.blueAccent,
        ),
      );
    }

    if (clima.temperatura >= 26.0) {
      recomendaciones.add(
        const RecomendacionModelo(
          titulo: 'Usa protector solar y mantente hidratado',
          descripcion: 'El ambiente es caluroso. Aplica bloqueador FPS 50+, bebe agua constantemente y viste ropa fresca.',
          icono: Icons.wb_sunny_rounded,
          color: Colors.orangeAccent,
        ),
      );
    }

    if (clima.temperatura < 15.0) {
      recomendaciones.add(
        const RecomendacionModelo(
          titulo: 'Abrígate adecuadamente',
          descripcion: 'Temperaturas bajas. Viste en capas, usa chamarra o suéter y cubre tu cuello para evitar resfriados.',
          icono: Icons.ac_unit_rounded,
          color: Colors.cyan,
        ),
      );
    }

    if (clima.velocidadViento >= 22.0) {
      recomendaciones.add(
        const RecomendacionModelo(
          titulo: 'Precaución con vientos fuertes',
          descripcion: 'Se registran ráfagas de viento considerables. Sujeta objetos ligeros y ten cuidado en exteriores.',
          icono: Icons.air_rounded,
          color: Colors.teal,
        ),
      );
    }

    if (clima.codigoClima >= 95) {
      recomendaciones.add(
        const RecomendacionModelo(
          titulo: 'Alerta de tormenta eléctrica',
          descripcion: 'Evita espacios abiertos, no te resguardes bajo árboles altos y mantente a salvo en interiores.',
          icono: Icons.thunderstorm_rounded,
          color: Colors.deepPurpleAccent,
        ),
      );
    }

    if (clima.temperatura >= 16.0 &&
        clima.temperatura <= 25.0 &&
        clima.probabilidadLluvia < 30 &&
        clima.codigoClima <= 2) {
      recomendaciones.add(
        const RecomendacionModelo(
          titulo: '¡Clima ideal para salir!',
          descripcion: 'Las condiciones son sumamente placenteras para salir a caminar, pasear en bici o hacer ejercicio al aire libre.',
          icono: Icons.directions_walk_rounded,
          color: Colors.green,
        ),
      );
    }

    if (recomendaciones.isEmpty) {
      recomendaciones.add(
        const RecomendacionModelo(
          titulo: 'Condiciones templadas y estables',
          descripcion: 'El clima se mantiene moderado. Disfruta tu día y viste con ropa cómoda de temporada.',
          icono: Icons.sentiment_satisfied_alt_rounded,
          color: Colors.blueGrey,
        ),
      );
    }

    return recomendaciones;
  }
}
