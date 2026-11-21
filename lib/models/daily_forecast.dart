import 'package:equatable/equatable.dart';

class DailyForecast extends Equatable {
  final DateTime date;
  final double tempMaxC;
  final double tempMinC;
  final int precipitationProbabilityMax;
  final int weatherCodeWmo;

  const DailyForecast({
    required this.date,
    required this.tempMaxC,
    required this.tempMinC,
    required this.precipitationProbabilityMax,
    required this.weatherCodeWmo,
  });

  factory DailyForecast.fromOpenMeteoDaily({
    required String dateStr,
    required double tempMaxC,
    required double tempMinC,
    required int precipitationProbabilityMax,
    required int weatherCodeWmo,
  }) {
    return DailyForecast(
      date: DateTime.tryParse(dateStr) ?? DateTime.now(),
      tempMaxC: tempMaxC,
      tempMinC: tempMinC,
      precipitationProbabilityMax: precipitationProbabilityMax,
      weatherCodeWmo: weatherCodeWmo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'tempMaxC': tempMaxC,
      'tempMinC': tempMinC,
      'precipitationProbabilityMax': precipitationProbabilityMax,
      'weatherCodeWmo': weatherCodeWmo,
    };
  }

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      tempMaxC: (json['tempMaxC'] as num?)?.toDouble() ?? 0.0,
      tempMinC: (json['tempMinC'] as num?)?.toDouble() ?? 0.0,
      precipitationProbabilityMax:
          (json['precipitationProbabilityMax'] as num?)?.toInt() ?? 0,
      weatherCodeWmo: (json['weatherCodeWmo'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [
    date,
    tempMaxC,
    tempMinC,
    precipitationProbabilityMax,
    weatherCodeWmo,
  ];
}
