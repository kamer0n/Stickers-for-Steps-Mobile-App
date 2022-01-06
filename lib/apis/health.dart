import 'package:health/health.dart';

import 'dart:convert';

import 'package:darkmodetoggle/apis/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

Future<int> fetchSteps() async {
  List<HealthDataPoint> _healthDataList = [];

  DateTime now = DateTime.now();
  DateTime start = DateTime(now.year, now.month, now.day);
  DateTime end = start.add(const Duration(days: 1));

  HealthFactory health = HealthFactory();

  // define the types to get
  List<HealthDataType> types = [
    HealthDataType.STEPS,
  ];

  bool accessWasGranted = await health.requestAuthorization(types);

  int steps = 0;

  if (accessWasGranted) {
    try {
      // fetch new data
      List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(start, end, types);

      // save all the new data points
      _healthDataList.addAll(healthData);
    } catch (e) {
      print("Caught exception in getHealthDataFromTypes: $e");
    }

    // filter out duplicates
    _healthDataList = HealthFactory.removeDuplicates(_healthDataList);

    // print the results
    _healthDataList.forEach((x) {
      steps += x.value.round();
    });

    return steps;
  } else {
    return 0;
  }
}

Future<Map<String, dynamic>> fetchTarget(int steps) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  final response = await http.Client().post(Uri.parse(stepaccess),
      body: {"steps": steps.toString()},
      headers: {"authorization": "TOKEN " + (preferences.getString('token') ?? defaultToken)});
  final Map<String, dynamic> parsed = jsonDecode(response.body);
  return parsed;
}

Future<List<int>> fetchStepsAndTarget() async {
  int sticker = 0;
  int steps = await fetchSteps();
  Map<String, dynamic> stepsPostResponse = await fetchTarget(steps);
  int target = int.parse(stepsPostResponse['target']);
  if (stepsPostResponse.containsKey('sticker')) {
    sticker = stepsPostResponse['sticker']['id'];
  }
  return [steps, target, sticker];
}
