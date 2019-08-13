import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/blocs.dart';
import '../repositories/repositories.dart';
import '../widgets/widgets.dart';
import '../models/models.dart' as model;
import './city_selection.dart';
import 'package:flutter_weather/models/weather.dart';

class Weather extends StatefulWidget {
  final WeatherRepository weatherRepository;

  Weather({Key key, @required this.weatherRepository})
      : assert(weatherRepository != null),
        super(key: key);

  @override
  State<Weather> createState() => _WeatherState();
}

class _WeatherState extends State<Weather> {
  Completer<void> _refreshCompleter;
  WeatherBloc _weatherBloc;

  @override
  void initState() {
    super.initState();
    _refreshCompleter = Completer<void>();
    _weatherBloc = WeatherBloc(weatherRepository: widget.weatherRepository);
  }

  _handleSearchButton() async {
    final city = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => CitySelection()));
    if (city != null) {
      _weatherBloc.dispatch(FetchWeather(city: city));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: Text('Flutter Clima'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _handleSearchButton,
          )
        ],
      ),
      body: Center(
        child: BlocBuilder(
          bloc: _weatherBloc,
          builder: (_, WeatherState weatherState) {
            if (weatherState is WeatherEmpty) {
              return Center(child: Text('Por favor, selecione uma cidade'));
            }
            if (weatherState is WeatherLoading) {
              return Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.white,
                ),
              );
            }

            if (weatherState is WeatherLoaded) {
              final weather = weatherState.weather;
              final themeBloc = BlocProvider.of<ThemeBloc>(context);
              themeBloc.dispatch(WeatherChanged(condition: weather.condition));

              _refreshCompleter?.complete();
              _refreshCompleter = Completer();

              return BlocBuilder(
                bloc: themeBloc,
                builder: (_, ThemeState themeState) {
                  return GradientContainer(
                    color: themeState.color,
                    child: RefreshIndicator(
                      onRefresh: () {
                        _weatherBloc
                            .dispatch(RefreshWeather(city: weather.location));
                        return _refreshCompleter.future;
                      },
                      child: _buildListView(weather),
                    ),
                  );
                },
              );
            }
            if (weatherState is WeatherError) {
              return Text('Algo deu errado',
                  style: TextStyle(color: Colors.red));
            }
          },
        ),
      ),
    );
  }

  ListView _buildListView(model.Weather weather) {
    return ListView(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 100.0),
          child: Center(
            child: Location(location: weather.location),
          ),
        ),
        Center(
          child: LastUpdated(dateTime: weather.lastUpdated),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 50.0),
          child: Center(
            child: CombinedWeatherTemperature(weather: weather),
          ),
        )
      ],
    );
  }

  @override
  void dispose() {
    _weatherBloc.dispose();
    super.dispose();
  }
}
