import 'package:flutter/material.dart';
import '../models/models.dart';

class WeatherConditions extends StatelessWidget {
  final WeatherCondition condition;

  WeatherConditions({Key key, this.condition})
      : assert(condition != null),
        super(key: key);

  @override
  Widget build(BuildContext context) { 
    Image image = _mapConditionToImage(condition);
    return image;
  }

  Image _mapConditionToImage(WeatherCondition condition) {
    String path;
    switch(condition) {
      case WeatherCondition.clear:
      case WeatherCondition.lightCloud:
        path ='assets/clear.png';
        break;
      case WeatherCondition.hail:
      case WeatherCondition.snow:
      case WeatherCondition.sleet:
        path = 'assets/snow.png';
        break;
      case WeatherCondition.heavyCloud:
        path = 'assets/cloudy.png';
        break;
      case WeatherCondition.heavyRain:
      case WeatherCondition.lightRain:
      case WeatherCondition.showers:
        path = 'assets/rain.png';
        break;
      case WeatherCondition.thunderstorm:
        path = 'assets/thunderstorm.png';
        break;
      case WeatherCondition.unknown:
        path = 'assets/clear.png';
        break;
    }
    return Image.asset(path, width: 50, height: 50,);
  }
}
