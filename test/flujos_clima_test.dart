import 'dart:convert';
import 'dart:io';

import 'package:climap_flutter/bloc/clima_bloc.dart';
import 'package:climap_flutter/bloc/clima_event.dart';
import 'package:climap_flutter/bloc/clima_state.dart';
import 'package:climap_flutter/bloc/comparacion_cubit.dart';
import 'package:climap_flutter/servicios/clima_api_servicio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  late ClimaApiServicio servicio;
  late List<String> peticiones;

  setUp(() {
    peticiones = [];
    servicio = ClimaApiServicio(
      clienteHttp: MockClient((request) async {
        final url = request.url;
        if (url.path.endsWith('/search')) {
          final nombre = url.queryParameters['name']!;
          peticiones.add('ciudad:$nombre');
          if (nombre == 'Sin resultados') return _json({});
          if (nombre == 'Sin conexión') throw const SocketException('Sin red');
          if (nombre == 'Servicio caído') return http.Response('', 503);

          return _json({
            'results': [
              {
                'name': nombre,
                'admin1': 'Michoacán',
                'country': 'México',
                'latitude': nombre == 'Morelia' ? 19.7 : 19.4,
                'longitude': -100.0,
              },
            ],
          });
        }

        final latitud = url.queryParameters['latitude']!;
        peticiones.add('clima:$latitud');
        return _json({
          'current': {'temperature_2m': 19, 'relative_humidity_2m': 70},
          'daily': {
            'time': ['2026-11-24', '2026-11-25'],
            'temperature_2m_max': [25],
            'temperature_2m_min': [10, 12],
            'precipitation_probability_max': [20],
            'weather_code': [2],
          },
        });
      }),
    );
  });

  tearDown(() => servicio.cerrar());

  test('El BLoC consulta por nombre, sugerencia y coordenadas', () async {
    final bloc = ClimaBloc(servicio: servicio);
    addTearDown(bloc.close);

    final sugerencias = bloc.stream.firstWhere((e) => e.sugerencias.isNotEmpty);
    bloc.add(const BuscarSugerenciasEvent('Morelia'));
    final ciudad = (await sugerencias).sugerencias.single;

    final porSugerencia = await _consultar(
      bloc,
      SeleccionarCiudadSugeridaEvent(ciudad),
    );
    final clima = porSugerencia.clima!;
    expect(clima.nombreLugar, 'Morelia, Michoacán, México');
    expect(clima.sensacionTermica, clima.temperatura);
    expect(clima.probabilidadLluvia, 20);
    expect(clima.pronosticoSemanal.last.tempMaxima, 0.0);
    expect(clima.pronosticoSemanal.last.tempMinima, 12.0);
    expect(porSugerencia.recomendaciones, isNotEmpty);

    final porTexto = await _consultar(
      bloc,
      const ConsultarClimaPorTextoEvent(' Zitácuaro '),
    );
    expect(porTexto.clima!.nombreLugar, 'Zitácuaro, Michoacán, México');

    final porMapa = await _consultar(
      bloc,
      const ConsultarClimaPorCoordenadasEvent(
        latitud: 19.4326,
        longitud: -99.1332,
      ),
    );
    expect(porMapa.clima!.nombreLugar, 'Coordenadas (19.43, -99.13)');
    expect(peticiones, [
      'ciudad:Morelia',
      'clima:19.7',
      'ciudad:Zitácuaro',
      'clima:19.4',
      'clima:19.4326',
    ]);
  });

  test('El BLoC distingue los errores y puede reintentar', () async {
    final bloc = ClimaBloc(servicio: servicio);
    addTearDown(bloc.close);

    final sinResultados = await _consultar(
      bloc,
      const ConsultarClimaPorTextoEvent('Sin resultados'),
    );
    expect(sinResultados.tipoError, TipoErrorClima.ciudadNoEncontrada);
    expect(sinResultados.mensajeError, contains('No se encontraron ciudades'));

    final reintento = await _consultar(bloc, const ReintentarConsultaEvent());
    expect(reintento.mensajeError, sinResultados.mensajeError);
    expect(peticiones, ['ciudad:Sin resultados', 'ciudad:Sin resultados']);

    final sinConexion = await _consultar(
      bloc,
      const ConsultarClimaPorTextoEvent('Sin conexión'),
    );
    expect(sinConexion.tipoError, TipoErrorClima.sinInternet);

    final errorServidor = await _consultar(
      bloc,
      const ConsultarClimaPorTextoEvent('Servicio caído'),
    );
    expect(errorServidor.tipoError, TipoErrorClima.errorServidor);
  });

  test(
    'El Cubit compara las dos ciudades y conserva el orden de consulta',
    () async {
      final cubit = ComparacionCubit(servicio: servicio);
      addTearDown(cubit.close);

      await cubit.compararCiudades(textoCiudad1: '', textoCiudad2: 'Morelia');
      expect(
        cubit.state.mensajeError,
        contains('escribe el nombre de ambas ciudades'),
      );
      expect(peticiones, isEmpty);

      await cubit.compararCiudades(
        textoCiudad1: 'Zitácuaro',
        textoCiudad2: 'Morelia',
      );
      expect(cubit.state.clima1!.nombreLugar, 'Zitácuaro, Michoacán, México');
      expect(cubit.state.clima2!.nombreLugar, 'Morelia, Michoacán, México');
      expect(
        cubit.state.veredicto,
        contains('condiciones climáticas muy similares'),
      );
      expect(cubit.state.mensajeError, isNull);
      expect(peticiones, [
        'ciudad:Zitácuaro',
        'ciudad:Morelia',
        'clima:19.4',
        'clima:19.7',
      ]);
    },
  );
}

Future<ClimaEstado> _consultar(ClimaBloc bloc, ClimaEvent evento) {
  final resultado = bloc.stream.firstWhere(
    (e) => e.estado == EstadoClima.exitoso || e.estado == EstadoClima.error,
  );
  bloc.add(evento);
  return resultado;
}

http.Response _json(Map<String, Object> datos) {
  return http.Response(
    jsonEncode(datos),
    200,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}
