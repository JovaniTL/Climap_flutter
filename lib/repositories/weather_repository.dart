import '../models/search_place.dart';
import '../models/weather_point_data.dart';
import '../services/weather_api_service.dart';

class WeatherRepository {
  final WeatherApiService _apiService;

  WeatherRepository({WeatherApiService? apiService})
    : _apiService = apiService ?? WeatherApiService();

  Future<WeatherPointData> getWeatherAtCoordinates({
    required double latitude,
    required double longitude,
    String? placeName,
  }) {
    return _apiService.fetchWeatherByCoordinates(
      latitude: latitude,
      longitude: longitude,
      placeName: placeName,
    );
  }

  Future<List<SearchPlace>> searchPlaces(String query) {
    return _apiService.searchPlacesByName(query);
  }

  void dispose() {
    _apiService.dispose();
  }
}
