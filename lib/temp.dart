import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

int rpm = 0;
int rpmMultiplier = 1;
int filteredValue = 0;
int shifterVoltage = 0;
int quickShifterSensitivityThreshold = 0;
int sensorDirection = 0;
int killTime = 0;
int minRpmCut = 0;
double shiftLightOnRpm = 0;
int calibrationInterval = 0;
int calibrationIsloadedThreshold = 0;
double alpha = 0;
int minShiftAgainTime = 0;
int thresholdDebounceTime = 0;

final StreamController<Map<String, dynamic>> streamController =
    StreamController.broadcast();

class TestPage extends StatefulWidget {
  const TestPage(
      {super.key,
      required this.qsSettingsCharacteristic,
      required this.qsLiveDataCharacteristic});

  final BluetoothCharacteristic qsSettingsCharacteristic;
  final BluetoothCharacteristic qsLiveDataCharacteristic;

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  late StreamSubscription<List<int>> qsLiveDataSub;
  late StreamSubscription<List<int>> qsSettingsSub;
  bool jsonReceived = false;

  @override
  void initState() {
    super.initState();
    getQsSettings(widget.qsSettingsCharacteristic);
    getQsLiveData(widget.qsLiveDataCharacteristic);
  }

  @override
  void dispose() {
    qsLiveDataSub.cancel();
    qsSettingsSub.cancel();
    widget.qsLiveDataCharacteristic.write(utf8.encode("STOP"));
    widget.qsLiveDataCharacteristic.setNotifyValue(false);
    widget.qsSettingsCharacteristic.setNotifyValue(false);
    super.dispose();
  }

  Future<void> getQsLiveData(
      BluetoothCharacteristic liveDataCharacteristic) async {
    try {
      // 1. Subscribe to notifications
      await liveDataCharacteristic.setNotifyValue(true);

      // 2. Save the subscription so we can cancel it later
      qsLiveDataSub = liveDataCharacteristic.onValueReceived.listen((value) {
        final jsonString = utf8.decode(value);
        print("Live Data: $jsonString");

        try {
          final data = jsonDecode(jsonString);

          rpm = data['rpm'] ?? 0;
          filteredValue = data['filterdValue'] ?? 0;
          shifterVoltage = data['shifterVoltage'] ?? 0;

          streamController.add({
            'filterdValue': filteredValue,
            'rpm': rpm,
            'shifterVoltage': shifterVoltage,
          });

          if (!mounted) return;
          setState(() {});
        } catch (e) {
          print("⚠️ JSON Parse Error: $e");
        }
      });

      // 3. Send the START command
      await liveDataCharacteristic.write(utf8.encode("START"));
      print("✅ Requested live data stream");
    } catch (e) {
      print("❌ Failed to get live data: $e");
    }
  }

