import "dart:convert";
import "dart:ui";

import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:weather_app/additioanl_info_item.dart";
import "package:weather_app/hourly_forecast_item.dart";
import "package:http/http.dart" as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  // "http://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&exclude=$exclude&appid=$apikey"
  // "http://api.openweathermap.org/data/2.5/weather?q=$cityname&appid=$apikey"

  late Future<Map<String, dynamic>> weather = getCurrentWeather();

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      // const String latitude = "33.44";
      // const String longitude = "94.04";
      // const String exclude = "minutely,hourly,alerts";
      const String cityname = "Lahore";
      const String apikey = "1e8597de8b224996417340f61d5f5fbc";
      final result = await http.get(Uri.parse(
          "http://api.openweathermap.org/data/2.5/forecast?q=$cityname&appid=$apikey"));

      if (result.statusCode != 200) {
        throw "Some unexpected error occured.";
      }

      final data = jsonDecode(result.body);
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "WEATHER APP",
          style: TextStyle(
            fontSize: 30,
            letterSpacing: 35,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  weather = getCurrentWeather();
                });
              },
              icon: const Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder(
        future: weather,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          final data = snapshot.data!;
          final currentWeatherData = data["list"][0];
          final currentTemp = currentWeatherData["main"]["temp"];
          final currentSky = currentWeatherData["weather"][0]["main"];
          final currentPressure = currentWeatherData["main"]["pressure"];
          final currentWindSpeed = currentWeatherData["wind"]["speed"];
          final currentHumidity = currentWeatherData["main"]["humidity"];

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: <Widget>[
                                Text(
                                  "$currentTemp K",
                                  style: const TextStyle(
                                    fontSize: 50,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Icon(
                                  currentSky == "Clouds"
                                      ? Icons.cloud
                                      : currentSky == "Rain"
                                          ? Icons.foggy
                                          : Icons.sunny,
                                  size: 100,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  currentSky,
                                  style: const TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    "HOURLY FORECAST",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 5,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  // SingleChildScrollView(
                  //   scrollDirection: Axis.horizontal,
                  //   child: Row(
                  //     children: <Widget>[
                  //       for (int i = 0; i < 10; i++)
                  //         HourlyForecastItem(
                  //           icon: data["list"][i + 1]["weather"][0]["main"] ==
                  //                   "Clouds"
                  //               ? Icons.cloud
                  //               : data["list"][i + 1]["weather"][0]["main"] ==
                  //                       "Rain"
                  //                   ? Icons.foggy
                  //                   : Icons.sunny,
                  //           time: data["list"][i + 1]["dt"].toString(),
                  //           temperature:
                  //               data["list"][i + 1]["main"]["temp"].toString(),
                  //         ),
                  //     ],
                  //   ),
                  // ),
                  SizedBox(
                    height: 170,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 23,
                      itemBuilder: (context, index) {
                        final hourlyForecast = data["list"][index + 1];
                        final hourlySky = hourlyForecast["weather"][0]["main"];
                        final time = DateTime.parse(hourlyForecast["dt_txt"]);
                        return HourlyForecastItem(
                          icon: hourlySky == "Clouds"
                              ? Icons.cloud
                              : hourlySky == "Rain"
                                  ? Icons.foggy
                                  : Icons.sunny,
                          time: DateFormat.j().format(time),
                          temperature:
                              hourlyForecast["main"]["temp"].toString(),
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    "MORE INFORMATION",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 5,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      AdditionalInfoItem(
                        icon: Icons.water_drop,
                        lable: "Humidity",
                        value: currentHumidity.toString(),
                      ),
                      AdditionalInfoItem(
                        icon: Icons.air,
                        lable: "Wind Speed",
                        value: currentWindSpeed.toString(),
                      ),
                      AdditionalInfoItem(
                        icon: Icons.beach_access,
                        lable: "Pressure",
                        value: currentPressure.toString(),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
