import 'package:ble1/settings/calibrate_t_p_s_dialog.dart';
import 'package:ble1/settings/show_temperature_calibration_dialog.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

String loggerId = '000';
bool daylightSaving = false;
int rpmMultiplier = 1;
int minRawTPS = 0;
int maxRawTPS = 20000;

int rpm = 0;
int tpsValue = 0;
int rawTpsValue = 0;
int engineTemp = 0;
double engineTempVolts = 0;
int airTemp = 0;
int batteryVoltage = 0;
double batteryVoltageDouble = 0.0;
int rawLambda = 0;
double afr = 0;

final StreamController<Map<String, dynamic>> streamController =
    StreamController.broadcast();

class Settings extends StatefulWidget {
  final BluetoothCharacteristic settingsCharacteristic;
  final BluetoothCharacteristic liveDataCharacteristic;

  const Settings(
      {super.key,
      required this.settingsCharacteristic,
      required this.liveDataCharacteristic});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late StreamSubscription<List<int>> liveDataSub;
  late StreamSubscription<List<int>> settingsSub;
  bool jsonReceived = false;

  @override
  void initState() {
    super.initState();
    getLoggerSettings(widget.settingsCharacteristic);
    getLiveData(widget.liveDataCharacteristic);
  }

  @override
  void dispose() {
    liveDataSub.cancel();
    settingsSub.cancel();

    widget.liveDataCharacteristic.write(utf8.encode("STOP"));
    widget.liveDataCharacteristic.setNotifyValue(false);
    widget.settingsCharacteristic.setNotifyValue(false);

    super.dispose();
  }

