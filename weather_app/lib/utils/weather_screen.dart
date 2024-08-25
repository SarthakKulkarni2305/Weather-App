import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weather_app/utils/additional_info.dart';
import 'package:weather_app/utils/hourly_forecast_cards.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  bool isLoading = true;
  double currentTemp = 0;
  String currentSkyCondition = '';
  double currentWindSpeed = 0;
  double currentHumidity = 0;
  double currentPressure = 0;

  // double hourlyTemp = 0;
  // String hourlySkyCondition = '';
  // String time = '';

  List<double> temperatures = [];
  List<String> skyConditions = [];
  List<DateTime> times = [];

  TextEditingController cityController = TextEditingController();

  String cityName = 'London';
  List<Map<String, dynamic>> hourlyForecasts = [];

  @override
  void initState() {
    super.initState();
    getCurrentWeather();
  }

  Future<void> getCurrentWeather() async {
    try {
      String apiKey = '8aa26a71a6ead13c0a547e4ff7388a10';

      final response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey'));
      print(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          currentTemp = (data['main']['temp'] - 273.15);
          isLoading = false;
          currentSkyCondition = data['weather'][0]['main'];
          currentWindSpeed = data['wind']['speed'];
          currentHumidity = data['main']['humidity'].toDouble();
          currentPressure = data['main']['pressure'] / 100;
        });
      } else {
        print('Error: ${response.statusCode}');
      }

      final hourlyResponse = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&appid=$apiKey'));
      print(hourlyResponse.body);
      if (hourlyResponse.statusCode == 200) {
        // final hourlyData = jsonDecode(hourlyResponse.body);

        // setState(() {
        //   currentTemp = (hourlyData['main']['temp'] - 273.15);
        //   isLoading = false;
        //   currentSkyCondition = hourlyData['weather'][0]['main'];
        //   currentWindSpeed = hourlyData['wind']['speed'];
        //   currentHumidity = hourlyData['main']['humidity'].toDouble();
        //   currentPressure = hourlyData['main']['pressure'] / 100;
        // });

        /*
        setState(() {
          // Initialize empty lists to store the data for 6 time steps
          temperatures.clear();
          skyConditions.clear();
          times.clear();

          // Loop through the first 6 time steps in the API response
          for (int i = 0; i < 6; i++) {
            var hourlyData = jsonDecode(hourlyResponse.body)['list'][i];

            // Convert temperature from Kelvin to Celsius and add to the list
            temperatures.add(hourlyData['main']['temp'] - 273.15);

            // Extract sky condition and add to the list
            skyConditions.add(hourlyData['weather'][0]['main']);

            // Convert the timestamp to a DateTime object and add to the list
            times.add(DateTime.fromMillisecondsSinceEpoch(hourlyData['dt'] * 1000));
          }

          // Update the state variables (if you need to display them or use them later)
          // currentTemps = temperatures;
          // currentSkyConditions = skyConditions;
          // currentTimes = times;

          // Set isLoading to false once data is fetched
          isLoading = false;
        });
        */
        final hourlyData = jsonDecode(hourlyResponse.body);
        setState(() {
          hourlyForecasts = List<Map<String, dynamic>>.from(
            hourlyData['list'].take(6).map((item) {
              return {
                'time': DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000),
                'temperature':
                    (item['main']['temp'] - 273.15).toStringAsFixed(1),
                'condition': item['weather'][0]['main'],
              };
            }),
          );
          isLoading = false;
        });
      } else {
        print('Error: ${hourlyResponse.statusCode}');
      }
    } catch (e) {
      print(e);
    }
  }

  IconData getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return Icons.cloud;
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return Icons.umbrella;
      case 'thunderstorm':
        return Icons.flash_on;
      case 'snow':
        return Icons.ac_unit;
      case 'clear':
        return Icons.wb_sunny;
      default:
        return Icons.wb_sunny;
    }
  }

  Color? getWeatherIconColors(String condition) {
    switch (condition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return Colors.blueGrey;
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return Colors.blue;
      case 'thunderstorm':
        return Colors.grey;
      case 'snow':
        return Colors.blue;
      case 'clear':
        return Colors.yellow;
      default:
        return Colors.yellow[700];
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            cityName[0].toUpperCase() + cityName.substring(1),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.refresh,
                color: Colors.black,
              ),
              onPressed: () {
                setState(() {
                  isLoading = true;
                });
                getCurrentWeather();
                print('Refresh');
              },
            )
          ],
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Card(
                          elevation: 10,
                          child: Column(children: [
                            Text(
                              '${currentTemp.toStringAsFixed(2)} °C',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(
                              /*
                              currentSkyCondition == 'Clouds' ||
                                      currentSkyCondition == 'Mist' ||
                                      currentSkyCondition == 'Rain'
                                  ? Icons.cloud
                                  : Icons.wb_sunny,
                                  */
                              getWeatherIcon(currentSkyCondition),
                              size: 64,
                              color: getWeatherIconColors(currentSkyCondition),
                              /*
                              color: currentSkyCondition == 'Clouds' ||
                                      currentSkyCondition == 'Mist' ||
                                      currentSkyCondition == 'Rain'
                                  ? Colors.blueGrey
                                  : Colors.yellow[700],
                                  */
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                              currentSkyCondition,
                              style: TextStyle(fontSize: 24),
                            ),
                          ]),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: const Text(
                          'Hourly Forecast',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      // SingleChildScrollView(
                      //   scrollDirection: Axis.horizontal,
                      //   child: Row(
                      //     children: [
                      //       HourlyForecastCard(),
                      //       HourlyForecastCard(),
                      //       HourlyForecastCard(),
                      //       HourlyForecastCard(),
                      //       HourlyForecastCard(),
                      //       HourlyForecastCard(),
                      //     ],
                      //   ),
                      // ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          /*
                          children: List.generate(6, (index) {
                            return HourlyForecastCard(
                                //time: times[index].toLocal().toString().substring(11, 16),
                                //icon: getWeatherIcon(skyConditions[index]),
                                //temperature: '${temperatures[index].toStringAsFixed(1)} °C',
                                );
                          }),
                          */

                          children: hourlyForecasts.map((forecast) {
                            return HourlyForecastCard(
                              time:
                                  DateFormat('HH:mm').format(forecast['time']),
                              icon: getWeatherIcon(forecast['condition']),
                              color:
                                  getWeatherIconColors(forecast['condition']),
                              temperature: '${forecast['temperature']}°C',
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: const Text(
                          'Additional Info',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AdditionalInfo(
                            title: 'Wind',
                            value: currentWindSpeed.toStringAsFixed(2),
                            icon: Icons.air,
                          ),
                          AdditionalInfo(
                            title: 'Humidity',
                            value: currentHumidity.toStringAsFixed(2),
                            icon: Icons.water,
                          ),
                          AdditionalInfo(
                            title: 'Pressure',
                            value: currentPressure.toStringAsFixed(2),
                            icon: Icons.arrow_downward,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 60,
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Change Location'),
                                    content: TextField(
                                      controller: cityController,
                                      decoration: InputDecoration(
                                          hintText: 'Enter City Name'),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp('[a-zA-Z]'))
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Cancel')),
                                      TextButton(
                                          onPressed: () {
                                            setState(() {
                                              cityName = cityController.text;
                                              isLoading = true;
                                            });
                                            getCurrentWeather();
                                            Navigator.pop(context);
                                          },
                                          child: const Text('OK'))
                                    ],
                                  );
                                });
                          },
                          child: Text(
                            'Change Location',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ));
  }
}
