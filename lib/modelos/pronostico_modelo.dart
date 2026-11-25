import 'package:equatable/equatable.dart';

class PronosticoDiaModelo extends Equatable {
  final DateTime fecha;
  final double tempMaxima;
  final double tempMinima;
  final int probabilidadLluvia;
  final int codigoClima;

  const PronosticoDiaModelo({
    required this.fecha,
    required this.tempMaxima,
    required this.tempMinima,
    required this.probabilidadLluvia,
    required this.codigoClima,
  });

  String get nombreDia {
    final hoy = DateTime.now();
    final fechaSoloDia = DateTime(fecha.year, fecha.month, fecha.day);
    final hoySoloDia = DateTime(hoy.year, hoy.month, hoy.day);

    final diferencia = fechaSoloDia.difference(hoySoloDia).inDays;
    if (diferencia == 0) return 'Hoy';
    if (diferencia == 1) return 'Mañana';

    const diasSemana = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    return diasSemana[fecha.weekday - 1];
  }

  @override
  List<Object?> get props => [
    fecha,
    tempMaxima,
    tempMinima,
    probabilidadLluvia,
    codigoClima,
  ];
}
