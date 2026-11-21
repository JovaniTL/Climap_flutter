import 'package:equatable/equatable.dart';

import '../../models/search_place.dart';

abstract class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  List<Object?> get props => [];
}

/// Se dispara cuando el usuario hace doble toque en un punto del mapa.
class MapDoubleTapSelected extends WeatherEvent {
  final double latitude;
  final double longitude;

  const MapDoubleTapSelected({required this.latitude, required this.longitude});

  @override
  List<Object?> get props => [latitude, longitude];
}

/// Se dispara cuando el usuario escribe o envía una consulta en el buscador de lugares.
class SearchPlacesRequested extends WeatherEvent {
  final String query;

  const SearchPlacesRequested(this.query);

  @override
  List<Object?> get props => [query];
}

/// Se dispara cuando el usuario elige una localidad de los resultados de búsqueda.
class SearchPlaceSelected extends WeatherEvent {
  final SearchPlace place;

  const SearchPlaceSelected(this.place);

  @override
  List<Object?> get props => [place];
}

/// Limpia los resultados o sugerencias de búsqueda actuales.
class ClearSearchResultsRequested extends WeatherEvent {
  const ClearSearchResultsRequested();
}

/// Refresca o reintenta la consulta meteorológica para la ubicación activa.
class RefreshWeatherRequested extends WeatherEvent {
  const RefreshWeatherRequested();
}
