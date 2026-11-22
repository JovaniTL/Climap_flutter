import 'package:equatable/equatable.dart';
import '../modelos/ciudad_modelo.dart';

abstract class ClimaEvent extends Equatable {
  const ClimaEvent();

  @override
  List<Object?> get props => [];
}

/// Se dispara mientras el usuario escribe en el campo de texto para mostrar sugerencias.
class BuscarSugerenciasEvent extends ClimaEvent {
  final String texto;

  const BuscarSugerenciasEvent(this.texto);

  @override
  List<Object?> get props => [texto];
}

/// Limpia la lista desplegable de sugerencias.
class LimpiarSugerenciasEvent extends ClimaEvent {
  const LimpiarSugerenciasEvent();
}

/// Se dispara cuando el usuario presiona el botón "Buscar" con el texto de la caja.
class ConsultarClimaPorTextoEvent extends ClimaEvent {
  final String nombreCiudad;

  const ConsultarClimaPorTextoEvent(this.nombreCiudad);

  @override
  List<Object?> get props => [nombreCiudad];
}

/// Se dispara cuando el usuario toca una de las sugerencias de la lista.
class SeleccionarCiudadSugeridaEvent extends ClimaEvent {
  final CiudadModelo ciudad;

  const SeleccionarCiudadSugeridaEvent(this.ciudad);

  @override
  List<Object?> get props => [ciudad];
}

/// Se dispara desde el mapa interactivo al pulsar el botón del punto central.
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

/// Permite reintentar la última petición fallida.
class ReintentarConsultaEvent extends ClimaEvent {
  const ReintentarConsultaEvent();
}

