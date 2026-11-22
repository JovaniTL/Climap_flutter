import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/clima_bloc.dart';
import '../bloc/clima_event.dart';
import '../bloc/clima_state.dart';
import '../servicios/clima_api_servicio.dart';
import 'widgets/buscador_ciudades_widget.dart';
import 'widgets/lista_pronostico_widget.dart';
import 'widgets/lista_recomendaciones_widget.dart';
import 'widgets/monito_clima_widget.dart';
import 'widgets/notificacion_clima_overlay.dart';
import 'widgets/rejilla_detalles_clima.dart';
import 'widgets/tarjeta_clima_actual.dart';

/// Vista principal que contiene la búsqueda, gestión de errores, monito climático,
/// detalles atmosféricos, recomendaciones y pronóstico semanal.
class VistaClimaPrincipal extends StatelessWidget {
  const VistaClimaPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              // 1. Buscador siempre visible en la parte superior
              const BuscadorCiudadesWidget(),
              const SizedBox(height: 12),

              // 2. Contenido dinámico según el estado de BLoC
              Expanded(
                child: BlocConsumer<ClimaBloc, ClimaEstado>(
                  listenWhen: (anterior, actual) =>
                      actual.estado == EstadoClima.exitoso &&
                      actual.clima != null &&
                      actual.clima != anterior.clima,
                  listener: (context, state) {
                    NotificacionClimaOverlay.mostrar(context, state.clima!);
                  },
                  builder: (context, state) {
                    // Estado de Carga
                    if (state.estado == EstadoClima.cargando) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(
                              'Consultando servicio meteorológico...',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      );
                    }

                    // Estado de Error (Sin internet, ciudad no encontrada, falla de API)
                    if (state.estado == EstadoClima.error) {
                      return _ConstruirVistaError(
                        mensaje: state.mensajeError ?? 'Ocurrió un error inesperado.',
                        tipo: state.tipoError,
                        onReintentar: state.ultimoEventoConsulta != null
                            ? () {
                                context
                                    .read<ClimaBloc>()
                                    .add(const ReintentarConsultaEvent());
                              }
                            : null,
                      );
                    }

                    // Estado Inicial (Pantalla de bienvenida)
                    if (state.estado == EstadoClima.inicial || state.clima == null) {
                      return Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.cloud_sync_rounded,
                                  size: 72,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                '¡Consulta el clima de cualquier ciudad!',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 32),
                                child: Text(
                                  'Escribe el nombre de tu ciudad arriba (ej. Zitácuaro, Morelia, CDMX) y pulsa "Buscar" para obtener el clima, recomendaciones y el monito interactivo.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Botones rápidos de ejemplo
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                alignment: WrapAlignment.center,
                                children: [
                                  _ChipCiudadRapida(nombre: 'Zitácuaro'),
                                  _ChipCiudadRapida(nombre: 'Morelia'),
                                  _ChipCiudadRapida(nombre: 'Ciudad de México'),
                                  _ChipCiudadRapida(nombre: 'Guadalajara'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Estado Exitoso: Se adapta a celular o tablet
                    final clima = state.clima!;
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final esPantallaAncha = constraints.maxWidth >= 600;

                        if (esPantallaAncha) {
                          // Diseño para Tablets / Pantallas anchas (2 columnas)
                          return SingleChildScrollView(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Columna Izquierda: Tarjeta de Clima + Monito
                                Expanded(
                                  flex: 5,
                                  child: Column(
                                    children: [
                                      TarjetaClimaActual(clima: clima),
                                      MonitoClimaWidget(clima: clima),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 20),
                                // Columna Derecha: Detalles, Recomendaciones y Pronóstico
                                Expanded(
                                  flex: 6,
                                  child: Column(
                                    children: [
                                      RejillaDetallesClima(clima: clima),
                                      const SizedBox(height: 16),
                                      ListaRecomendacionesWidget(
                                        recomendaciones: state.recomendaciones,
                                      ),
                                      const SizedBox(height: 16),
                                      ListaPronosticoWidget(
                                        pronostico: clima.pronosticoSemanal,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        // Diseño para Celulares (Columna única desplazable)
                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              TarjetaClimaActual(clima: clima),
                              MonitoClimaWidget(clima: clima),
                              const SizedBox(height: 16),
                              RejillaDetallesClima(clima: clima),
                              const SizedBox(height: 20),
                              ListaRecomendacionesWidget(
                                recomendaciones: state.recomendaciones,
                              ),
                              const SizedBox(height: 20),
                              ListaPronosticoWidget(
                                pronostico: clima.pronosticoSemanal,
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget para mostrar errores descriptivos con opción de reintentar
class _ConstruirVistaError extends StatelessWidget {
  final String mensaje;
  final TipoErrorClima? tipo;
  final VoidCallback? onReintentar;

  const _ConstruirVistaError({
    required this.mensaje,
    required this.tipo,
    this.onReintentar,
  });

  @override
  Widget build(BuildContext context) {
    IconData icono;
    Color color;

    switch (tipo) {
      case TipoErrorClima.sinInternet:
        icono = Icons.wifi_off_rounded;
        color = Colors.redAccent;
        break;
      case TipoErrorClima.ciudadNoEncontrada:
        icono = Icons.location_off_rounded;
        color = Colors.orangeAccent;
        break;
      case TipoErrorClima.errorServidor:
        icono = Icons.cloud_off_rounded;
        color = Colors.amber.shade800;
        break;
      default:
        icono = Icons.error_outline_rounded;
        color = Colors.red;
    }

    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icono, size: 54, color: color),
            ),
            const SizedBox(height: 16),
            const Text(
              'No pudimos completar la consulta',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              mensaje,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onReintentar != null) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onReintentar,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChipCiudadRapida extends StatelessWidget {
  final String nombre;

  const _ChipCiudadRapida({required this.nombre});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: const Icon(Icons.search, size: 16),
      label: Text(nombre),
      onPressed: () {
        context.read<ClimaBloc>().add(ConsultarClimaPorTextoEvent(nombre));
      },
    );
  }
}

