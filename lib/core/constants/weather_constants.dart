class WeatherConstants {
  WeatherConstants._();

  static const String forecastBaseUrl =
      'https://api.open-meteo.com/v1/forecast';
  static const String geocodingBaseUrl =
      'https://geocoding-api.open-meteo.com/v1/search';

  static const double defaultSelectionRadiusMeters =
      10000.0; // Radio del circulo por defecto del mapa (10km)

  static const int forecastDays = 7; // Dias del pronostico
}
