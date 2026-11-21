import 'package:equatable/equatable.dart';

import 'daily_forecast.dart';

class WeatherPointData extends Equatable {
  final double latitude;
  final double longitude;
  final String? placeName;
  final double temperatureC;
  final double feelsLikeC;
  final int relativeHumidity;
  final double windSpeedKmh;
  final int precipitationProbability;
  final int weatherCodeWmo;
  final bool isDay;
  final List<DailyForecast> dailyForecasts;
  final DateTime fetchedAt;

  const WeatherPointData({
    required this.latitude,
    required this.longitude,
    this.placeName,
    required this.temperatureC,
    required this.feelsLikeC,
    required this.relativeHumidity,
    required this.windSpeedKmh,
    required this.precipitationProbability,
    required this.weatherCodeWmo,
    required this.isDay,
    this.dailyForecasts = const [],
    required this.fetchedAt,
  });

  factory WeatherPointData.fromOpenMeteoJson(
    Map<String, dynamic> json, {
    required double latitude,
    required double longitude,
    String? placeName,
  }) {
    final current = json['current'] as Map<String, dynamic>? ?? {};
    final daily = json['daily'] as Map<String, dynamic>? ?? {};

    final dates = (daily['time'] as List?)?.cast<String>() ?? const [];
    final maxTemps = (daily['temperature_2m_max'] as List?) ?? const [];
    final minTemps = (daily['temperature_2m_min'] as List?) ?? const [];
    final rainProbs =
        (daily['precipitation_probability_max'] as List?) ?? const [];
    final dailyCodes = (daily['weather_code'] as List?) ?? const [];

    final List<DailyForecast> parsedForecasts = [];
    for (int i = 0; i < dates.length; i++) {
      parsedForecasts.add(
        DailyForecast.fromOpenMeteoDaily(
          dateStr: dates[i],
          tempMaxC: i < maxTemps.length
              ? (maxTemps[i] as num?)?.toDouble() ?? 0.0
              : 0.0,
          tempMinC: i < minTemps.length
              ? (minTemps[i] as num?)?.toDouble() ?? 0.0
              : 0.0,
          precipitationProbabilityMax: i < rainProbs.length
              ? (rainProbs[i] as num?)?.toInt() ?? 0
              : 0,
          weatherCodeWmo: i < dailyCodes.length
              ? (dailyCodes[i] as num?)?.toInt() ?? 0
              : 0,
        ),
      );
    }

    final int currentRainProb = parsedForecasts.isNotEmpty
        ? parsedForecasts.first.precipitationProbabilityMax
        : 0;

    return WeatherPointData(
      latitude: latitude,
      longitude: longitude,
      placeName: placeName,
      temperatureC: (current['temperature_2m'] as num?)?.toDouble() ?? 0.0,
      feelsLikeC:
          (current['apparent_temperature'] as num?)?.toDouble() ??
          (current['temperature_2m'] as num?)?.toDouble() ??
          0.0,
      relativeHumidity: (current['relative_humidity_2m'] as num?)?.toInt() ?? 0,
      windSpeedKmh: (current['wind_speed_10m'] as num?)?.toDouble() ?? 0.0,
      precipitationProbability: currentRainProb,
      weatherCodeWmo: (current['weather_code'] as num?)?.toInt() ?? 0,
      isDay: ((current['is_day'] as num?)?.toInt() ?? 1) == 1,
      dailyForecasts: parsedForecasts,
      fetchedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'placeName': placeName,
      'temperatureC': temperatureC,
      'feelsLikeC': feelsLikeC,
      'relativeHumidity': relativeHumidity,
      'windSpeedKmh': windSpeedKmh,
      'precipitationProbability': precipitationProbability,
      'weatherCodeWmo': weatherCodeWmo,
      'isDay': isDay,
      'dailyForecasts': dailyForecasts.map((d) => d.toJson()).toList(),
      'fetchedAt': fetchedAt.toIso8601String(),
    };
  }

  factory WeatherPointData.fromJson(Map<String, dynamic> json) {
    final rawForecasts = (json['dailyForecasts'] as List?) ?? const [];

    return WeatherPointData(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      placeName: json['placeName'] as String?,
      temperatureC: (json['temperatureC'] as num?)?.toDouble() ?? 0.0,
      feelsLikeC:
          (json['feelsLikeC'] as num?)?.toDouble() ??
          (json['temperatureC'] as num?)?.toDouble() ??
          0.0,
      relativeHumidity: (json['relativeHumidity'] as num?)?.toInt() ?? 0,
      windSpeedKmh: (json['windSpeedKmh'] as num?)?.toDouble() ?? 0.0,
      precipitationProbability:
          (json['precipitationProbability'] as num?)?.toInt() ?? 0,
      weatherCodeWmo: (json['weatherCodeWmo'] as num?)?.toInt() ?? 0,
      isDay: json['isDay'] as bool? ?? true,
      dailyForecasts: rawForecasts
          .map((item) => DailyForecast.fromJson(item as Map<String, dynamic>))
          .toList(),
      fetchedAt:
          DateTime.tryParse(json['fetchedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  String get displayLocationLabel {
    if (placeName != null && placeName!.trim().isNotEmpty) {
      return placeName!.trim();
    }
    return 'Área (${latitude.toStringAsFixed(2)}, ${longitude.toStringAsFixed(2)})';
  }

  @override
  List<Object?> get props => [
    latitude,
    longitude,
    placeName,
    temperatureC,
    feelsLikeC,
    relativeHumidity,
    windSpeedKmh,
    precipitationProbability,
    weatherCodeWmo,
    isDay,
    dailyForecasts,
    fetchedAt,
  ];
}
