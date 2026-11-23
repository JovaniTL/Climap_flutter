import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/comparacion_cubit.dart';
import '../modelos/clima_modelo.dart';
import '../utilidades/clima_traductor.dart';
import '../utilidades/evaluador_actividades.dart';

/// Vista para comparar el estado climático entre dos ciudades y calcular
/// cuál es más ideal para realizar actividades al aire libre (ej. salir a caminar).
class VistaComparacion extends StatefulWidget {
  const VistaComparacion({super.key});

  @override
  State<VistaComparacion> createState() => _VistaComparacionState();
}

class _VistaComparacionState extends State<VistaComparacion> {
  final TextEditingController _ciudad1Controller =
      TextEditingController(text: 'Zitácuaro');
  final TextEditingController _ciudad2Controller =
      TextEditingController(text: 'Morelia');

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comparador de Climas'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sección de entrada: Ciudad 1 y Ciudad 2
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Campo Ciudad 1
                    TextField(
                      controller: _ciudad1Controller,
                      decoration: const InputDecoration(
                        labelText: 'Primera Ciudad',
                        hintText: 'Ej. Zitácuaro',
                        prefixIcon: Icon(Icons.location_city, color: Colors.blueAccent),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Campo Ciudad 2
                    TextField(
                      controller: _ciudad2Controller,
                      decoration: const InputDecoration(
                        labelText: 'Segunda Ciudad',
                        hintText: 'Ej. Morelia',
                        prefixIcon: Icon(Icons.location_city, color: Colors.orangeAccent),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Botón para comparar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _ejecutarComparacion,
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
              ),

              const SizedBox(height: 12),
              // Chips de sugerencia rápida
              Wrap(
                spacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  ActionChip(
                    label: const Text('Zitácuaro vs Morelia'),
                    onPressed: () {
                      _ciudad1Controller.text = 'Zitácuaro';
                      _ciudad2Controller.text = 'Morelia';
                      _ejecutarComparacion();
                    },
                  ),
                  ActionChip(
                    label: const Text('Guadalajara vs Monterrey'),
                    onPressed: () {
                      _ciudad1Controller.text = 'Guadalajara';
                      _ciudad2Controller.text = 'Monterrey';
                      _ejecutarComparacion();
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Resultados de la comparación
              BlocBuilder<ComparacionCubit, ComparacionEstado>(
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
                        border: Border.all(
                          color: colorScheme.error.withValues(alpha: 0.4),
                        ),
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
                    return _ConstruirResultadoComparacion(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConstruirResultadoComparacion extends StatelessWidget {
  final ClimaModelo clima1;
  final ClimaModelo clima2;
  final String veredicto;

  const _ConstruirResultadoComparacion({
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
        // 1. Tarjeta del Veredicto Inteligente
        Container(
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
                color: Colors.green.withValues(alpha: 0.3),
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
        ),

        const SizedBox(height: 18),

        // 2. Tarjetas de Ambas Ciudades (apiladas en pantallas muy angostas)
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

        // 3. Tabla comparativa de métricas detalladas
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
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
        ),
      ],
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
        border: Border.all(color: colorTema.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          // Barra de Aptitud para Salir
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

