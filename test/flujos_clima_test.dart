import 'dart:async';
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

  test(
    'Reintentar después de fallar por coordenadas vuelve a consultar coordenadas',
    () async {
      final llamadas = <String>[];
      var intentos = 0;
      final srv = ClimaApiServicio(
        clienteHttp: MockClient((request) async {
          final url = request.url;
          if (url.path.endsWith('/search')) {
            llamadas.add('search:${url.queryParameters['name']}');
            return _json({'results': []});
          }
          llamadas.add('clima:${url.queryParameters['latitude']}');
          intentos++;
          if (intentos == 1) {
            throw const SocketException('Sin red');
          }
          return _json({
            'current': {'temperature_2m': 20, 'relative_humidity_2m': 60},
            'daily': {
              'time': ['2026-11-24'],
              'temperature_2m_max': [24],
              'temperature_2m_min': [12],
              'precipitation_probability_max': [10],
              'weather_code': [0],
            },
          });
        }),
      );
      addTearDown(srv.cerrar);

      final bloc = ClimaBloc(servicio: srv);
      addTearDown(bloc.close);

      final fallo = await _consultar(
        bloc,
        const ConsultarClimaPorCoordenadasEvent(
          latitud: 19.4326,
          longitud: -99.1332,
        ),
      );
      expect(fallo.estado, EstadoClima.error);
      expect(fallo.tipoError, TipoErrorClima.sinInternet);

      final reintento = await _consultar(bloc, const ReintentarConsultaEvent());
      expect(reintento.estado, EstadoClima.exitoso);
      expect(reintento.clima!.nombreLugar, 'Coordenadas (19.43, -99.13)');
      expect(llamadas, ['clima:19.4326', 'clima:19.4326']);
    },
  );

  test(
    'El servicio clasifica ClientException como sinInternet y FormatException como errorServidor',
    () async {
      final srv = ClimaApiServicio(
        clienteHttp: MockClient((request) async {
          if (request.url.path.endsWith('/search')) {
            final nombre = request.url.queryParameters['name'];
            if (nombre == 'ClienteError') {
              throw http.ClientException('Fallo de conexión');
            }
            return http.Response('no es json', 200);
          }
          if (request.url.queryParameters['latitude'] == '1.0') {
            throw http.ClientException('Fallo de red en pronóstico');
          }
          return http.Response('{invalido', 200);
        }),
      );
      addTearDown(srv.cerrar);

      await expectLater(
        srv.buscarCiudades('ClienteError'),
        throwsA(
          isA<ClimaExcepcion>().having(
            (e) => e.tipo,
            'tipo',
            TipoErrorClima.sinInternet,
          ),
        ),
      );
      await expectLater(
        srv.buscarCiudades('JsonInvalido'),
        throwsA(
          isA<ClimaExcepcion>().having(
            (e) => e.tipo,
            'tipo',
            TipoErrorClima.errorServidor,
          ),
        ),
      );
      await expectLater(
        srv.obtenerClima(latitud: 1.0, longitud: 2.0, nombreLugar: 'Prueba'),
        throwsA(
          isA<ClimaExcepcion>().having(
            (e) => e.tipo,
            'tipo',
            TipoErrorClima.sinInternet,
          ),
        ),
      );
      await expectLater(
        srv.obtenerClima(latitud: 3.0, longitud: 4.0, nombreLugar: 'Prueba'),
        throwsA(
          isA<ClimaExcepcion>().having(
            (e) => e.tipo,
            'tipo',
            TipoErrorClima.errorServidor,
          ),
        ),
      );
    },
  );

  test(
    'Consultar clima limpia cargandoSugerencias y descarta sugerencias obsoletas',
    () async {
      final completerSugerencias = Completer<http.Response>();
      final srv = ClimaApiServicio(
        clienteHttp: MockClient((request) async {
          if (request.url.path.endsWith('/search')) {
            final nombre = request.url.queryParameters['name'];
            if (nombre == 'More') {
              return completerSugerencias.future;
            }
            return _json({
              'results': [
                {
                  'name': nombre,
                  'admin1': 'Oslo',
                  'country': 'Noruega',
                  'latitude': 59.9,
                  'longitude': 10.7,
                },
              ],
            });
          }
          return _json({
            'current': {'temperature_2m': 2, 'relative_humidity_2m': 75},
            'daily': {
              'time': ['2026-11-24'],
              'temperature_2m_max': [4],
              'temperature_2m_min': [-1],
              'precipitation_probability_max': [5],
              'weather_code': [0],
            },
          });
        }),
      );
      addTearDown(srv.cerrar);

      final bloc = ClimaBloc(servicio: srv);
      addTearDown(bloc.close);

      final cargandoSug = bloc.stream.firstWhere((e) => e.cargandoSugerencias);
      bloc.add(const BuscarSugerenciasEvent('More'));
      await cargandoSug;

      final resultado = await _consultar(
        bloc,
        const ConsultarClimaPorTextoEvent('Oslo'),
      );
      expect(resultado.estado, EstadoClima.exitoso);
      expect(resultado.cargandoSugerencias, isFalse);
      expect(resultado.sugerencias, isEmpty);

      completerSugerencias.complete(
        _json({
          'results': [
            {
              'name': 'Morelia',
              'admin1': 'Michoacán',
              'country': 'México',
              'latitude': 19.7,
              'longitude': -101.2,
            },
          ],
        }),
      );
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.cargandoSugerencias, isFalse);
      expect(bloc.state.sugerencias, isEmpty);
      expect(bloc.state.clima!.nombreLugar, 'Oslo, Oslo, Noruega');
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
