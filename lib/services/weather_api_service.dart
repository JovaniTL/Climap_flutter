import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/weather_constants.dart';
import '../models/search_place.dart';
import '../models/weather_point_data.dart';

class WeatherApiException implements Exception {
  final String message;
  WeatherApiException(this.message);

  @override
  String toString() => message;
}

class WeatherApiService {
  final http.Client _client;

  WeatherApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<WeatherPointData> fetchWeatherByCoordinates({
    required double latitude,
    required double longitude,
    String? placeName,
    int forecastDays = WeatherConstants.forecastDays,
  }) async {
    final uri = Uri.parse(WeatherConstants.forecastBaseUrl).replace(
      queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current': 'temperature_2m,apparent_temperature,relative_humidity_2m,weather_code,wind_speed_10m,is_day',
        'daily': 'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max',
        'forecast_days': forecastDays.toString(),
        'timezone': 'auto',
      },
    );

    try {
      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        throw WeatherApiException(
          'Error al consultar el clima (${response.statusCode}).',
        );
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return WeatherPointData.fromOpenMeteoJson(
        decoded,
        latitude: latitude,
        longitude: longitude,
        placeName: placeName,
      );
    } on WeatherApiException {
      rethrow;
    } catch (_) {
      throw WeatherApiException(
        'No se pudo obtener el pronóstico. Revisa tu conexión a internet.',
      );
    }
  }

  Future<List<SearchPlace>> searchPlacesByName(
    String query, {
    int count = 5,
    String language = 'es',
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];

    final uri = Uri.parse(WeatherConstants.geocodingBaseUrl).replace(
      queryParameters: {
        'name': trimmed,
        'count': count.toString(),
        'language': language,
        'format': 'json',
      },
    );

    try {
      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        throw WeatherApiException(
          'Error al buscar lugares (${response.statusCode}).',
        );
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final results = decoded['results'] as List?;
      if (results == null || results.isEmpty) {
        return const [];
      }

      return results
          .map(
            (item) =>
                SearchPlace.fromOpenMeteoJson(item as Map<String, dynamic>),
          )
          .toList();
    } on WeatherApiException {
      rethrow;
    } catch (_) {
      throw WeatherApiException('No se pudo realizar la búsqueda de lugares.');
    }
  }

  void dispose() {
    _client.close();
  }
}
