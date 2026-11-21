import '../constants/weather_constants.dart';
import '../../models/weather_point_data.dart';

enum AvatarVisualState { temperate, hotBeach, coldHeavy, rainStorm, strongWind }

class AvatarStateMapper {
  static const double coldThresholdC = 12.0;
  static const double hotThresholdC = 26.0;
  static const double strongWindThresholdKmh = 35.0;
  static const double temperatureHysteresisC =
      WeatherConstants.defaultSelectionRadiusMeters > 0 ? 1.5 : 1.5;

  const AvatarStateMapper();

  AvatarVisualState mapFromWeather(
    WeatherPointData weather, {
    AvatarVisualState? previousState,
  }) {
    final code = weather.weatherCodeWmo;
    final temp = weather.temperatureC;
    final wind = weather.windSpeedKmh;

    // 1. Lluvia, llovizna o tormenta eléctrica (códigos WMO 51–99)
    if (code >= 51 && code <= 99) {
      return AvatarVisualState.rainStorm;
    }

    // 2. Frío intenso con margen de histéresis
    final coldLimit = previousState == AvatarVisualState.coldHeavy
        ? coldThresholdC + temperatureHysteresisC
        : coldThresholdC;
    if (temp < coldLimit) {
      return AvatarVisualState.coldHeavy;
    }

    // 3. Calor / playa (temperatura alta y cielo despejado o poco nublado: WMO 0–2)
    final hotLimit = previousState == AvatarVisualState.hotBeach
        ? hotThresholdC - temperatureHysteresisC
        : hotThresholdC;
    final isClearOrPartlyCloudy = code >= 0 && code <= 2;
    if (temp > hotLimit && isClearOrPartlyCloudy) {
      return AvatarVisualState.hotBeach;
    }

    // 4. Viento fuerte
    if (wind >= strongWindThresholdKmh) {
      return AvatarVisualState.strongWind;
    }

    // 5. Estado base templado
    return AvatarVisualState.temperate;
  }

  int toRiveWeatherType(AvatarVisualState state) {
    switch (state) {
      case AvatarVisualState.temperate:
        return 0;
      case AvatarVisualState.hotBeach:
        return 1;
      case AvatarVisualState.coldHeavy:
        return 2;
      case AvatarVisualState.rainStorm:
        return 3;
      case AvatarVisualState.strongWind:
        return 4;
    }
  }
}
