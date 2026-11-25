import 'package:equatable/equatable.dart';

import 'pronostico_modelo.dart';

class ClimaModelo extends Equatable {
  final String nombreLugar;
  final double temperatura;
  final double sensacionTermica;
  final int humedad;
  final double presionAtmosferica;
  final double velocidadViento;
  final int probabilidadLluvia;
  final int codigoClima;
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

  factory ClimaModelo.fromOpenMeteoJson(
    Map<String, dynamic> json, {
    required String nombreLugar,
    required double latitud,
    required double longitud,
  }) {
    final actual = json['current'] as Map<String, dynamic>? ?? {};
    final diario = json['daily'] as Map<String, dynamic>? ?? {};
    final pronostico = _leerPronostico(diario);
    final temperatura = (actual['temperature_2m'] as num?)?.toDouble() ?? 0.0;
    final lluviaHoy = pronostico.isEmpty
        ? 0
        : pronostico.first.probabilidadLluvia;

    return ClimaModelo(
      nombreLugar: nombreLugar,
      temperatura: temperatura,
      sensacionTermica:
          (actual['apparent_temperature'] as num?)?.toDouble() ?? temperatura,
      humedad: (actual['relative_humidity_2m'] as num?)?.toInt() ?? 0,
      presionAtmosferica:
          (actual['surface_pressure'] as num?)?.toDouble() ?? 1013.25,
      velocidadViento: (actual['wind_speed_10m'] as num?)?.toDouble() ?? 0.0,
      probabilidadLluvia: lluviaHoy,
      codigoClima: (actual['weather_code'] as num?)?.toInt() ?? 0,
      esDeDia: ((actual['is_day'] as num?)?.toInt() ?? 1) == 1,
      latitud: latitud,
      longitud: longitud,
      pronosticoSemanal: pronostico,
      fechaConsulta: DateTime.now(),
    );
  }

  static List<PronosticoDiaModelo> _leerPronostico(
    Map<String, dynamic> diario,
  ) {
    final fechas = (diario['time'] as List?)?.cast<String>() ?? [];
    final maximas = diario['temperature_2m_max'] as List? ?? [];
    final minimas = diario['temperature_2m_min'] as List? ?? [];
    final probabilidadLluvia =
        diario['precipitation_probability_max'] as List? ?? [];
    final codigos = diario['weather_code'] as List? ?? [];

    final pronostico = <PronosticoDiaModelo>[];
    for (var i = 0; i < fechas.length; i++) {
      pronostico.add(
        PronosticoDiaModelo(
          fecha: DateTime.tryParse(fechas[i]) ?? DateTime.now(),
          tempMaxima: _numeroDelDia(maximas, i)?.toDouble() ?? 0.0,
          tempMinima: _numeroDelDia(minimas, i)?.toDouble() ?? 0.0,
          probabilidadLluvia:
              _numeroDelDia(probabilidadLluvia, i)?.toInt() ?? 0,
          codigoClima: _numeroDelDia(codigos, i)?.toInt() ?? 0,
        ),
      );
    }
    return pronostico;
  }

  static num? _numeroDelDia(List valores, int dia) {
    return dia < valores.length ? valores[dia] as num? : null;
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
