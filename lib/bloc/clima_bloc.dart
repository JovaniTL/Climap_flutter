import 'package:flutter_bloc/flutter_bloc.dart';

import '../modelos/clima_modelo.dart';
import '../servicios/clima_api_servicio.dart';
import '../utilidades/recomendador_clima.dart';
import 'clima_event.dart';
import 'clima_state.dart';

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
      emit(state.copyWith(sugerencias: const [], cargandoSugerencias: false));
    }
  }

  void _onLimpiarSugerencias(
    LimpiarSugerenciasEvent event,
    Emitter<ClimaEstado> emit,
  ) {
    _idSolicitudSugerencias++;
    emit(state.copyWith(sugerencias: const [], cargandoSugerencias: false));
  }

  Future<void> _onConsultarClimaPorTexto(
    ConsultarClimaPorTextoEvent event,
    Emitter<ClimaEstado> emit,
  ) async {
    final texto = event.nombreCiudad.trim();
    if (texto.isEmpty) {
      _idSolicitudSugerencias++;
      emit(
        state.copyWith(
          estado: EstadoClima.error,
          cargandoSugerencias: false,
          mensajeError: 'Por favor, escribe el nombre de una ciudad.',
          tipoError: TipoErrorClima.ciudadNoEncontrada,
          limpiarUltimoEvento: true,
        ),
      );
      return;
    }

    await _cargarClima(
      emit,
      eventoConsulta: event,
      obtenerClima: () async {
        final ciudades = await _servicio.buscarCiudades(texto);
        return _servicio.obtenerClimaDeCiudad(ciudades.first);
      },
      errorInesperado: 'Ocurrió un error inesperado al consultar el clima.',
    );
  }

  Future<void> _onSeleccionarCiudadSugerida(
    SeleccionarCiudadSugeridaEvent event,
    Emitter<ClimaEstado> emit,
  ) {
    final ciudad = event.ciudad;
    return _cargarClima(
      emit,
      eventoConsulta: event,
      obtenerClima: () => _servicio.obtenerClimaDeCiudad(ciudad),
      errorInesperado: 'No se pudo cargar el clima de la ciudad seleccionada.',
    );
  }

  Future<void> _onConsultarClimaPorCoordenadas(
    ConsultarClimaPorCoordenadasEvent event,
    Emitter<ClimaEstado> emit,
  ) {
    final latitud = event.latitud;
    final longitud = event.longitud;
    final nombre =
        event.nombreLugar ??
        'Coordenadas (${latitud.toStringAsFixed(2)}, ${longitud.toStringAsFixed(2)})';

    return _cargarClima(
      emit,
      eventoConsulta: event,
      obtenerClima: () => _servicio.obtenerClima(
        latitud: latitud,
        longitud: longitud,
        nombreLugar: nombre,
      ),
      errorInesperado:
          'Error al consultar el clima en las coordenadas del mapa.',
    );
  }

  Future<void> _cargarClima(
    Emitter<ClimaEstado> emit, {
    required ClimaEvent eventoConsulta,
    required Future<ClimaModelo> Function() obtenerClima,
    required String errorInesperado,
  }) async {
    _idSolicitudSugerencias++;
    emit(
      state.copyWith(
        estado: EstadoClima.cargando,
        sugerencias: const [],
        cargandoSugerencias: false,
        limpiarError: true,
        ultimoEventoConsulta: eventoConsulta,
      ),
    );

    try {
      final clima = await obtenerClima();
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
          mensajeError: errorInesperado,
          tipoError: TipoErrorClima.desconocido,
        ),
      );
    }
  }

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
