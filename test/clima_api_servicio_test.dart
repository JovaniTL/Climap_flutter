import 'dart:convert';

import 'package:climap_flutter/servicios/clima_api_servicio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('ClimaApiServicio', () {
    test('buscarCiudades parsea correctamente una respuesta 200 válida', () async {
      final cliente = MockClient((request) async {
        expect(request.url.queryParameters['name'], 'Zitácuaro');
        return http.Response(
          jsonEncode({
            'results': [
              {
                'name': 'Zitácuaro',
                'admin1': 'Michoacán',
                'country': 'México',
                'latitude': 19.4361,
                'longitude': -100.3572,
              },
            ],
          }),
          200,
        );
      });

      final servicio = ClimaApiServicio(clienteHttp: cliente);
      final ciudades = await servicio.buscarCiudades('Zitácuaro');
      servicio.cerrar();

      expect(ciudades, hasLength(1));
      expect(ciudades.first.nombre, 'Zitácuaro');
      expect(ciudades.first.nombreCompleto, 'Zitácuaro, Michoacán, México');
      expect(ciudades.first.latitud, closeTo(19.4361, 0.0001));
    });

    test('buscarCiudades lanza ciudadNoEncontrada cuando results viene vacío', () async {
      final cliente = MockClient((_) async => http.Response(jsonEncode({}), 200));
      final servicio = ClimaApiServicio(clienteHttp: cliente);

      await expectLater(
        () => servicio.buscarCiudades('CiudadInventadaXYZ'),
        throwsA(
          isA<ClimaExcepcion>().having(
            (e) => e.tipo,
            'tipo',
            TipoErrorClima.ciudadNoEncontrada,
          ),
        ),
      );
      servicio.cerrar();
    });

    test('buscarCiudades lanza sinInternet ante http.ClientException', () async {
      final cliente = MockClient((_) async => throw http.ClientException('Sin red'));
      final servicio = ClimaApiServicio(clienteHttp: cliente);

      await expectLater(
        () => servicio.buscarCiudades('Morelia'),
        throwsA(
          isA<ClimaExcepcion>().having(
            (e) => e.tipo,
            'tipo',
            TipoErrorClima.sinInternet,
          ),
        ),
      );
      servicio.cerrar();
    });

    test('buscarCiudades lanza errorServidor ante HTTP 500 o JSON inválido', () async {
      final cliente500 = MockClient((_) async => http.Response('Error', 500));
      final servicio500 = ClimaApiServicio(clienteHttp: cliente500);
      await expectLater(
        () => servicio500.buscarCiudades('Morelia'),
        throwsA(
          isA<ClimaExcepcion>().having(
            (e) => e.tipo,
            'tipo',
            TipoErrorClima.errorServidor,
          ),
        ),
      );
      servicio500.cerrar();

      final clienteJsonInvalido = MockClient((_) async => http.Response('{no-json', 200));
      final servicioJson = ClimaApiServicio(clienteHttp: clienteJsonInvalido);
      await expectLater(
        () => servicioJson.buscarCiudades('Morelia'),
        throwsA(
          isA<ClimaExcepcion>().having(
            (e) => e.tipo,
            'tipo',
            TipoErrorClima.errorServidor,
          ),
        ),
      );
      servicioJson.cerrar();
    });

    test('obtenerClima parsea datos actuales y pronóstico diario', () async {
      final cliente = MockClient((_) async {
        return http.Response(
          jsonEncode({
            'current': {
              'temperature_2m': 23.4,
              'apparent_temperature': 24.1,
              'relative_humidity_2m': 55,
              'surface_pressure': 1015.0,
              'wind_speed_10m': 12.5,
              'weather_code': 1,
              'is_day': 0,
            },
            'daily': {
              'time': ['2026-11-22', '2026-11-23'],
              'temperature_2m_max': [26.0, 25.0],
              'temperature_2m_min': [11.0, 10.0],
              'precipitation_probability_max': [35, 10],
              'weather_code': [2, 0],
            },
          }),
          200,
        );
      });

      final servicio = ClimaApiServicio(clienteHttp: cliente);
      final clima = await servicio.obtenerClima(
        latitud: 19.70,
        longitud: -101.19,
        nombreLugar: 'Morelia',
      );
      servicio.cerrar();

      expect(clima.nombreLugar, 'Morelia');
      expect(clima.temperatura, 23.4);
      expect(clima.sensacionTermica, 24.1);
      expect(clima.humedad, 55);
      expect(clima.presionAtmosferica, 1015.0);
      expect(clima.velocidadViento, 12.5);
      expect(clima.probabilidadLluvia, 35);
      expect(clima.esDeDia, isFalse);
      expect(clima.pronosticoSemanal, hasLength(2));
    });
  });
}
