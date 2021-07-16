import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:weather_example_app/const.dart';
import 'package:weather_example_app/one_api_call_model.dart';

import 'api_model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final apiModel = ApiResponse();
  ApiResponse currentWeather;
  OneApiCall oneApiCallWeather;
  List<Daily> daily = [];
  final constData = ConstantData();

  /// current weather api call
  // Future<void> _fetchData() async {
  //   String key = constData.apiKey;
  //   // String API_URL = 'https://api.openweathermap.org/data/2.5/weather?q=London&APPID=$key'; // current weather api call
  //   final response = await http.get(Uri.parse(API_URL));
  //   final data = ApiResponse.fromJson(jsonDecode(response.body)); // current weather
  //
  //   setState(() {
  //     currentWeather = data;
  //   });
  // }

  /// One call api
  Future<void> _fetchData() async {
    String key = constData.apiKey;
    String API_URL = 'https://api.openweathermap.org/data/2.5/onecall?lat=33.44&lon=-94.04&exclude=minutely&APPID=$key';
    final response = await http.get(Uri.parse(API_URL));
    final data = OneApiCall.fromJson(jsonDecode(response.body)); // current weather

    setState(() {
      oneApiCallWeather = data;
      daily = data.daily;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: AspectRatio(
        aspectRatio: 1.23,

        child: Container(margin: EdgeInsets.symmetric(vertical: 10, horizontal: 3),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(18)),
            gradient: LinearGradient(
              colors: [
                Color(0xff2c274c),
                Color(0xff46426c),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          child: Stack(
            children: [
              body()
            ],
          ),
        ), // one api call
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  body(){
    // return  child: currentWeather == null ? fetchButton() : fetchedData(), // current weather
    return oneApiCallWeather == null ? fetchButton() : fetchedData();
  }

  Widget fetchButton(){
    return Center(
      child: ElevatedButton(
        child: Text('Load Weather'),
        onPressed: _fetchData,
      ),
    );
  }

  Widget fetchedData(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
         Text(
            "City: " + oneApiCallWeather.timezone,
          style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 2),
          textAlign: TextAlign.center,
        ),
        Expanded(child: chart()) /// remove this if you will ise current weather api call
      ],
    );
  }

  Widget chart(){

    return LineChart(
      LineChartData(
        ///ToolTip
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
          ),
          touchCallback: (LineTouchResponse touchResponse) {},
          handleBuiltInTouches: true,
        ),
        titlesData: FlTitlesData(
          bottomTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            getTextStyles: (value) => const TextStyle(
              color: Color(0xff72719b),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            margin: 10,
            getTitles: (value) {

              return "";
            },
          ),
          leftTitles: SideTitles(
            showTitles: true,
            getTextStyles: (value) => const TextStyle(
              color: Color(0xff75729e),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            getTitles: (value) {
              switch (value.toInt()) {
                case 1:
                  return '5 °C';
                case 2:
                  return '10 °C';
                case 3:
                  return '15 °C';
                case 4:
                  return '20 °C';
              }
              return '';
            },
            margin: 8,
            reservedSize: 30,
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border(
            bottom: BorderSide(
              color: Color(0xff4e4965),
              width: 4,
            ),
            left: BorderSide(
              color: Colors.transparent,
            ),
            right: BorderSide(
              color: Colors.transparent,
            ),
            top: BorderSide(
              color: Colors.transparent,
            ),
          ),
        ),
        // minX: 0,
        // maxX: 14,
        // maxY: 20,
        // minY: 0,
        lineBarsData: linesBarData(),

      ),
      swapAnimationDuration: Duration(milliseconds: 150), // Optional
      swapAnimationCurve: Curves.linear, // Optional
    );
  }

  List<LineChartBarData> linesBarData(){
    List<FlSpot> listData = [];
    for(var i = 0; i < daily.length; i++){
      var date = DateTime.fromMillisecondsSinceEpoch(daily[i].dt);
      var formattedDate = DateFormat('d').format(date);
      listData.add(FlSpot(double.parse(i.toString()), daily[i].temp.max));
      setState(() {

      });
    }
    final lineChartBarData1 = LineChartBarData(
      spots: listData,
      isCurved: true,
      colors: [
        const Color(0xff4af699),
      ],
      barWidth: 8,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: false,
      ),
      belowBarData: BarAreaData(
        show: false,
      ),
    );
    return [
      lineChartBarData1,
    ];
  }
}
