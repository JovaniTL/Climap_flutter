import 'package:equatable/equatable.dart';
import '../modelos/ciudad_modelo.dart';
import '../modelos/clima_modelo.dart';
import '../modelos/recomendacion_modelo.dart';
import '../servicios/clima_api_servicio.dart';
import 'clima_event.dart';

enum EstadoClima {
  inicial,
  cargando,
  exitoso,
  error,
}

class ClimaEstado extends Equatable {
  final EstadoClima estado;
  final ClimaModelo? clima;
  final List<CiudadModelo> sugerencias;
  final bool cargandoSugerencias;
  final String? mensajeError;
  final TipoErrorClima? tipoError;
  final List<RecomendacionModelo> recomendaciones;
  final ClimaEvent? ultimoEventoConsulta;

  const ClimaEstado({
    this.estado = EstadoClima.inicial,
    this.clima,
    this.sugerencias = const [],
    this.cargandoSugerencias = false,
    this.mensajeError,
    this.tipoError,
    this.recomendaciones = const [],
    this.ultimoEventoConsulta,
  });

  ClimaEstado copyWith({
    EstadoClima? estado,
    ClimaModelo? clima,
    List<CiudadModelo>? sugerencias,
    bool? cargandoSugerencias,
    String? mensajeError,
    TipoErrorClima? tipoError,
    bool limpiarError = false,
    List<RecomendacionModelo>? recomendaciones,
    ClimaEvent? ultimoEventoConsulta,
    bool limpiarUltimoEvento = false,
  }) {
    return ClimaEstado(
      estado: estado ?? this.estado,
      clima: clima ?? this.clima,
      sugerencias: sugerencias ?? this.sugerencias,
      cargandoSugerencias: cargandoSugerencias ?? this.cargandoSugerencias,
      mensajeError: limpiarError ? null : (mensajeError ?? this.mensajeError),
      tipoError: limpiarError ? null : (tipoError ?? this.tipoError),
      recomendaciones: recomendaciones ?? this.recomendaciones,
      ultimoEventoConsulta: limpiarUltimoEvento
          ? null
          : (ultimoEventoConsulta ?? this.ultimoEventoConsulta),
    );
  }

  @override
  List<Object?> get props => [
    estado,
    clima,
    sugerencias,
    cargandoSugerencias,
    mensajeError,
    tipoError,
    recomendaciones,
    ultimoEventoConsulta,
  ];
}

