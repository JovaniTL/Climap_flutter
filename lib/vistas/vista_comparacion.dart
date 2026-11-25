import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/comparacion_cubit.dart';
import '../modelos/clima_modelo.dart';
import '../utilidades/clima_traductor.dart';
import '../utilidades/evaluador_actividades.dart';

class VistaComparacion extends StatefulWidget {
  const VistaComparacion({super.key});

  @override
  State<VistaComparacion> createState() => _VistaComparacionState();
}

class _VistaComparacionState extends State<VistaComparacion> {
  final TextEditingController _ciudad1Controller = TextEditingController(
    text: 'Zitácuaro',
  );
  final TextEditingController _ciudad2Controller = TextEditingController(
    text: 'Morelia',
  );

  @override
  void dispose() {
    _ciudad1Controller.dispose();
    _ciudad2Controller.dispose();
    super.dispose();
  }

  void _ejecutarComparacion() {
    FocusScope.of(context).unfocus();
    context.read<ComparacionCubit>().compararCiudades(
      textoCiudad1: _ciudad1Controller.text,
      textoCiudad2: _ciudad2Controller.text,
    );
  }

  void _compararEjemplo(String ciudad1, String ciudad2) {
    _ciudad1Controller.text = ciudad1;
    _ciudad2Controller.text = ciudad2;
    _ejecutarComparacion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comparador de Climas'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _FormularioComparacion(
                ciudad1Controller: _ciudad1Controller,
                ciudad2Controller: _ciudad2Controller,
                onComparar: _ejecutarComparacion,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  ActionChip(
                    label: const Text('Zitácuaro vs Morelia'),
                    onPressed: () => _compararEjemplo('Zitácuaro', 'Morelia'),
                  ),
                  ActionChip(
                    label: const Text('Guadalajara vs Monterrey'),
                    onPressed: () =>
                        _compararEjemplo('Guadalajara', 'Monterrey'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const _EstadoComparacion(),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormularioComparacion extends StatelessWidget {
  final TextEditingController ciudad1Controller;
  final TextEditingController ciudad2Controller;
  final VoidCallback onComparar;

  const _FormularioComparacion({
    required this.ciudad1Controller,
    required this.ciudad2Controller,
    required this.onComparar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _campoCiudad(
            ciudad1Controller,
            'Primera Ciudad',
            'Ej. Zitácuaro',
            Colors.blueAccent,
          ),
          const SizedBox(height: 12),
          _campoCiudad(
            ciudad2Controller,
            'Segunda Ciudad',
            'Ej. Morelia',
            Colors.orangeAccent,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onComparar,
              icon: const Icon(Icons.compare_arrows_rounded),
              label: const Text(
                'Comparar Climas',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _campoCiudad(
    TextEditingController controlador,
    String etiqueta,
    String ejemplo,
    Color color,
  ) {
    return TextField(
      controller: controlador,
      decoration: InputDecoration(
        labelText: etiqueta,
        hintText: ejemplo,
        prefixIcon: Icon(Icons.location_city, color: color),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
      ),
    );
  }
}

class _EstadoComparacion extends StatelessWidget {
  const _EstadoComparacion();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ComparacionCubit, ComparacionEstado>(
      builder: (context, state) {
        if (state.cargando) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Analizando condiciones meteorológicas...',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          );
        }

        if (state.mensajeError != null) {
          final colorScheme = Theme.of(context).colorScheme;
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.error.withAlpha(102)),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: colorScheme.error),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    state.mensajeError!,
                    style: TextStyle(color: colorScheme.onErrorContainer),
                  ),
                ),
              ],
            ),
          );
        }

        if (state.clima1 != null && state.clima2 != null) {
          return _ResultadoComparacion(
            clima1: state.clima1!,
            clima2: state.clima2!,
            veredicto: state.veredicto ?? '',
          );
        }

        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: Text(
              'Selecciona dos ciudades y pulsa "Comparar Climas" para ver la comparativa.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}

class _ResultadoComparacion extends StatelessWidget {
  final ClimaModelo clima1;
  final ClimaModelo clima2;
  final String veredicto;

  const _ResultadoComparacion({
    required this.clima1,
    required this.clima2,
    required this.veredicto,
  });

  @override
  Widget build(BuildContext context) {
    final puntaje1 = EvaluadorActividades.calcularPuntajeActividad(clima1);
    final puntaje2 = EvaluadorActividades.calcularPuntajeActividad(clima2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TarjetaVeredicto(veredicto: veredicto),
        const SizedBox(height: 18),

        LayoutBuilder(
          builder: (context, constraints) {
            final tarjeta1 = _TarjetaResumenCiudad(
              clima: clima1,
              puntaje: puntaje1,
              colorTema: Colors.blueAccent,
            );
            final tarjeta2 = _TarjetaResumenCiudad(
              clima: clima2,
              puntaje: puntaje2,
              colorTema: Colors.orangeAccent,
            );
            if (constraints.maxWidth < 360) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  tarjeta1,
                  const SizedBox(height: 12),
                  tarjeta2,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: tarjeta1),
                const SizedBox(width: 12),
                Expanded(child: tarjeta2),
              ],
            );
          },
        ),

        const SizedBox(height: 20),

        _TablaComparativa(clima1: clima1, clima2: clima2),
      ],
    );
  }
}

