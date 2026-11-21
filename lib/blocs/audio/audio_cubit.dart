import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AudioState extends Equatable {
  final bool isMuted;
  final bool isPlaying;
  final bool pausedByLifecycle;

  const AudioState({
    this.isMuted = false,
    this.isPlaying = false,
    this.pausedByLifecycle = false,
  });

  AudioState copyWith({
    bool? isMuted,
    bool? isPlaying,
    bool? pausedByLifecycle,
  }) {
    return AudioState(
      isMuted: isMuted ?? this.isMuted,
      isPlaying: isPlaying ?? this.isPlaying,
      pausedByLifecycle: pausedByLifecycle ?? this.pausedByLifecycle,
    );
  }

  @override
  List<Object?> get props => [isMuted, isPlaying, pausedByLifecycle];
}

class AudioCubit extends Cubit<AudioState> {
  final Future<void> Function()? _onPlayLoop;
  final Future<void> Function()? _onPauseLoop;
  final Future<void> Function(bool muted)? _onSetMuted;

  AudioCubit({
    Future<void> Function()? onPlayLoop,
    Future<void> Function()? onPauseLoop,
    Future<void> Function(bool muted)? onSetMuted,
  }) : _onPlayLoop = onPlayLoop,
       _onPauseLoop = onPauseLoop,
       _onSetMuted = onSetMuted,
       super(const AudioState());

  Future<void> startAmbientLoop() async {
    if (state.isMuted) {
      emit(state.copyWith(isPlaying: false, pausedByLifecycle: false));
      return;
    }

    await _onPlayLoop?.call();
    emit(state.copyWith(isPlaying: true, pausedByLifecycle: false));
  }

  Future<void> toggleMute() async {
    final nextMuted = !state.isMuted;
    await _onSetMuted?.call(nextMuted);

    if (nextMuted) {
      await _onPauseLoop?.call();
      emit(
        state.copyWith(
          isMuted: true,
          isPlaying: false,
          pausedByLifecycle: false,
        ),
      );
    } else {
      await _onPlayLoop?.call();
      emit(
        state.copyWith(
          isMuted: false,
          isPlaying: true,
          pausedByLifecycle: false,
        ),
      );
    }
  }

  Future<void> pauseForLifecycle() async {
    if (!state.isPlaying) return;

    await _onPauseLoop?.call();
    emit(state.copyWith(isPlaying: false, pausedByLifecycle: true));
  }

  Future<void> resumeFromLifecycle() async {
    if (!state.pausedByLifecycle || state.isMuted) return;

    await _onPlayLoop?.call();
    emit(state.copyWith(isPlaying: true, pausedByLifecycle: false));
  }
}
