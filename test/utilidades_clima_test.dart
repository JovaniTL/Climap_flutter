import 'package:climap_flutter/modelos/clima_modelo.dart';
import 'package:climap_flutter/utilidades/evaluador_actividades.dart';
import 'package:climap_flutter/utilidades/recomendador_clima.dart';
import 'package:flutter_test/flutter_test.dart';

ClimaModelo _clima({
  String nombre = 'Ciudad',
  double temp = 21.0,
  int probLluvia = 10,
  double viento = 8.0,
  int codigo = 0,
}) {
  return ClimaModelo(
    nombreLugar: nombre,
    temperatura: temp,
    sensacionTermica: temp,
    humedad: 50,
    presionAtmosferica: 1013.0,
    velocidadViento: viento,
    probabilidadLluvia: probLluvia,
    codigoClima: codigo,
    esDeDia: true,
    latitud: 19.4,
    longitud: -100.3,
    pronosticoSemanal: const [],
    fechaConsulta: DateTime(2026, 11, 22),
  );
}

void main() {
  group('RecomendadorClima', () {
    test('sugiere protector solar e hidratación con temperatura alta', () {
      final recs = RecomendadorClima.generarRecomendaciones(_clima(temp: 30.0));
      expect(
        recs.any((r) => r.titulo.contains('protector solar')),
        isTrue,
      );
    });

    test('sugiere paraguas, abrigo, viento y alerta de tormenta cuando corresponde', () {
      final recs = RecomendadorClima.generarRecomendaciones(
        _clima(temp: 11.0, probLluvia: 70, codigo: 95, viento: 28.0),
      );
      final titulos = recs.map((r) => r.titulo).toList();
      expect(titulos, contains('Lleva paraguas o impermeable'));
      expect(titulos, contains('Abrígate adecuadamente'));
      expect(titulos, contains('Precaución con vientos fuertes'));
      expect(titulos, contains('Alerta de tormenta eléctrica'));
    });

    test('recomienda salir cuando el clima es templado y despejado', () {
      final recs = RecomendadorClima.generarRecomendaciones(_clima());
      expect(
        recs.any((r) => r.titulo.contains('Clima ideal para salir')),
        isTrue,
      );
    });
  });

  group('EvaluadorActividades', () {
    test('calcula puntaje perfecto en clima templado, penaliza tormenta y da veredicto', () {
      final ideal = _clima(nombre: 'Morelia', temp: 21.0, probLluvia: 0, viento: 10.0, codigo: 0);
      final tormenta = _clima(nombre: 'Toluca', temp: 12.0, probLluvia: 90, viento: 35.0, codigo: 95);

      expect(EvaluadorActividades.calcularPuntajeActividad(ideal), 100);
      expect(EvaluadorActividades.calcularPuntajeActividad(tormenta), lessThan(40));

      final veredicto = EvaluadorActividades.generarVeredictoComparativo(
        clima1: ideal,
        clima2: tormenta,
      );
      expect(veredicto, contains('Morelia'));

      final empate = EvaluadorActividades.generarVeredictoComparativo(
        clima1: _clima(nombre: 'A', temp: 21.0),
        clima2: _clima(nombre: 'B', temp: 21.5),
      );
      expect(empate, contains('condiciones climáticas muy similares'));
    });
  });
}
