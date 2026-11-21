import 'package:equatable/equatable.dart';

import '../../core/constants/weather_constants.dart';
import '../../core/utils/avatar_state_mapper.dart';
import '../../models/search_place.dart';
import '../../models/weather_point_data.dart';

enum WeatherStatus { initial, loading, loaded, error }

class WeatherState extends Equatable {
  final WeatherStatus status;
  final double? selectedLatitude;
  final double? selectedLongitude;
  final double selectionRadiusMeters;
  final WeatherPointData? weatherData;
  final AvatarVisualState avatarState;
  final List<SearchPlace> searchResults;
  final bool isSearchingPlaces;
  final String? errorMessage;

  const WeatherState({
    this.status = WeatherStatus.initial,
    this.selectedLatitude,
    this.selectedLongitude,
    this.selectionRadiusMeters = WeatherConstants.defaultSelectionRadiusMeters,
    this.weatherData,
    this.avatarState = AvatarVisualState.temperate,
    this.searchResults = const [],
    this.isSearchingPlaces = false,
    this.errorMessage,
  });

  bool get hasSelectedArea =>
      selectedLatitude != null && selectedLongitude != null;

  WeatherState copyWith({
    WeatherStatus? status,
    double? selectedLatitude,
    double? selectedLongitude,
    double? selectionRadiusMeters,
    WeatherPointData? weatherData,
    AvatarVisualState? avatarState,
    List<SearchPlace>? searchResults,
    bool? isSearchingPlaces,
    String? errorMessage,
    bool clearError = false,
  }) {
    return WeatherState(
      status: status ?? this.status,
      selectedLatitude: selectedLatitude ?? this.selectedLatitude,
      selectedLongitude: selectedLongitude ?? this.selectedLongitude,
      selectionRadiusMeters:
          selectionRadiusMeters ?? this.selectionRadiusMeters,
      weatherData: weatherData ?? this.weatherData,
      avatarState: avatarState ?? this.avatarState,
      searchResults: searchResults ?? this.searchResults,
      isSearchingPlaces: isSearchingPlaces ?? this.isSearchingPlaces,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'selectedLatitude': selectedLatitude,
      'selectedLongitude': selectedLongitude,
      'selectionRadiusMeters': selectionRadiusMeters,
      'weatherData': weatherData?.toJson(),
      'avatarState': avatarState.name,
    };
  }

  factory WeatherState.fromJson(Map<String, dynamic> json) {
    final rawWeather = json['weatherData'] as Map<String, dynamic>?;
    final parsedWeather = rawWeather != null
        ? WeatherPointData.fromJson(rawWeather)
        : null;

    final rawStatusName = json['status'] as String?;
    WeatherStatus parsedStatus = WeatherStatus.initial;
    if (rawStatusName == WeatherStatus.loaded.name && parsedWeather != null) {
      parsedStatus = WeatherStatus.loaded;
    }

    final rawAvatarName = json['avatarState'] as String?;
    final parsedAvatar = AvatarVisualState.values.firstWhere(
      (e) => e.name == rawAvatarName,
      orElse: () => AvatarVisualState.temperate,
    );

    return WeatherState(
      status: parsedStatus,
      selectedLatitude: (json['selectedLatitude'] as num?)?.toDouble(),
      selectedLongitude: (json['selectedLongitude'] as num?)?.toDouble(),
      selectionRadiusMeters:
          (json['selectionRadiusMeters'] as num?)?.toDouble() ??
          WeatherConstants.defaultSelectionRadiusMeters,
      weatherData: parsedWeather,
      avatarState: parsedAvatar,
      searchResults: const [],
      isSearchingPlaces: false,
      errorMessage: null,
    );
  }

  @override
  List<Object?> get props => [
    status,
    selectedLatitude,
    selectedLongitude,
    selectionRadiusMeters,
    weatherData,
    avatarState,
    searchResults,
    isSearchingPlaces,
    errorMessage,
  ];
}
