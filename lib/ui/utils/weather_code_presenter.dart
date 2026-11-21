import 'package:flutter/material.dart';

class WeatherCodePresenter {
  WeatherCodePresenter._();

  static String descriptionForWmo(int code, {bool isDay = true}) {
    if (code == 0) {
      return isDay ? 'Despejado' : 'Noche despejada';
    }
    if (code == 1) {
      return 'Mayormente despejado';
    }
    if (code == 2) {
      return 'Parcialmente nublado';
    }
    if (code == 3) {
      return 'Nublado';
    }
    if (code == 45 || code == 48) {
      return 'Niebla';
    }
    if (code >= 51 && code <= 55) {
      return 'Llovizna';
    }
    if (code == 56 || code == 57) {
      return 'Llovizna helada';
    }
    if (code >= 61 && code <= 65) {
      return 'Lluvia';
    }
    if (code == 66 || code == 67) {
      return 'Lluvia helada';
    }
    if (code >= 71 && code <= 77) {
      return 'Nieve';
    }
    if (code >= 80 && code <= 82) {
      return 'Chubascos';
    }
    if (code == 85 || code == 86) {
      return 'Chubascos de nieve';
    }
    if (code >= 95 && code <= 99) {
      return 'Tormenta eléctrica';
    }
    return 'Condición variable';
  }

  static IconData iconForWmo(int code, {bool isDay = true}) {
    if (code == 0) {
      return isDay ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded;
    }
    if (code == 1 || code == 2) {
      return isDay ? Icons.wb_sunny : Icons.nights_stay_rounded;
    }
    if (code == 3) {
      return Icons.cloud_rounded;
    }
    if (code == 45 || code == 48) {
      return Icons.foggy;
    }
    if (code >= 51 && code <= 57) {
      return Icons.grain_rounded;
    }
    if (code >= 61 && code <= 67) {
      return Icons.water_drop_rounded;
    }
    if (code >= 71 && code <= 77 || code == 85 || code == 86) {
      return Icons.ac_unit_rounded;
    }
    if (code >= 80 && code <= 82) {
      return Icons.umbrella_rounded;
    }
    if (code >= 95 && code <= 99) {
      return Icons.thunderstorm_rounded;
    }
    return Icons.device_thermostat_rounded;
  }
}