  Future<void> getQsSettings(BluetoothCharacteristic c) async {
    try {
      await c.setNotifyValue(true);
      print("Subscribed to notifications");

      qsSettingsSub = c.onValueReceived.listen((value) {
        if (jsonReceived) return;

        try {
          final jsonString = utf8.decode(value);
          print("# Decoded JSON string: $jsonString");

          final jsonData = jsonDecode(jsonString);
          jsonReceived = true;

          rpmMultiplier = jsonData['rpmMultiplier'] ?? 1;
          quickShifterSensitivityThreshold =
              jsonData['quickShifterSensitivityThreshold'] ?? 0;
          sensorDirection = jsonData['sensorDirection'] ?? 0;
          killTime = jsonData['killTime'] ?? 0;
          alpha = jsonData['alpha'] ?? 0;
          minRpmCut = jsonData['minRpmCut'] ?? 0;
          shiftLightOnRpm = jsonData['shiftLightOnRpm'] ?? 0;
          calibrationInterval = jsonData['calibrationInterval'] ?? 0;
          calibrationIsloadedThreshold =
              jsonData['calibrationIsloadedThreshold'] ?? 0;
          minShiftAgainTime = jsonData['minShiftAgainTime'] ?? 0;
          thresholdDebounceTime = jsonData['thresholdDebounceTime'] ?? 0;

          if (!mounted) return;
          setState(() {});
        } catch (e) {
          print("# JSON parse error: $e");
        }
      });

      //await c.write(utf8.encode("GET_SETTINGS"), withoutResponse: false);
      await c.write(utf8.encode(jsonEncode({"cmd": "GET_SETTINGS"})));

      print("Sent GET_SETTINGS request");
    } catch (e) {
      print('# Error in getLoggerSettings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Temp Shifter Page'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Text('Sensor Pressure: '),
                  Text(shifterVoltage.toString()),
                ],
              ),
               Row(
                children: [Text('KillTime: '), Text(killTime.toString())],
              ),
                      Row(
                children: [Text('Sensor Direction: '), Text(sensorDirection.toString())],
              ),
              SliderExample(
                filteredValue: filteredValue,
                rpm: rpm,
                shifterVoltage: shifterVoltage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SliderExample extends StatefulWidget {
 SliderExample(
      {super.key,
      required this.filteredValue,
      required this.rpm,
      required this.shifterVoltage});

  final int filteredValue;
  final int rpm;
  int shifterVoltage;

  @override
  SliderExampleState createState() => SliderExampleState();
}

class SliderExampleState extends State<SliderExample> {
  double desiredValue = 50.0; // Initial desired value
  double actualValue = 25.0; // Initial actual value (can be dynamic)

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Row(
            children: [
              Text(' Filter output: '),
              Text(widget.filteredValue.toString())
            ],
          ),
          Row(
            children: [Text('RPM: '), Text(widget.rpm.toString())],
          ),
          Row(
            children: [Text('Alpha: '), Text('0.01')],
          ),
  
         
          Row(
            children: [Text('Shift Again Time: '), Text('500')],
          ),
          Row(
            children: [Text('Debounce Time: '), Text('150')],
          ),
          Row(
            children: [Text('Min RPM Cut: '), Text('4000')],
          ),
          Row(
            children: [Text('Shiftlight On: '), Text('13300')],
          ),
          Row(
            children: [Text('Rpm Multiplier: '), Text('x2')],
          ),
          Row(
            children: [Text('Self Calibrate interval: '), Text('5000')],
          ),
          Row(
            children: [Text('Claibration Loaded Threshold: '), Text('75%')],
          ),
          Text(
            'Set Value: ${desiredValue.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
          Text(
            'Actual Value: ${shifterVoltage.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
          RotatedBox(
            quarterTurns: 3,
            child: SizedBox(
              width: 400, // sets the overall size of the slider
              height: 30, // sets the overall size of the slider
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(),
                        borderRadius:
                            BorderRadius.circular(7)), // the background

                    height: 15,
                    width: 339,
                  ),
                  SliderTheme(
                    // --------------------------------------- this the actual value received

                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4.0,
                      trackShape: const RoundedRectSliderTrackShape(),
                      activeTrackColor: Colors.blue,
                      inactiveTrackColor: Colors.white,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 0,
                        pressedElevation: 0,
                      ),
                      thumbColor: Colors.blue,
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 32.0),
                    ),
                    child: Slider(
                      min: 0.0,
                      max: 100.0,
                      value: shifterVoltage.toDouble(),
                      onChanged: (value) {
                        setState(() {
                          shifterVoltage = value.toInt();
                        });
                      },
                    ),
                  ),
                  // ------------------------------------------------------------------------------------------------
                  SliderTheme(
                    // -----------------------------------the set value

                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 10.0,
                      trackShape: const RoundedRectSliderTrackShape(),
                      activeTrackColor: const Color.fromRGBO(0, 0, 0, 0),
                      inactiveTrackColor: const Color.fromRGBO(0, 0, 0, 0),
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6.0,
                        pressedElevation: 0,
                      ),
                      thumbColor: Colors.blue,
                      overlayColor: const Color.fromARGB(99, 247, 236, 236),
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 32.0),
                    ),
                    child: Slider(
                      value: desiredValue,
                      min: 0,
                      max: 100,
                      label: desiredValue.round().toString(),
                      onChanged: (double value) {
                        setState(() {
                          desiredValue = value;
                        });
                      },
                    ),
                  ),

                  // Display desired value on top
                  // Positioned(
                  //   top: 125,
                  //   child: Text(
                  //     // 'Desired Value: ${desiredValue.toStringAsFixed(1)}',
                  //     'Desired Value: ${desiredValue.toStringAsFixed(1)}',
                  //     style: const TextStyle(fontSize: 16, color: Colors.white),
                  //   ),
                  // ),
                  // Positioned(
                  //   top: 50,
                  //   child: Text(
                  //     'Actual Value: ${actualValue.toStringAsFixed(1)}',
                  //     style: const TextStyle(fontSize: 16),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
