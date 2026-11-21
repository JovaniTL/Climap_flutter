import 'package:equatable/equatable.dart';

class SearchPlace extends Equatable {
  final String name;
  final String? admin1;
  final String country;
  final double latitude;
  final double longitude;

  const SearchPlace({
    required this.name,
    this.admin1,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  factory SearchPlace.fromOpenMeteoJson(Map<String, dynamic> json) {
    return SearchPlace(
      name: json['name'] as String? ?? 'Ubicación',
      admin1: json['admin1'] as String?,
      country: json['country'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String get subtitle {
    final parts = <String>[
      if (admin1 != null && admin1!.trim().isNotEmpty) admin1!.trim(),
      if (country.trim().isNotEmpty) country.trim(),
    ];
    return parts.join(', ');
  }

  @override
  List<Object?> get props => [name, admin1, country, latitude, longitude];
}
