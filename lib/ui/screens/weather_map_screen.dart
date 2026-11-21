import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/audio/audio_cubit.dart';
import '../../blocs/weather/weather_bloc.dart';
import '../../blocs/weather/weather_event.dart';
import '../../blocs/weather/weather_state.dart';
import '../widgets/place_search_bar.dart';
import '../widgets/weather_info_panel.dart';
import '../widgets/weather_map_view.dart';

class WeatherMapScreen extends StatefulWidget {
  const WeatherMapScreen({super.key});

  @override
  State<WeatherMapScreen> createState() => _WeatherMapScreenState();
}

class _WeatherMapScreenState extends State<WeatherMapScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AudioCubit>().startAmbientLoop();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    final audioCubit = context.read<AudioCubit>();

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      audioCubit.pauseForLifecycle();
    } else if (state == AppLifecycleState.resumed) {
      audioCubit.resumeFromLifecycle();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const Positioned.fill(child: WeatherMapView()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(child: PlaceSearchBar()),
                      const SizedBox(width: 8),
                      const _AudioToggleButton(),
                    ],
                  ),
                  const Spacer(),
                  const _BottomWeatherOverlay(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AudioToggleButton extends StatelessWidget {
  const _AudioToggleButton();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return BlocBuilder<AudioCubit, AudioState>(
      builder: (context, audioState) {
        final isMuted = audioState.isMuted;
        return Material(
          elevation: 4,
          shape: const CircleBorder(),
          color: scheme.surface,
          child: IconButton(
            tooltip: isMuted
                ? 'Activar música ambiental'
                : 'Silenciar música ambiental',
            onPressed: () => context.read<AudioCubit>().toggleMute(),
            icon: Icon(
              isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              color: isMuted ? scheme.onSurfaceVariant : scheme.primary,
            ),
          ),
        );
      },
    );
  }
}

class _BottomWeatherOverlay extends StatelessWidget {
  const _BottomWeatherOverlay();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return BlocBuilder<WeatherBloc, WeatherState>(
      builder: (context, state) {
        if (state.status == WeatherStatus.loading &&
            state.weatherData == null) {
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  ),
                  SizedBox(width: 12),
                  Text('Consultando pronóstico del área...'),
                ],
              ),
            ),
          );
        }

        if (state.status == WeatherStatus.error && state.weatherData == null) {
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.error_outline_rounded, color: scheme.error),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      state.errorMessage ?? 'No se pudo cargar el clima.',
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.read<WeatherBloc>().add(
                      const RefreshWeatherRequested(),
                    ),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state.weatherData != null) {
          return Stack(
            alignment: Alignment.topRight,
            children: [
              WeatherInfoPanel(
                weather: state.weatherData!,
                avatarState: state.avatarState,
                onRefresh: () => context.read<WeatherBloc>().add(
                  const RefreshWeatherRequested(),
                ),
              ),
              if (state.status == WeatherStatus.loading)
                const Padding(
                  padding: EdgeInsets.only(top: 14, right: 52),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
            ],
          );
        }

        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.touch_app_rounded, color: scheme.primary),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Haz doble toque en el mapa o busca una ciudad para ver el clima y el avatar.',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
