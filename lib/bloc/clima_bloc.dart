import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../servicios/clima_api_servicio.dart';
import '../utilidades/recomendador_clima.dart';
import 'clima_event.dart';
import 'clima_state.dart';

/// BLoC principal para gestionar el estado del clima, las sugerencias y los errores.
class ClimaBloc extends Bloc<ClimaEvent, ClimaEstado> {
  final ClimaApiServicio _servicio;
  int _idSolicitudSugerencias = 0;

  ClimaBloc({ClimaApiServicio? servicio})
      : _servicio = servicio ?? ClimaApiServicio(),
        super(const ClimaEstado()) {
    on<BuscarSugerenciasEvent>(_onBuscarSugerencias);
    on<LimpiarSugerenciasEvent>(_onLimpiarSugerencias);
    on<ConsultarClimaPorTextoEvent>(_onConsultarClimaPorTexto);
    on<SeleccionarCiudadSugeridaEvent>(_onSeleccionarCiudadSugerida);
    on<ConsultarClimaPorCoordenadasEvent>(_onConsultarClimaPorCoordenadas);
    on<ReintentarConsultaEvent>(_onReintentarConsulta);
  }

  /// Busca sugerencias de ciudades conforme el usuario escribe
  Future<void> _onBuscarSugerencias(
    BuscarSugerenciasEvent event,
    Emitter<ClimaEstado> emit,
  ) async {
    final idSolicitud = ++_idSolicitudSugerencias;
    final texto = event.texto.trim();
    if (texto.length < 2) {
      emit(state.copyWith(sugerencias: const [], cargandoSugerencias: false));
      return;
    }

    emit(state.copyWith(cargandoSugerencias: true));

    try {
      final ciudades = await _servicio.buscarCiudades(texto);
      if (idSolicitud != _idSolicitudSugerencias) return;
      emit(state.copyWith(sugerencias: ciudades, cargandoSugerencias: false));
    } catch (_) {
      if (idSolicitud != _idSolicitudSugerencias) return;
      // Si falla la búsqueda rápida de sugerencias, simplemente dejamos la lista vacía
      emit(state.copyWith(sugerencias: const [], cargandoSugerencias: false));
    }
  }

  /// Limpia las sugerencias de la vista
  void _onLimpiarSugerencias(
    LimpiarSugerenciasEvent event,
    Emitter<ClimaEstado> emit,
  ) {
    _idSolicitudSugerencias++;
    emit(state.copyWith(sugerencias: const [], cargandoSugerencias: false));
  }

  /// Busca la ciudad y carga su clima a partir del texto ingresado
  Future<void> _onConsultarClimaPorTexto(
    ConsultarClimaPorTextoEvent event,
    Emitter<ClimaEstado> emit,
  ) async {
    _idSolicitudSugerencias++;
    final texto = event.nombreCiudad.trim();
    if (texto.isEmpty) {
      emit(
        state.copyWith(
          estado: EstadoClima.error,
          mensajeError: 'Por favor, escribe el nombre de una ciudad.',
          tipoError: TipoErrorClima.ciudadNoEncontrada,
          limpiarUltimoEvento: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        estado: EstadoClima.cargando,
        sugerencias: const [],
        limpiarError: true,
        ultimoEventoConsulta: event,
      ),
    );

    try {
      // 1. Buscar la ciudad para obtener latitud y longitud
      final ciudades = await _servicio.buscarCiudades(texto);
      final ciudadElegida = ciudades.first;

      // 2. Obtener el clima de esa ciudad
      final clima = await _servicio.obtenerClima(
        latitud: ciudadElegida.latitud,
        longitud: ciudadElegida.longitud,
        nombreLugar: ciudadElegida.nombreCompleto,
      );

      // 3. Generar recomendaciones inteligentes
      final recomendaciones = RecomendadorClima.generarRecomendaciones(clima);

      emit(
        state.copyWith(
          estado: EstadoClima.exitoso,
          clima: clima,
          recomendaciones: recomendaciones,
          limpiarError: true,
        ),
      );
    } on ClimaExcepcion catch (e) {
      emit(
        state.copyWith(
          estado: EstadoClima.error,
          mensajeError: e.mensaje,
          tipoError: e.tipo,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          estado: EstadoClima.error,
          mensajeError: 'Ocurrió un error inesperado al consultar el clima.',
          tipoError: TipoErrorClima.desconocido,
        ),
      );
    }
  }

  /// Carga el clima directamente para una ciudad seleccionada de la lista
  Future<void> _onSeleccionarCiudadSugerida(
    SeleccionarCiudadSugeridaEvent event,
    Emitter<ClimaEstado> emit,
  ) async {
    _idSolicitudSugerencias++;
    final ciudad = event.ciudad;

    emit(
      state.copyWith(
        estado: EstadoClima.cargando,
        sugerencias: const [],
        limpiarError: true,
        ultimoEventoConsulta: event,
      ),
    );

    try {
      final clima = await _servicio.obtenerClima(
        latitud: ciudad.latitud,
        longitud: ciudad.longitud,
        nombreLugar: ciudad.nombreCompleto,
      );

      final recomendaciones = RecomendadorClima.generarRecomendaciones(clima);

      emit(
        state.copyWith(
          estado: EstadoClima.exitoso,
          clima: clima,
          recomendaciones: recomendaciones,
          limpiarError: true,
        ),
      );
    } on ClimaExcepcion catch (e) {
      emit(
        state.copyWith(
          estado: EstadoClima.error,
          mensajeError: e.mensaje,
          tipoError: e.tipo,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          estado: EstadoClima.error,
          mensajeError: 'No se pudo cargar el clima de la ciudad seleccionada.',
          tipoError: TipoErrorClima.desconocido,
        ),
      );
    }
  }

  /// Carga el clima para unas coordenadas seleccionadas desde el mapa
  Future<void> _onConsultarClimaPorCoordenadas(
    ConsultarClimaPorCoordenadasEvent event,
    Emitter<ClimaEstado> emit,
  ) async {
    _idSolicitudSugerencias++;
    final nombre = event.nombreLugar ??
        'Coordenadas (${event.latitud.toStringAsFixed(2)}, ${event.longitud.toStringAsFixed(2)})';

    emit(
      state.copyWith(
        estado: EstadoClima.cargando,
        sugerencias: const [],
        limpiarError: true,
        ultimoEventoConsulta: event,
      ),
    );

    try {
      final clima = await _servicio.obtenerClima(
        latitud: event.latitud,
        longitud: event.longitud,
        nombreLugar: nombre,
      );

      final recomendaciones = RecomendadorClima.generarRecomendaciones(clima);

      emit(
        state.copyWith(
          estado: EstadoClima.exitoso,
          clima: clima,
          recomendaciones: recomendaciones,
          limpiarError: true,
        ),
      );
    } on ClimaExcepcion catch (e) {
      emit(
        state.copyWith(
          estado: EstadoClima.error,
          mensajeError: e.mensaje,
          tipoError: e.tipo,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          estado: EstadoClima.error,
          mensajeError: 'Error al consultar el clima en las coordenadas del mapa.',
          tipoError: TipoErrorClima.desconocido,
        ),
      );
    }
  }

  /// Reintenta la última consulta en caso de error
  void _onReintentarConsulta(
    ReintentarConsultaEvent event,
    Emitter<ClimaEstado> emit,
  ) {
    final ultimoEvento = state.ultimoEventoConsulta;
    if (ultimoEvento != null) {
      add(ultimoEvento);
    }
  }
}
