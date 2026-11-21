import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'blocs/audio/audio_cubit.dart';
import 'blocs/weather/weather_bloc.dart';
import 'repositories/weather_repository.dart';
import 'services/audio_service.dart';
import 'ui/screens/weather_map_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageDirectory = kIsWeb
      ? HydratedStorage.webStorageDirectory
      : await getApplicationDocumentsDirectory();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: storageDirectory,
  );

  final weatherRepository = WeatherRepository();
  final audioService = AudioService();

  runApp(
    WeatherAvatarApp(
      weatherRepository: weatherRepository,
      audioService: audioService,
    ),
  );
}

class WeatherAvatarApp extends StatefulWidget {
  final WeatherRepository weatherRepository;
  final AudioService audioService;

  const WeatherAvatarApp({
    super.key,
    required this.weatherRepository,
    required this.audioService,
  });

  @override
  State<WeatherAvatarApp> createState() => _WeatherAvatarAppState();
}

class _WeatherAvatarAppState extends State<WeatherAvatarApp> {
  late final WeatherBloc _weatherBloc;
  late final AudioCubit _audioCubit;

  @override
  void initState() {
    super.initState();
    _weatherBloc = WeatherBloc(repository: widget.weatherRepository);
    _audioCubit = AudioCubit(
      onPlayLoop: widget.audioService.playLoop,
      onPauseLoop: widget.audioService.pause,
      onSetMuted: widget.audioService.setMuted,
    );
  }

  @override
  void dispose() {
    _weatherBloc.close();
    _audioCubit.close();
    widget.audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<WeatherBloc>.value(value: _weatherBloc),
        BlocProvider<AudioCubit>.value(value: _audioCubit),
      ],
      child: MaterialApp(
        title: 'Clima y Avatar',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF0284C7),
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF0284C7),
          brightness: Brightness.dark,
        ),
        themeMode: ThemeMode.system,
        home: const WeatherMapScreen(),
      ),
    );
  }
}
