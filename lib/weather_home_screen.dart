import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/weather_search_screen.dart';

class Weather {
  final double temp; //현재 온도
  final double tempMin; //최저 온도
  final double tempMax; //최고 온도
  final int humidity; //흐림정도
  final String condition;

  Weather({
    required this.temp,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.condition,
  });
}

class WeatherHomeScreen extends StatefulWidget {
  const WeatherHomeScreen({super.key});

  @override
  State<WeatherHomeScreen> createState() => _WeatherHomeScreenState();
}

class _WeatherHomeScreenState extends State<WeatherHomeScreen> {
  double latitude = 0.0;
  double longitude = 0.0;

  @override
  void initState() {
    super.initState();
    myPosition();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _searchPosition(double lat, double lng) async {
    setState(() {
      latitude = lat;
      longitude = lng;
    });
  }

  void myPosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
    });
  }

  Future<List<dynamic>> getLocation() async {
    //dotenv.env['googleMapApiKey']
    const key = '';

    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$key&language=ko');
    final response = await http.get(url);
    final resData = await json.decode(response.body);
    final address = resData['results'];

    return address;
  }

  Future<Weather> getWeather() async {
    //dotenv.env['openWeatherApiKey']
    const key = '';

    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$key');
    final response = await http.get(url);
    final resData = json.decode(response.body);
    Weather weather = Weather(
      temp: resData["main"]?["temp"] ?? 0.0,
      tempMax: resData["main"]?["temp_max"] ?? 0.0,
      tempMin: resData["main"]?["temp_min"] ?? 0.0,
      humidity: resData["main"]?["humidity"] ?? 0,
      condition: resData['weather']?[0]['main'] ?? '',
    );

    return weather;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateFormat('yyy년 MM월 dd일').format(now);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      WeatherSearchScreen(searchPosition: _searchPosition),
                ),
              )
            },
            padding: const EdgeInsets.symmetric(horizontal: 10),
            icon: const Icon(
              Icons.search,
              color: Colors.deepPurple,
              size: 30,
            ),
          ),
          IconButton(
            onPressed: myPosition,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            icon: const Icon(
              Icons.my_location,
              color: Colors.deepPurple,
              size: 25,
            ),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        color: Theme.of(context).colorScheme.inversePrimary,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder(
                  future: getLocation(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData == false || snapshot.data!.isEmpty) {
                      return const CircularProgressIndicator(); // CircularProgressIndicator : 로딩 에니메이션
                    } else if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Error: ${snapshot.error}', // 에러명을 텍스트에 뿌려줌
                          style: const TextStyle(fontSize: 15),
                        ),
                      );
                    } else {
                      List<dynamic> value =
                          snapshot.data![0]['formatted_address'].split(' ');

                      return Text(
                        '${value[2]} ${value[3]}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.deepPurple,
                          fontSize: 40,
                        ),
                      );
                    }
                  },
                ),
                Text(
                  today,
                  style: TextStyle(
                    color: Colors.deepPurple.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            FutureBuilder(
              future: getWeather(),
              builder: (context, snapshot) {
                if (snapshot.hasData == false) {
                  return const CircularProgressIndicator(); // CircularProgressIndicator : 로딩 에니메이션
                } else if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Error: ${snapshot.error}', // 에러명을 텍스트에 뿌려줌
                      style: const TextStyle(fontSize: 15),
                    ),
                  );
                } else {
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${((snapshot.data!.temp) - 272.15).toStringAsFixed(1)}C˚',
                            style: const TextStyle(
                              color: Colors.deepPurple,
                              fontSize: 42,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Icon(
                            snapshot.data!.condition == 'Clouds'
                                ? Icons.cloud
                                : snapshot.data!.condition == 'Rain'
                                    ? Icons.umbrella
                                    : Icons.sunny,
                            color: Colors.deepPurple.withOpacity(0.4),
                            size: 40,
                          ),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding:
                            const EdgeInsets.only(top: 10, left: 10, right: 10),
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(width: 1, color: Colors.deepPurple),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                const Text(
                                  '최저온도',
                                  style: TextStyle(
                                    color: Colors.deepPurple,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '${(snapshot.data!.tempMin - 272.15).toStringAsFixed(1)}C˚',
                                  style: const TextStyle(
                                    color: Colors.deepPurple,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                const Text(
                                  '최고온도',
                                  style: TextStyle(
                                    color: Colors.deepPurple,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '${(snapshot.data!.tempMax - 272.15).toStringAsFixed(1)}C˚',
                                  style: const TextStyle(
                                    color: Colors.deepPurple,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                const Text(
                                  '습도',
                                  style: TextStyle(
                                    color: Colors.deepPurple,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '${snapshot.data!.humidity}%',
                                  style: const TextStyle(
                                    color: Colors.deepPurple,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
