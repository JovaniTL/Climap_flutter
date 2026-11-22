import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../modelos/clima_modelo.dart';
import '../servicios/clima_api_servicio.dart';
import '../utilidades/evaluador_actividades.dart';

class ComparacionEstado extends Equatable {
  final bool cargando;
  final ClimaModelo? clima1;
  final ClimaModelo? clima2;
  final String? veredicto;
  final String? mensajeError;

  const ComparacionEstado({
    this.cargando = false,
    this.clima1,
    this.clima2,
    this.veredicto,
    this.mensajeError,
  });

  ComparacionEstado copyWith({
    bool? cargando,
    ClimaModelo? clima1,
    ClimaModelo? clima2,
    String? veredicto,
    String? mensajeError,
    bool limpiarError = false,
  }) {
    return ComparacionEstado(
      cargando: cargando ?? this.cargando,
      clima1: clima1 ?? this.clima1,
      clima2: clima2 ?? this.clima2,
      veredicto: veredicto ?? this.veredicto,
      mensajeError: limpiarError ? null : (mensajeError ?? this.mensajeError),
    );
  }

  @override
  List<Object?> get props => [cargando, clima1, clima2, veredicto, mensajeError];
}

/// Cubit para gestionar la comparación simultánea de dos ciudades.
class ComparacionCubit extends Cubit<ComparacionEstado> {
  final ClimaApiServicio _servicio;

  ComparacionCubit({ClimaApiServicio? servicio})
      : _servicio = servicio ?? ClimaApiServicio(),
        super(const ComparacionEstado());

  /// Realiza la consulta de ambas ciudades y calcula el veredicto comparativo
  Future<void> compararCiudades({
    required String textoCiudad1,
    required String textoCiudad2,
  }) async {
    final c1 = textoCiudad1.trim();
    final c2 = textoCiudad2.trim();

    if (c1.isEmpty || c2.isEmpty) {
      emit(
        state.copyWith(
          mensajeError: 'Por favor, escribe el nombre de ambas ciudades para comparar.',
        ),
      );
      return;
    }

    emit(state.copyWith(cargando: true, limpiarError: true));

    try {
      // 1. Buscar ambas ciudades
      final res1 = await _servicio.buscarCiudades(c1);
      final ciudad1 = res1.first;

      final res2 = await _servicio.buscarCiudades(c2);
      final ciudad2 = res2.first;

      // 2. Consultar el clima de ambas
      final clima1 = await _servicio.obtenerClima(
        latitud: ciudad1.latitud,
        longitud: ciudad1.longitud,
        nombreLugar: ciudad1.nombreCompleto,
      );

      final clima2 = await _servicio.obtenerClima(
        latitud: ciudad2.latitud,
        longitud: ciudad2.longitud,
        nombreLugar: ciudad2.nombreCompleto,
      );

      // 3. Generar el veredicto comparativo inteligente
      final veredicto = EvaluadorActividades.generarVeredictoComparativo(
        clima1: clima1,
        clima2: clima2,
      );

      emit(
        state.copyWith(
          cargando: false,
          clima1: clima1,
          clima2: clima2,
          veredicto: veredicto,
          limpiarError: true,
        ),
      );
    } on ClimaExcepcion catch (e) {
      emit(state.copyWith(cargando: false, mensajeError: e.mensaje));
    } catch (_) {
      emit(
        state.copyWith(
          cargando: false,
          mensajeError: 'Ocurrió un error al comparar las ciudades. Revisa tu conexión.',
        ),
      );
    }
  }
}

