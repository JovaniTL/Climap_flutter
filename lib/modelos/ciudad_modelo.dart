import 'package:equatable/equatable.dart';

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

  factory CiudadModelo.fromOpenMeteoJson(Map<String, dynamic> json) {
    return CiudadModelo(
      nombre: json['name'] as String? ?? 'Ubicación desconocida',
      estado: json['admin1'] as String?,
      pais: json['country'] as String? ?? '',
      latitud: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitud: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String get nombreCompleto {
    final region = estado?.trim() ?? '';
    final nombrePais = pais.trim();
    final partes = <String>[
      nombre,
      if (region.isNotEmpty) region,
      if (nombrePais.isNotEmpty) nombrePais,
    ];
    return partes.join(', ');
  }

  @override
  List<Object?> get props => [nombre, estado, pais, latitud, longitud];
}