class _TarjetaVeredicto extends StatelessWidget {
  final String veredicto;

  const _TarjetaVeredicto({required this.veredicto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withAlpha(77),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.stars_rounded, color: Colors.amberAccent, size: 24),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Veredicto de Actividades al Aire Libre',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            veredicto,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _TablaComparativa extends StatelessWidget {
  final ClimaModelo clima1;
  final ClimaModelo clima2;

  const _TablaComparativa({required this.clima1, required this.clima2});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tabla Comparativa de Indicadores',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _FilaComparativa(
            parametro: 'Temperatura actual',
            valor1: '${clima1.temperatura.toStringAsFixed(1)} °C',
            valor2: '${clima2.temperatura.toStringAsFixed(1)} °C',
          ),
          const Divider(height: 16),
          _FilaComparativa(
            parametro: 'Sensación térmica',
            valor1: '${clima1.sensacionTermica.toStringAsFixed(1)} °C',
            valor2: '${clima2.sensacionTermica.toStringAsFixed(1)} °C',
          ),
          const Divider(height: 16),
          _FilaComparativa(
            parametro: 'Probabilidad de lluvia',
            valor1: '${clima1.probabilidadLluvia}%',
            valor2: '${clima2.probabilidadLluvia}%',
          ),
          const Divider(height: 16),
          _FilaComparativa(
            parametro: 'Velocidad del viento',
            valor1: '${clima1.velocidadViento.toStringAsFixed(1)} km/h',
            valor2: '${clima2.velocidadViento.toStringAsFixed(1)} km/h',
          ),
          const Divider(height: 16),
          _FilaComparativa(
            parametro: 'Humedad relativa',
            valor1: '${clima1.humedad}%',
            valor2: '${clima2.humedad}%',
          ),
          const Divider(height: 16),
          _FilaComparativa(
            parametro: 'Presión atmosférica',
            valor1: '${clima1.presionAtmosferica.toStringAsFixed(0)} hPa',
            valor2: '${clima2.presionAtmosferica.toStringAsFixed(0)} hPa',
          ),
        ],
      ),
    );
  }
}

class _TarjetaResumenCiudad extends StatelessWidget {
  final ClimaModelo clima;
  final int puntaje;
  final Color colorTema;

  const _TarjetaResumenCiudad({
    required this.clima,
    required this.puntaje,
    required this.colorTema,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final icono = ClimaTraductor.obtenerIcono(
      clima.codigoClima,
      esDeDia: clima.esDeDia,
    );
    final descripcion = ClimaTraductor.obtenerDescripcion(
      clima.codigoClima,
      esDeDia: clima.esDeDia,
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorTema.withAlpha(77), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            clima.nombreLugar.split(',').first,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Icon(icono, size: 36, color: colorTema),
          const SizedBox(height: 6),
          Text(
            '${clima.temperatura.round()}°C',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          Text(
            descripcion,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              Text(
                'Aptitud: $puntaje%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: puntaje >= 60 ? Colors.green : Colors.orange,
                ),
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: puntaje / 100.0,
                  minHeight: 6,
                  color: puntaje >= 60 ? Colors.green : Colors.orange,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilaComparativa extends StatelessWidget {
  final String parametro;
  final String valor1;
  final String valor2;

  const _FilaComparativa({
    required this.parametro,
    required this.valor1,
    required this.valor2,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Text(
            parametro,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            valor1,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            valor2,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.orangeAccent,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