  Future<void> getLiveData(
      BluetoothCharacteristic liveDataCharacteristic) async {
    try {
      // 1. Subscribe to notifications
      await liveDataCharacteristic.setNotifyValue(true);

      // 2. Save the subscription so we can cancel it later
      liveDataSub = liveDataCharacteristic.onValueReceived.listen((value) {
        final jsonString = utf8.decode(value);
        print("Live Data: $jsonString");

        try {
          final data = jsonDecode(jsonString);

          rpm = data['rpm'] ?? 0;
          airTemp = data['airTemp'] ?? 0;
          engineTemp = data['engineTemp'] ?? 0;
          engineTempVolts = data['engineTempVolts'] ?? 0;
          tpsValue = data['tps'] ?? 0;
          rawTpsValue = data['rawTps'] ?? 0;
          batteryVoltage = data['bVolts'] ?? 0;
          batteryVoltageDouble = batteryVoltage / 10;
          rawLambda = data['lambda'] ?? 0;
          afr = (rawLambda / 100.0) * 14.7;
          afr = double.parse(afr.toStringAsFixed(2));

          streamController.add({
            'raw': rawTpsValue,
            'percent': tpsValue,
            'engineTemperatureVolts': engineTempVolts,
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

  // bool jsonReceived = false; // Track if real JSON has been received

  Future<void> getLoggerSettings(BluetoothCharacteristic c) async {
    try {
      await c.setNotifyValue(true);
      print("Subscribed to notifications");

      settingsSub = c.onValueReceived.listen((value) {
        if (jsonReceived) return;

        try {
          final jsonString = utf8.decode(value);
          print("# Decoded JSON string: $jsonString");

          final jsonData = jsonDecode(jsonString);
          jsonReceived = true;

          loggerId = jsonData['LoggerId'] ?? '000';
          daylightSaving = jsonData['daylightSaving'] ?? false;
          rpmMultiplier = jsonData['rpmMultiplier'] ?? 1;
          minRawTPS = jsonData['tpsMin'] ?? 0;
          maxRawTPS = jsonData['tpsMax'] ?? 20000;

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

  //-----------------------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logger Settings'),
      ),
      body: Center(
        child: SizedBox(
          height: 700,
          width: 1200,
          child: Container(
            padding: const EdgeInsets.all(120.0),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 7,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
              borderRadius: BorderRadius.circular(10),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text(
                        'DayLight Savings Time',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      const SizedBox(width: 20),
                      Transform.scale(
                        scale:
                            0.8, // Adjust the scale factor (e.g., 0.8 for 80% size)
                        child: Switch(
                          value: daylightSaving,
                          onChanged: (bool value) {
                            setState(() {
                              daylightSaving = value;
                            });
                            sendLoggerSettings(widget.settingsCharacteristic);
                          },
                          activeColor: Colors.blue,
                          inactiveThumbColor: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ParameterToAdjust(
                    title: 'Logger ID',
                    value: loggerId,
                    adjustmentProcedure: SetId(
                      settingsCharacteristic: widget.settingsCharacteristic,
                      loggerId: loggerId,
                      onUpdated: () {
                        setState(
                            () {}); // 👈 Rebuild Settings UI, // Pass settings to SetId
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  ParameterToAdjust(
                      title: 'RPM',
                      value: rpm.toString(),
                      adjustmentProcedure: RpmMultiplier(
                          settingsCharacteristic:
                              widget.settingsCharacteristic)),
                  const SizedBox(height: 20),
                  ParameterToAdjust(
                    title: 'Air Temperature',
                    value: airTemp.toString(),
                    adjustmentProcedure: const Calibrate(),
                  ),
                  const SizedBox(height: 20),
                  ParameterToAdjust(
                      title: 'Water Temperature',
                      value: engineTemp.toString(),
                      adjustmentProcedure: TextButton(
                        onPressed: () {
                          showTemperatureCalibrationDialog(
                            context,
                            widget.settingsCharacteristic,
                          );
                        },
                        child: const Text(
                          'Calibrate',
                          style: TextStyle(color: Colors.blue, fontSize: 19),
                        ),
                      )),
                  const SizedBox(height: 20),
                  ParameterToAdjust(
                    title: 'Throttle Position',
                    value: '$tpsValue %',
                    adjustmentProcedure: CalibrateTPS(
                      settingsCharacteristic: widget.settingsCharacteristic,
                      onUpdated: () {
                        setState(() {}); // 👈 Rebuild Settings UI
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  ParameterToAdjust(
                    title: 'Battery Voltage',
                    value: '$batteryVoltageDouble Volts',
                  ),
                  const SizedBox(height: 20),
                  const SizedBox(height: 20),
                  ParameterToAdjust(
                    title: 'AFR ',
                    value: '$afr : 1',
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ParameterToAdjust extends StatelessWidget {
  const ParameterToAdjust({
    super.key,
    required this.title,
    this.value = '',
    this.adjustmentProcedure,
  });

  final String title;
  final String value;
  final Widget? adjustmentProcedure;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Row(
          children: [
            SizedBox(
              width: 235,
              child: Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            SizedBox(
              width: 155,
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                ),
              ),
            ),
            adjustmentProcedure ?? const SizedBox.shrink(),
          ],
        ),
      ],
    );
  }
}

class SetId extends StatefulWidget {
  final BluetoothCharacteristic settingsCharacteristic;
  final String loggerId;
  final VoidCallback onUpdated;

  const SetId({
    super.key,
    required this.settingsCharacteristic,
    required this.loggerId,
    required this.onUpdated,
  });

  @override
  State<SetId> createState() => _SetIdState();
}

class _SetIdState extends State<SetId> {
  final TextEditingController myController1 = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController1.dispose();
    super.dispose();
  }

  @override
  void initState() {
    myController1.text = '';
    return super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> changeLoggerId() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Change Logger ID',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            content: TextField(
              controller: myController1,
              onTap: myController1.clear,
              maxLength: 3,
              decoration: const InputDecoration(
                labelText: 'Enter Three-Digit ID',
                labelStyle: TextStyle(color: Colors.black, fontSize: 18),
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 18),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                      child: const Text(
                        'SET',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                      onPressed: () async {
                        loggerId = myController1.text;
                        if (loggerId.length < 3) {
                          return;
                        }
                        widget.onUpdated(); // 👈 Notify parent to rebuild
                        Navigator.of(context).pop();
                        await sendLoggerSettings(widget.settingsCharacteristic);
                      }),
                ],
              ),
            ],
          );
        },
      );
    }

    return TextButton(
      child: const Text(
        'Set Logger ID',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.blue, fontSize: 19),
      ),
      onPressed: () {
        changeLoggerId();
      },
    );
  }
}
//------------------------------------------------------------------------------------------

class RpmMultiplier extends StatelessWidget {
  final BluetoothCharacteristic settingsCharacteristic;
  const RpmMultiplier({super.key, required this.settingsCharacteristic});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: const Text(
        'Set Multiplier',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.blue, fontSize: 19),
      ),
      onPressed: () {
        rpmMultiplier *=
            2; // this is a real value returned, so could be displayed
        if (rpmMultiplier > 4) {
          rpmMultiplier = 1;
        }
        sendLoggerSettings(settingsCharacteristic);
        // getLoggerSettings(settingsCharacteristic);
      },
    );
  }
}
//------------------------------------------------------------------------------------------

class Calibrate extends StatelessWidget {
  const Calibrate({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
        child: const Text(
          'Calibrate',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.blue, fontSize: 19),
        ),
        onPressed: () {});
  }
}

//----------------------------------------------------------------------------------
Future<void> sendLoggerSettings(BluetoothCharacteristic c) async {
  try {
    Map<String, dynamic> payload = {
      "cmd": "SAVE_SETTINGS",
      "loggerId": loggerId,
      "daylightSaving": daylightSaving,
      "rpmMultiplier": rpmMultiplier,
      "minRawTPS": minRawTPS,
      "maxRawTPS": maxRawTPS,
    };

    String jsonString = jsonEncode(payload);
    List<int> jsonBytes = utf8.encode(jsonString);

    await c.write(jsonBytes, withoutResponse: false);
    print("✅ Sent settings to ESP32: $jsonString");
  } catch (e) {
    print("❌ Failed to send settings: $e");
  }
}
