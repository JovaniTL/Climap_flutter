import 'package:equatable/equatable.dart';

import '../modelos/ciudad_modelo.dart';

abstract class ClimaEvent extends Equatable {
  const ClimaEvent();

  @override
  List<Object?> get props => [];
}

class BuscarSugerenciasEvent extends ClimaEvent {
  final String texto;

  const BuscarSugerenciasEvent(this.texto);

  @override
  List<Object?> get props => [texto];
}

class LimpiarSugerenciasEvent extends ClimaEvent {
  const LimpiarSugerenciasEvent();
}

class ConsultarClimaPorTextoEvent extends ClimaEvent {
  final String nombreCiudad;

  const ConsultarClimaPorTextoEvent(this.nombreCiudad);

  @override
  List<Object?> get props => [nombreCiudad];
}

class SeleccionarCiudadSugeridaEvent extends ClimaEvent {
  final CiudadModelo ciudad;

  const SeleccionarCiudadSugeridaEvent(this.ciudad);

  @override
  List<Object?> get props => [ciudad];
}

class ConsultarClimaPorCoordenadasEvent extends ClimaEvent {
  final double latitud;
  final double longitud;
  final String? nombreLugar;

  const ConsultarClimaPorCoordenadasEvent({
    required this.latitud,
    required this.longitud,
    this.nombreLugar,
  });

  @override
  List<Object?> get props => [latitud, longitud, nombreLugar];
}

class ReintentarConsultaEvent extends ClimaEvent {
  const ReintentarConsultaEvent();
}
