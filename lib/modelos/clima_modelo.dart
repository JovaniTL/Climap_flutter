import 'package:equatable/equatable.dart';
import 'pronostico_modelo.dart';

/// Modelo principal con todos los datos meteorológicos requeridos.
class ClimaModelo extends Equatable {
  final String nombreLugar;
  final double temperatura;
  final double sensacionTermica;
  final int humedad;
  final double presionAtmosferica; // En hPa (hectopascales)
  final double velocidadViento; // En km/h
  final int probabilidadLluvia; // En porcentaje %
  final int codigoClima; // Código WMO
  final bool esDeDia;
  final double latitud;
  final double longitud;
  final List<PronosticoDiaModelo> pronosticoSemanal;
  final DateTime fechaConsulta;

  const ClimaModelo({
    required this.nombreLugar,
    required this.temperatura,
    required this.sensacionTermica,
    required this.humedad,
    required this.presionAtmosferica,
    required this.velocidadViento,
    required this.probabilidadLluvia,
    required this.codigoClima,
    required this.esDeDia,
    required this.latitud,
    required this.longitud,
    required this.pronosticoSemanal,
    required this.fechaConsulta,
  });

  /// Crea la instancia a partir de la respuesta JSON de Open-Meteo API.
  factory ClimaModelo.fromOpenMeteoJson(
    Map<String, dynamic> json, {
    required String nombreLugar,
    required double latitud,
    required double longitud,
  }) {
    final current = json['current'] as Map<String, dynamic>? ?? {};
    final daily = json['daily'] as Map<String, dynamic>? ?? {};

    // Procesar pronóstico diario
    final tiempos = (daily['time'] as List?)?.cast<String>() ?? [];
    final maxTemps = daily['temperature_2m_max'] as List? ?? [];
    final minTemps = daily['temperature_2m_min'] as List? ?? [];
    final probasLluvia = daily['precipitation_probability_max'] as List? ?? [];
    final codigos = daily['weather_code'] as List? ?? [];

    final List<PronosticoDiaModelo> listaPronostico = [];
    for (int i = 0; i < tiempos.length; i++) {
      final fechaParsed = DateTime.tryParse(tiempos[i]) ?? DateTime.now();
      final maxT = i < maxTemps.length ? (maxTemps[i] as num?)?.toDouble() ?? 0.0 : 0.0;
      final minT = i < minTemps.length ? (minTemps[i] as num?)?.toDouble() ?? 0.0 : 0.0;
      final probL = i < probasLluvia.length ? (probasLluvia[i] as num?)?.toInt() ?? 0 : 0;
      final cod = i < codigos.length ? (codigos[i] as num?)?.toInt() ?? 0 : 0;

      listaPronostico.add(
        PronosticoDiaModelo(
          fecha: fechaParsed,
          tempMaxima: maxT,
          tempMinima: minT,
          probabilidadLluvia: probL,
          codigoClima: cod,
        ),
      );
    }

    // Probabilidad de lluvia del día actual
    final lluviaHoy = listaPronostico.isNotEmpty
        ? listaPronostico.first.probabilidadLluvia
        : 0;

    return ClimaModelo(
      nombreLugar: nombreLugar,
      temperatura: (current['temperature_2m'] as num?)?.toDouble() ?? 0.0,
      sensacionTermica: (current['apparent_temperature'] as num?)?.toDouble() ??
          (current['temperature_2m'] as num?)?.toDouble() ??
          0.0,
      humedad: (current['relative_humidity_2m'] as num?)?.toInt() ?? 0,
      presionAtmosferica: (current['surface_pressure'] as num?)?.toDouble() ?? 1013.25,
      velocidadViento: (current['wind_speed_10m'] as num?)?.toDouble() ?? 0.0,
      probabilidadLluvia: lluviaHoy,
      codigoClima: (current['weather_code'] as num?)?.toInt() ?? 0,
      esDeDia: ((current['is_day'] as num?)?.toInt() ?? 1) == 1,
      latitud: latitud,
      longitud: longitud,
      pronosticoSemanal: listaPronostico,
      fechaConsulta: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    nombreLugar,
    temperatura,
    sensacionTermica,
    humedad,
    presionAtmosferica,
    velocidadViento,
    probabilidadLluvia,
    codigoClima,
    esDeDia,
    latitud,
    longitud,
    pronosticoSemanal,
    fechaConsulta,
  ];
}

