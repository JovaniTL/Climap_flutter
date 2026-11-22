import 'package:equatable/equatable.dart';

/// Modelo que representa una ciudad o ubicación encontrada mediante la API de geocodificación.
class CiudadModelo extends Equatable {
  final String nombre;
  final String? estado;
  final String pais;
  final double latitud;
  final double longitud;

  const CiudadModelo({
    required this.nombre,
    this.estado,
    required this.pais,
    required this.latitud,
    required this.longitud,
  });

  /// Crea una instancia a partir del JSON que devuelve Open-Meteo Geocoding API.
  factory CiudadModelo.fromOpenMeteoJson(Map<String, dynamic> json) {
    return CiudadModelo(
      nombre: json['name'] as String? ?? 'Ubicación desconocida',
      estado: json['admin1'] as String?,
      pais: json['country'] as String? ?? '',
      latitud: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitud: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Devuelve el nombre completo legible (ejemplo: "Zitácuaro, Michoacán, México").
  String get nombreCompleto {
    final partes = <String>[
      nombre,
      if (estado != null && estado!.trim().isNotEmpty) estado!.trim(),
      if (pais.trim().isNotEmpty) pais.trim(),
    ];
    return partes.join(', ');
  }

  @override
  List<Object?> get props => [nombre, estado, pais, latitud, longitud];
}

