import '../modelos/clima_modelo.dart';

/// Clase que calcula el índice de actividades al aire libre y compara dos ciudades.
class EvaluadorActividades {
  EvaluadorActividades._();

  /// Calcula un puntaje de 0 a 100 según qué tan agradable es el clima para salir a caminar o hacer deporte.
  static int calcularPuntajeActividad(ClimaModelo clima) {
    double puntaje = 100.0;

    // 1. Penalización por lluvia
    if (clima.probabilidadLluvia > 20) {
      // Si la probabilidad de lluvia es mayor al 20%, restamos proporcionalmente
      puntaje -= (clima.probabilidadLluvia - 20) * 0.8;
    }
    if (clima.codigoClima >= 51 && clima.codigoClima <= 82) {
      puntaje -= 30.0; // Llueve activamente
    }
    if (clima.codigoClima >= 95) {
      puntaje -= 60.0; // Tormenta
    }

    // 2. Penalización por temperatura extrema
    // Rango ideal: 18°C a 24°C
    if (clima.temperatura < 18.0) {
      final diferenciaFrio = 18.0 - clima.temperatura;
      puntaje -= diferenciaFrio * 3.0; // Penaliza el frío
    } else if (clima.temperatura > 24.0) {
      final diferenciaCalor = clima.temperatura - 24.0;
      puntaje -= diferenciaCalor * 3.5; // Penaliza el calor
    }

    // 3. Penalización por viento fuerte
    if (clima.velocidadViento > 20.0) {
      puntaje -= (clima.velocidadViento - 20.0) * 1.5;
    }

    return puntaje.clamp(0.0, 100.0).round();
  }

  /// Genera una descripción de la aptitud según el puntaje
  static String descripcionPuntaje(int puntaje) {
    if (puntaje >= 80) return 'Excelente para salir a caminar';
    if (puntaje >= 60) return 'Buen clima con precauciones menores';
    if (puntaje >= 40) return 'Clima regular, considera ropa adecuada';
    return 'No recomendable para actividades al aire libre';
  }

  /// Compara dos climas y devuelve una conclusión inteligente en español
  static String generarVeredictoComparativo({
    required ClimaModelo clima1,
    required ClimaModelo clima2,
  }) {
    final p1 = calcularPuntajeActividad(clima1);
    final p2 = calcularPuntajeActividad(clima2);

    final nombre1 = clima1.nombreLugar;
    final nombre2 = clima2.nombreLugar;

    if ((p1 - p2).abs() < 5) {
      return 'Ambas ciudades tienen condiciones climáticas muy similares hoy. Tanto en $nombre1 (${clima1.temperatura.toStringAsFixed(1)}°C) como en $nombre2 (${clima2.temperatura.toStringAsFixed(1)}°C) las condiciones para actividades son parejas.';
    }

    final mejor = p1 > p2 ? clima1 : clima2;
    final otra = p1 > p2 ? clima2 : clima1;

    String razones = '';
    if (mejor.probabilidadLluvia < otra.probabilidadLluvia) {
      razones += 'menor probabilidad de lluvia (${mejor.probabilidadLluvia}% vs ${otra.probabilidadLluvia}%)';
    }
    if ((mejor.temperatura - 21.0).abs() < (otra.temperatura - 21.0).abs()) {
      if (razones.isNotEmpty) razones += ' y ';
      razones += 'una temperatura más templada (${mejor.temperatura.toStringAsFixed(1)}°C vs ${otra.temperatura.toStringAsFixed(1)}°C)';
    }

    if (razones.isEmpty) {
      razones = 'condiciones atmosféricas generales más confortables';
    }

    return '🏆 ${mejor.nombreLugar} es más ideal hoy para salir a caminar o realizar actividades al aire libre, debido a su $razones.';
  }
}

