import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../modelos/ciudad_modelo.dart';
import '../modelos/clima_modelo.dart';

enum TipoErrorClima {
  sinInternet,
  ciudadNoEncontrada,
  errorServidor,
  desconocido,
}

class ClimaExcepcion implements Exception {
  final String mensaje;
  final TipoErrorClima tipo;

  const ClimaExcepcion({
    required this.mensaje,
    this.tipo = TipoErrorClima.desconocido,
  });

  @override
  String toString() => mensaje;
}

class ClimaApiServicio {
  static const String _urlGeocoding =
      'https://geocoding-api.open-meteo.com/v1/search';
  static const String _urlForecast = 'https://api.open-meteo.com/v1/forecast';

  final http.Client _clienteHttp;

  ClimaApiServicio({http.Client? clienteHttp})
    : _clienteHttp = clienteHttp ?? http.Client();

  void cerrar() {
    _clienteHttp.close();
  }

  Future<List<CiudadModelo>> buscarCiudades(String nombreCiudad) async {
    final consulta = nombreCiudad.trim();
    if (consulta.isEmpty) return const [];

    final url = Uri.parse(_urlGeocoding).replace(
      queryParameters: {
        'name': consulta,
        'count': '6',
        'language': 'es',
        'format': 'json',
      },
    );

    try {
      final datos = await _obtenerJson(
        url,
        'El servicio de búsqueda no respondió correctamente.',
      );
      final resultados = datos['results'] as List?;

      if (resultados == null || resultados.isEmpty) {
        throw ClimaExcepcion(
          mensaje:
              'No se encontraron ciudades con el nombre "$consulta". Verifica la ortografía.',
          tipo: TipoErrorClima.ciudadNoEncontrada,
        );
      }

      return resultados
          .map(
            (item) =>
                CiudadModelo.fromOpenMeteoJson(item as Map<String, dynamic>),
          )
          .toList();
    } on SocketException {
      throw const ClimaExcepcion(
        mensaje:
            'Sin conexión a internet. Revisa tu red Wi-Fi o datos móviles.',
        tipo: TipoErrorClima.sinInternet,
      );
    } on TimeoutException {
      throw const ClimaExcepcion(
        mensaje: 'Tiempo de espera agotado. El servidor tardó demasiado en responder.',
        tipo: TipoErrorClima.errorServidor,
      );
    } on ClimaExcepcion {
      rethrow;
    } catch (e) {
      throw ClimaExcepcion(
        mensaje: 'Ocurrió un error inesperado al buscar la ciudad: $e',
        tipo: TipoErrorClima.desconocido,
      );
    }
  }

  Future<ClimaModelo> obtenerClimaDeCiudad(CiudadModelo ciudad) {
    return obtenerClima(
      latitud: ciudad.latitud,
      longitud: ciudad.longitud,
      nombreLugar: ciudad.nombreCompleto,
    );
  }

  Future<ClimaModelo> obtenerClima({
    required double latitud,
    required double longitud,
    required String nombreLugar,
  }) async {
    final url = Uri.parse(_urlForecast).replace(
      queryParameters: {
        'latitude': latitud.toString(),
        'longitude': longitud.toString(),
        'current': 'temperature_2m,apparent_temperature,relative_humidity_2m,surface_pressure,wind_speed_10m,weather_code,is_day',
        'daily': 'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max',
        'forecast_days': '7',
        'timezone': 'auto',
      },
    );

    try {
      final datos = await _obtenerJson(
        url,
        'Error del servidor meteorológico (Código HTTP no válido).',
      );
      return ClimaModelo.fromOpenMeteoJson(
        datos,
        nombreLugar: nombreLugar,
        latitud: latitud,
        longitud: longitud,
      );
    } on SocketException {
      throw const ClimaExcepcion(
        mensaje: 'Sin conexión a internet. No se pudo obtener el pronóstico del clima.',
        tipo: TipoErrorClima.sinInternet,
      );
    } on TimeoutException {
      throw const ClimaExcepcion(
        mensaje: 'Tiempo de espera agotado al consultar el clima.',
        tipo: TipoErrorClima.errorServidor,
      );
    } on ClimaExcepcion {
      rethrow;
    } catch (e) {
      throw ClimaExcepcion(
        mensaje: 'Error al procesar los datos del clima: $e',
        tipo: TipoErrorClima.desconocido,
      );
    }
  }

  Future<Map<String, dynamic>> _obtenerJson(Uri url, String mensajeHttp) async {
    final respuesta = await _clienteHttp
        .get(url)
        .timeout(const Duration(seconds: 10));

    if (respuesta.statusCode != 200) {
      throw ClimaExcepcion(
        mensaje: mensajeHttp,
        tipo: TipoErrorClima.errorServidor,
      );
    }

    return jsonDecode(respuesta.body) as Map<String, dynamic>;
  }
}
