import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/clima_bloc.dart';
import '../bloc/clima_event.dart';
import '../bloc/clima_state.dart';
import '../modelos/clima_modelo.dart';
import '../modelos/recomendacion_modelo.dart';
import '../servicios/clima_api_servicio.dart';
import 'widgets/buscador_ciudades_widget.dart';
import 'widgets/lista_pronostico_widget.dart';
import 'widgets/lista_recomendaciones_widget.dart';
import 'widgets/monito_clima_widget.dart';
import 'widgets/rejilla_detalles_clima.dart';
import 'widgets/tarjeta_clima_actual.dart';

class VistaClimaPrincipal extends StatelessWidget {
  const VistaClimaPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              BuscadorCiudadesWidget(),
              SizedBox(height: 12),
              Expanded(child: _ContenidoClima()),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContenidoClima extends StatelessWidget {
  const _ContenidoClima();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClimaBloc, ClimaEstado>(
      builder: (context, state) {
        if (state.estado == EstadoClima.cargando) {
          return const _CargandoClima();
        }

        if (state.estado == EstadoClima.error) {
          return _VistaError(
            mensaje: state.mensajeError ?? 'Ocurrió un error inesperado.',
            tipo: state.tipoError,
            onReintentar: () {
              context.read<ClimaBloc>().add(const ReintentarConsultaEvent());
            },
          );
        }

        final clima = state.clima;
        if (state.estado == EstadoClima.inicial || clima == null) {
          return const _InicioClima();
        }

        return _ClimaConsultado(
          clima: clima,
          recomendaciones: state.recomendaciones,
        );
      },
    );
  }
}

class _CargandoClima extends StatelessWidget {
  const _CargandoClima();

  @override
  Widget build(BuildContext context) {
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
}

class _InicioClima extends StatelessWidget {
  const _InicioClima();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(26),
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Escribe el nombre de tu ciudad arriba (ej. Zitácuaro, Morelia, CDMX) y pulsa "Buscar" para obtener el clima, recomendaciones y el monito interactivo.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
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
}

class _ClimaConsultado extends StatelessWidget {
  final ClimaModelo clima;
  final List<RecomendacionModelo> recomendaciones;

  const _ClimaConsultado({required this.clima, required this.recomendaciones});

  @override
  Widget build(BuildContext context) {
    final resumen = [
      TarjetaClimaActual(clima: clima),
      MonitoClimaWidget(clima: clima),
    ];
    final detalles = RejillaDetallesClima(clima: clima);
    final sugerencias = ListaRecomendacionesWidget(
      recomendaciones: recomendaciones,
    );
    final pronostico = ListaPronosticoWidget(
      pronostico: clima.pronosticoSemanal,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 600) {
          return SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: Column(children: resumen)),
                const SizedBox(width: 20),
                Expanded(
                  flex: 6,
                  child: Column(
                    children: [
                      detalles,
                      const SizedBox(height: 16),
                      sugerencias,
                      const SizedBox(height: 16),
                      pronostico,
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              ...resumen,
              const SizedBox(height: 16),
              detalles,
              const SizedBox(height: 20),
              sugerencias,
              const SizedBox(height: 20),
              pronostico,
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

class _VistaError extends StatelessWidget {
  final String mensaje;
  final TipoErrorClima? tipo;
  final VoidCallback onReintentar;

  const _VistaError({
    required this.mensaje,
    required this.tipo,
    required this.onReintentar,
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
              color: Colors.black.withAlpha(15),
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
                color: color.withAlpha(31),
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
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onReintentar,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
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
