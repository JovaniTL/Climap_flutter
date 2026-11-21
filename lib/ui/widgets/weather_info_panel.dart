import 'package:flutter/material.dart';

import '../../core/utils/avatar_state_mapper.dart';
import '../../models/daily_forecast.dart';
import '../../models/weather_point_data.dart';
import '../utils/weather_code_presenter.dart';
import 'avatar_rive_widget.dart';

class WeatherInfoPanel extends StatelessWidget {
  final WeatherPointData weather;
  final AvatarVisualState avatarState;
  final VoidCallback onRefresh;

  const WeatherInfoPanel({
    super.key,
    required this.weather,
    required this.avatarState,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final description = WeatherCodePresenter.descriptionForWmo(
      weather.weatherCodeWmo,
      isDay: weather.isDay,
    );
    final conditionIcon = WeatherCodePresenter.iconForWmo(
      weather.weatherCodeWmo,
      isDay: weather.isDay,
    );

    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: 18,
                  color: scheme.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    weather.displayLocationLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Actualizar pronóstico',
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AvatarRiveWidget(visualState: avatarState),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${weather.temperatureC.toStringAsFixed(1)}°C',
                            style: textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(conditionIcon, color: scheme.primary),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sensación térmica: ${weather.feelsLikeC.toStringAsFixed(1)}°C',
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _MetricChip(
                  icon: Icons.water_drop_outlined,
                  label: 'Humedad',
                  value: '${weather.relativeHumidity}%',
                ),
                _MetricChip(
                  icon: Icons.air_rounded,
                  label: 'Viento',
                  value: '${weather.windSpeedKmh.toStringAsFixed(0)} km/h',
                ),
                _MetricChip(
                  icon: Icons.umbrella_outlined,
                  label: 'Lluvia',
                  value: '${weather.precipitationProbability}%',
                ),
              ],
            ),
            if (weather.dailyForecasts.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Text(
                'Próximos días',
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 98,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: weather.dailyForecasts.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return _DailyForecastTile(
                      forecast: weather.dailyForecasts[index],
                      isToday: index == 0,
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetricChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: scheme.primary),
            const SizedBox(height: 2),
            Text(
              value,
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyForecastTile extends StatelessWidget {
  final DailyForecast forecast;
  final bool isToday;

  const _DailyForecastTile({required this.forecast, required this.isToday});

  String _weekdayLabel(DateTime date) {
    if (isToday) return 'Hoy';
    const names = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return names[(date.weekday - 1).clamp(0, 6)];
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final icon = WeatherCodePresenter.iconForWmo(forecast.weatherCodeWmo);

    return Container(
      width: 78,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: isToday
            ? scheme.primaryContainer.withValues(alpha: 0.45)
            : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isToday ? scheme.primary : scheme.outlineVariant,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _weekdayLabel(forecast.date),
            style: Theme.of(context).textTheme.labelMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          Icon(icon, size: 20, color: scheme.primary),
          Text(
            '${forecast.tempMaxC.toStringAsFixed(0)}° / ${forecast.tempMinC.toStringAsFixed(0)}°',
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(
            '${forecast.precipitationProbabilityMax}%',
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
