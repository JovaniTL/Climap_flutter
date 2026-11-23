import 'dart:async';

import 'package:climap_flutter/bloc/clima_bloc.dart';
import 'package:climap_flutter/bloc/clima_event.dart';
import 'package:climap_flutter/bloc/clima_state.dart';
import 'package:climap_flutter/modelos/ciudad_modelo.dart';
import 'package:climap_flutter/modelos/clima_modelo.dart';
import 'package:climap_flutter/modelos/pronostico_modelo.dart';
import 'package:climap_flutter/servicios/clima_api_servicio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

ClimaModelo _crearClimaDemo(String nombreLugar) {
  return ClimaModelo(
    nombreLugar: nombreLugar,
    temperatura: 22.0,
    sensacionTermica: 22.5,
    humedad: 50,
    presionAtmosferica: 1014.0,
    velocidadViento: 10.0,
    probabilidadLluvia: 10,
    codigoClima: 0,
    esDeDia: true,
    latitud: 19.43,
    longitud: -99.13,
    pronosticoSemanal: [
      PronosticoDiaModelo(
        fecha: DateTime(2026, 11, 22),
        tempMaxima: 24.0,
        tempMinima: 12.0,
        probabilidadLluvia: 10,
        codigoClima: 0,
      ),
    ],
    fechaConsulta: DateTime(2026, 11, 22),
  );
}

class _ServicioFake extends ClimaApiServicio {
  Future<List<CiudadModelo>> Function(String)? onBuscarCiudades;
  Future<ClimaModelo> Function(double, double, String)? onObtenerClima;

  _ServicioFake({
    this.onBuscarCiudades,
    this.onObtenerClima,
  }) : super(clienteHttp: MockClient((_) async => http.Response('{}', 200)));

  @override
  Future<List<CiudadModelo>> buscarCiudades(String nombreCiudad) {
    return onBuscarCiudades!(nombreCiudad);
  }

  @override
  Future<ClimaModelo> obtenerClima({
    required double latitud,
    required double longitud,
    required String nombreLugar,
  }) {
    return onObtenerClima!(latitud, longitud, nombreLugar);
  }
}

void main() {
  group('ClimaBloc', () {
    test('reintentar desde coordenadas vuelve a consultar por coordenadas y no por texto', () async {
      var intentosClima = 0;
      var llamoBuscarCiudades = false;

      final servicio = _ServicioFake(
        onBuscarCiudades: (_) async {
          llamoBuscarCiudades = true;
          return const [];
        },
        onObtenerClima: (lat, lon, nombre) async {
          intentosClima++;
          if (intentosClima == 1) {
            throw const ClimaExcepcion(
              mensaje: 'Sin conexión',
              tipo: TipoErrorClima.sinInternet,
            );
          }
          return _crearClimaDemo(nombre);
        },
      );

      final bloc = ClimaBloc(servicio: servicio);
      bloc.add(
        const ConsultarClimaPorCoordenadasEvent(
          latitud: 19.43,
          longitud: -99.13,
          nombreLugar: 'Ubicación seleccionada (19.43, -99.13)',
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.estado, EstadoClima.error);
      expect(bloc.state.tipoError, TipoErrorClima.sinInternet);
      expect(bloc.state.ultimoEventoConsulta, isA<ConsultarClimaPorCoordenadasEvent>());

      bloc.add(const ReintentarConsultaEvent());
      await Future<void>.delayed(Duration.zero);

      expect(llamoBuscarCiudades, isFalse);
      expect(intentosClima, 2);
      expect(bloc.state.estado, EstadoClima.exitoso);
      expect(bloc.state.clima?.nombreLugar, 'Ubicación seleccionada (19.43, -99.13)');

      await bloc.close();
      servicio.cerrar();
    });

    test('reintentar desde ciudad sugerida reutiliza la ciudad sin volver a geocodificar', () async {
      var intentosClima = 0;
      var llamoBuscarCiudades = false;
      const zitacuaro = CiudadModelo(
        nombre: 'Zitácuaro',
        estado: 'Michoacán',
        pais: 'México',
        latitud: 19.4361,
        longitud: -100.3572,
      );

      final servicio = _ServicioFake(
        onBuscarCiudades: (_) async {
          llamoBuscarCiudades = true;
          return const [];
        },
        onObtenerClima: (lat, lon, nombre) async {
          intentosClima++;
          if (intentosClima == 1) {
            throw const ClimaExcepcion(
              mensaje: 'Sin conexión',
              tipo: TipoErrorClima.sinInternet,
            );
          }
          return _crearClimaDemo(nombre);
        },
      );

      final bloc = ClimaBloc(servicio: servicio);
      bloc.add(const SeleccionarCiudadSugeridaEvent(zitacuaro));
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.estado, EstadoClima.error);
      expect(bloc.state.ultimoEventoConsulta, isA<SeleccionarCiudadSugeridaEvent>());

      bloc.add(const ReintentarConsultaEvent());
      await Future<void>.delayed(Duration.zero);

      expect(llamoBuscarCiudades, isFalse);
      expect(intentosClima, 2);
      expect(bloc.state.estado, EstadoClima.exitoso);
      expect(bloc.state.clima?.nombreLugar, 'Zitácuaro, Michoacán, México');

      await bloc.close();
      servicio.cerrar();
    });

    test('consulta con texto vacío limpia ultimoEventoConsulta y emite error', () async {
      final servicio = _ServicioFake();
      final bloc = ClimaBloc(servicio: servicio);

      bloc.add(const ConsultarClimaPorTextoEvent('   '));
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.estado, EstadoClima.error);
      expect(bloc.state.ultimoEventoConsulta, isNull);

      await bloc.close();
      servicio.cerrar();
    });

    test('respuestas lentas de sugerencias no sobreescriben búsquedas posteriores ni limpieza', () async {
      final completerLento = Completer<List<CiudadModelo>>();
      const ciudadLenta = CiudadModelo(
        nombre: 'Monterrey',
        pais: 'México',
        latitud: 25.68,
        longitud: -100.31,
      );
      const ciudadRapida = CiudadModelo(
        nombre: 'Morelia',
        pais: 'México',
        latitud: 19.70,
        longitud: -101.19,
      );

      final servicio = _ServicioFake(
        onBuscarCiudades: (texto) {
          if (texto == 'Mo') return completerLento.future;
          return Future.value(const [ciudadRapida]);
        },
      );

      final bloc = ClimaBloc(servicio: servicio);
      bloc.add(const BuscarSugerenciasEvent('Mo'));
      await Future<void>.delayed(Duration.zero);

      bloc.add(const BuscarSugerenciasEvent('Morelia'));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.sugerencias, [ciudadRapida]);

      // Llega la respuesta atrasada de 'Mo'
      completerLento.complete(const [ciudadLenta]);
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.sugerencias, [ciudadRapida]);

      bloc.add(const LimpiarSugerenciasEvent());
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.sugerencias, isEmpty);

      await bloc.close();
      servicio.cerrar();
    });
  });
}
