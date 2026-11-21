import 'package:climap_flutter/blocs/weather/weather_event.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../core/utils/avatar_state_mapper.dart';
import '../../repositories/weather_repository.dart';
import '../../services/weather_api_service.dart';
import 'weather_state.dart';

class WeatherBloc extends HydratedBloc<WeatherEvent, WeatherState> {
  final WeatherRepository _repository;
  final AvatarStateMapper _avatarStateMapper;

  WeatherBloc({
    WeatherRepository? repository,
    AvatarStateMapper avatarStateMapper = const AvatarStateMapper(),
  }) : _repository = repository ?? WeatherRepository(),
       _avatarStateMapper = avatarStateMapper,
       super(const WeatherState()) {
    on<MapDoubleTapSelected>(_onMapDoubleTapSelected);
    on<SearchPlacesRequested>(_onSearchPlacesRequested);
    on<SearchPlaceSelected>(_onSearchPlaceSelected);
    on<ClearSearchResultsRequested>(_onClearSearchResultsRequested);
    on<RefreshWeatherRequested>(_onRefreshWeatherRequested);
  }

  Future<void> _onMapDoubleTapSelected(
    MapDoubleTapSelected event,
    Emitter<WeatherState> emit,
  ) async {
    emit(
      state.copyWith(
        status: WeatherStatus.loading,
        selectedLatitude: event.latitude,
        selectedLongitude: event.longitude,
        searchResults: const [],
        clearError: true,
      ),
    );

    await _loadWeatherForCoordinates(
      latitude: event.latitude,
      longitude: event.longitude,
      placeName: null,
      emit: emit,
    );
  }

  Future<void> _onSearchPlacesRequested(
    SearchPlacesRequested event,
    Emitter<WeatherState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(state.copyWith(searchResults: const [], isSearchingPlaces: false));
      return;
    }

    emit(state.copyWith(isSearchingPlaces: true, clearError: true));

    try {
      final places = await _repository.searchPlaces(query);
      emit(state.copyWith(searchResults: places, isSearchingPlaces: false));
    } on WeatherApiException catch (e) {
      emit(state.copyWith(isSearchingPlaces: false, errorMessage: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          isSearchingPlaces: false,
          errorMessage: 'No se pudieron cargar los resultados de búsqueda.',
        ),
      );
    }
  }

  Future<void> _onSearchPlaceSelected(
    SearchPlaceSelected event,
    Emitter<WeatherState> emit,
  ) async {
    final place = event.place;
    emit(
      state.copyWith(
        status: WeatherStatus.loading,
        selectedLatitude: place.latitude,
        selectedLongitude: place.longitude,
        searchResults: const [],
        isSearchingPlaces: false,
        clearError: true,
      ),
    );

    await _loadWeatherForCoordinates(
      latitude: place.latitude,
      longitude: place.longitude,
      placeName: place.name,
      emit: emit,
    );
  }

  void _onClearSearchResultsRequested(
    ClearSearchResultsRequested event,
    Emitter<WeatherState> emit,
  ) {
    emit(state.copyWith(searchResults: const [], isSearchingPlaces: false));
  }

  Future<void> _onRefreshWeatherRequested(
    RefreshWeatherRequested event,
    Emitter<WeatherState> emit,
  ) async {
    if (!state.hasSelectedArea) return;

    emit(state.copyWith(status: WeatherStatus.loading, clearError: true));

    await _loadWeatherForCoordinates(
      latitude: state.selectedLatitude!,
      longitude: state.selectedLongitude!,
      placeName: state.weatherData?.placeName,
      emit: emit,
    );
  }

  Future<void> _loadWeatherForCoordinates({
    required double latitude,
    required double longitude,
    required String? placeName,
    required Emitter<WeatherState> emit,
  }) async {
    try {
      final weather = await _repository.getWeatherAtCoordinates(
        latitude: latitude,
        longitude: longitude,
        placeName: placeName,
      );

      final nextAvatarState = _avatarStateMapper.mapFromWeather(
        weather,
        previousState: state.avatarState,
      );

      emit(
        state.copyWith(
          status: WeatherStatus.loaded,
          selectedLatitude: latitude,
          selectedLongitude: longitude,
          weatherData: weather,
          avatarState: nextAvatarState,
          clearError: true,
        ),
      );
    } on WeatherApiException catch (e) {
      emit(
        state.copyWith(status: WeatherStatus.error, errorMessage: e.message),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: WeatherStatus.error,
          errorMessage: 'Ocurrió un error inesperado al consultar el clima.',
        ),
      );
    }
  }

  @override
  WeatherState? fromJson(Map<String, dynamic> json) {
    try {
      return WeatherState.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(WeatherState state) {
    if (state.weatherData == null && !state.hasSelectedArea) {
      return null;
    }
    return state.toJson();
  }

  @override
  Future<void> close() {
    _repository.dispose();
    return super.close();
  }
}
