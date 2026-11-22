import 'package:flutter/material.dart';

/// Traduce los códigos estándar WMO de Open-Meteo a texto en español, iconos y colores de fondo.
class ClimaTraductor {
  ClimaTraductor._();

  /// Obtiene la descripción textual del clima en español.
  static String obtenerDescripcion(int codigoWmo, {bool esDeDia = true}) {
    switch (codigoWmo) {
      case 0:
        return esDeDia ? 'Despejado y soleado' : 'Noche despejada';
      case 1:
        return esDeDia ? 'Mayormente soleado' : 'Mayormente despejado';
      case 2:
        return 'Parcialmente nublado';
      case 3:
        return 'Completamente nublado';
      case 45:
      case 48:
        return 'Niebla densa';
      case 51:
      case 53:
      case 55:
        return 'Llovizna ligera';
      case 56:
      case 57:
        return 'Llovizna helada';
      case 61:
        return 'Lluvia ligera';
      case 63:
        return 'Lluvia moderada';
      case 65:
        return 'Lluvia fuerte y constante';
      case 66:
      case 67:
        return 'Lluvia con granizo helado';
      case 71:
      case 73:
      case 75:
      case 77:
        return 'Nevada';
      case 80:
      case 81:
      case 82:
        return 'Chubascos fuertes';
      case 85:
      case 86:
        return 'Chubascos de nieve';
      case 95:
        return 'Tormenta eléctrica';
      case 96:
      case 99:
        return 'Tormenta eléctrica con granizo';
      default:
        return 'Condición variable';
    }
  }

  /// Obtiene un icono representativo de Material Design.
  static IconData obtenerIcono(int codigoWmo, {bool esDeDia = true}) {
    switch (codigoWmo) {
      case 0:
        return esDeDia ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded;
      case 1:
      case 2:
        return esDeDia ? Icons.wb_cloudy_rounded : Icons.cloud_queue_rounded;
      case 3:
        return Icons.cloud_rounded;
      case 45:
      case 48:
        return Icons.foggy;
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
        return Icons.water_drop_outlined;
      case 61:
      case 63:
      case 65:
      case 66:
      case 67:
        return Icons.water_drop_rounded;
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return Icons.ac_unit_rounded;
      case 80:
      case 81:
      case 82:
        return Icons.umbrella_rounded;
      case 95:
      case 96:
      case 99:
        return Icons.thunderstorm_rounded;
      default:
        return Icons.thermostat_rounded;
    }
  }

  /// Colores de degradado para la cabecera o fondo según el clima.
  static List<Color> obtenerGradienteFondo(int codigoWmo, {bool esDeDia = true}) {
    if (!esDeDia) {
      return const [Color(0xFF1A2130), Color(0xFF0F172A)];
    }

    if (codigoWmo == 0 || codigoWmo == 1) {
      // Soleado / Despejado
      return const [Color(0xFFFF9800), Color(0xFF2196F3)];
    } else if (codigoWmo == 2 || codigoWmo == 3) {
      // Nublado
      return const [Color(0xFF607D8B), Color(0xFF455A64)];
    } else if (codigoWmo >= 51 && codigoWmo <= 82) {
      // Lluvioso
      return const [Color(0xFF3F51B5), Color(0xFF283593)];
    } else if (codigoWmo >= 95) {
      // Tormenta
      return const [Color(0xFF311B92), Color(0xFF1A237E)];
    } else {
      // Templado neutro
      return const [Color(0xFF1976D2), Color(0xFF0D47A1)];
    }
  }
}

