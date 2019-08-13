import 'dart:convert';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import '../models/weather.dart';

class WeatherApiClient {
  static const baseUrl = 'https://www.metaweather.com';
  final http.Client httpClient;

  WeatherApiClient({@required this.httpClient}) : assert(httpClient != null);

  Future<int> getLocationId(String city) async {
    final endpoint = '$baseUrl/api/location/search/?query=$city';
    final response = await httpClient.get(endpoint);
    if (response.statusCode != 200) {
      throw Exception('Erro ao tentar obter locationId para esta cidade');
    }

    final locationJson = jsonDecode(response.body) as List;
    return locationJson.first['woeid'];
  }

  Future<Weather> fetchWeather(int locationId) async {
    final endpoint = '$baseUrl/api/location/$locationId';
    final response = await httpClient.get(endpoint);
    if (response.statusCode != 200) {
      throw Exception('Erro ao tentar obter o clima para esta cidade');
    }

    final weatherJson = jsonDecode(response.body);
    return Weather.fromJson(weatherJson);
  }
}
