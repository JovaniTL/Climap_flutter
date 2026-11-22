import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../modelos/ciudad_modelo.dart';
import '../modelos/clima_modelo.dart';

/// Tipos de error categorizados para mostrar mensajes específicos al usuario.
enum TipoErrorClima {
  sinInternet,
  ciudadNoEncontrada,
  errorServidor,
  desconocido,
}

/// Excepción personalizada para los errores de clima.
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

/// Servicio encargado de realizar las peticiones HTTP a Open-Meteo.
class ClimaApiServicio {
  static const String _urlGeocoding = 'https://geocoding-api.open-meteo.com/v1/search';
  static const String _urlForecast = 'https://api.open-meteo.com/v1/forecast';

  final http.Client _clienteHttp;

  ClimaApiServicio({http.Client? clienteHttp})
      : _clienteHttp = clienteHttp ?? http.Client();

  /// Busca ciudades que coincidan con el texto ingresado por el usuario.
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
      final respuesta = await _clienteHttp
          .get(url)
          .timeout(const Duration(seconds: 10));

      if (respuesta.statusCode != 200) {
        throw const ClimaExcepcion(
          mensaje: 'El servicio de búsqueda no respondió correctamente.',
          tipo: TipoErrorClima.errorServidor,
        );
      }

      final datos = jsonDecode(respuesta.body) as Map<String, dynamic>;
      final resultados = datos['results'] as List?;

      if (resultados == null || resultados.isEmpty) {
        throw ClimaExcepcion(
          mensaje: 'No se encontraron ciudades con el nombre "$consulta". Verifica la ortografía.',
          tipo: TipoErrorClima.ciudadNoEncontrada,
        );
      }

      return resultados
          .map((item) => CiudadModelo.fromOpenMeteoJson(item as Map<String, dynamic>))
          .toList();
    } on SocketException {
      throw const ClimaExcepcion(
        mensaje: 'Sin conexión a internet. Revisa tu red Wi-Fi o datos móviles.',
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
        mensaje: 'Ocurrió un error inesperado al buscar la ciudad: ${e.toString()}',
        tipo: TipoErrorClima.desconocido,
      );
    }
  }

  /// Obtiene los datos meteorológicos actuales y el pronóstico de 7 días para unas coordenadas.
  Future<ClimaModelo> obtenerClima({
    required double latitud,
    required double longitud,
    required String nombreLugar,
  }) async {
    final url = Uri.parse(_urlForecast).replace(
      queryParameters: {
        'latitude': latitud.toString(),
        'longitude': longitud.toString(),
        'current':
            'temperature_2m,apparent_temperature,relative_humidity_2m,surface_pressure,wind_speed_10m,weather_code,is_day',
        'daily':
            'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max',
        'forecast_days': '7',
        'timezone': 'auto',
      },
    );

    try {
      final respuesta = await _clienteHttp
          .get(url)
          .timeout(const Duration(seconds: 10));

      if (respuesta.statusCode != 200) {
        throw const ClimaExcepcion(
          mensaje: 'Error del servidor meteorológico (Código HTTP no válido).',
          tipo: TipoErrorClima.errorServidor,
        );
      }

      final datos = jsonDecode(respuesta.body) as Map<String, dynamic>;

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
        mensaje: 'Error al procesar los datos del clima: ${e.toString()}',
        tipo: TipoErrorClima.desconocido,
      );
    }
  }
}

