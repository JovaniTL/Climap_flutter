import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import '../../core/utils/avatar_state_mapper.dart';

class AvatarRiveWidget extends StatefulWidget {
  final AvatarVisualState visualState;
  final String assetPath;
  final String stateMachineName;
  final String inputName;

  const AvatarRiveWidget({
    super.key,
    required this.visualState,
    this.assetPath = 'assets/rive/weather_avatar.riv',
    this.stateMachineName = 'WeatherStateMachine',
    this.inputName = 'weather_type',
  });

  @override
  State<AvatarRiveWidget> createState() => _AvatarRiveWidgetState();
}

class _AvatarRiveWidgetState extends State<AvatarRiveWidget> {
  static const AvatarStateMapper _mapper = AvatarStateMapper();

  Artboard? _artboard;
  SMIInput<double>? _weatherTypeInput;
  bool _hasLoadError = false;

  @override
  void initState() {
    super.initState();
    _loadRiveFile();
  }

  @override
  void didUpdateWidget(covariant AvatarRiveWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visualState != widget.visualState) {
      _syncRiveInput();
    }
  }

  Future<void> _loadRiveFile() async {
    try {
      final file = await RiveFile.asset(widget.assetPath);
      final artboard = file.mainArtboard.instance();
      final controller = StateMachineController.fromArtboard(
        artboard,
        widget.stateMachineName,
      );

      if (controller != null) {
        artboard.addController(controller);
        final input = controller.findInput<double>(widget.inputName);
        _weatherTypeInput = input;
      }

      if (!mounted) return;
      setState(() {
        _artboard = artboard;
        _hasLoadError = false;
      });
      _syncRiveInput();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasLoadError = true;
      });
    }
  }

  void _syncRiveInput() {
    final numericType = _mapper
        .toRiveWeatherType(widget.visualState)
        .toDouble();
    _weatherTypeInput?.value = numericType;
  }

  @override
  Widget build(BuildContext context) {
    if (_hasLoadError || _artboard == null) {
      return _AvatarFallbackBadge(visualState: widget.visualState);
    }

    return SizedBox(
      width: 112,
      height: 112,
      child: Rive(artboard: _artboard!, fit: BoxFit.contain),
    );
  }
}

class _AvatarFallbackBadge extends StatelessWidget {
  final AvatarVisualState visualState;

  const _AvatarFallbackBadge({required this.visualState});

  String _labelForState(AvatarVisualState state) {
    switch (state) {
      case AvatarVisualState.temperate:
        return 'Templado';
      case AvatarVisualState.hotBeach:
        return 'Calor / Playa';
      case AvatarVisualState.coldHeavy:
        return 'Frío intenso';
      case AvatarVisualState.rainStorm:
        return 'Lluvia / Tormenta';
      case AvatarVisualState.strongWind:
        return 'Viento fuerte';
    }
  }

  IconData _iconForState(AvatarVisualState state) {
    switch (state) {
      case AvatarVisualState.temperate:
        return Icons.face_rounded;
      case AvatarVisualState.hotBeach:
        return Icons.beach_access_rounded;
      case AvatarVisualState.coldHeavy:
        return Icons.ac_unit_rounded;
      case AvatarVisualState.rainStorm:
        return Icons.thunderstorm_rounded;
      case AvatarVisualState.strongWind:
        return Icons.air_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 112,
      height: 112,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_iconForState(visualState), size: 36, color: scheme.primary),
          const SizedBox(height: 6),
          Text(
            _labelForState(visualState),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
