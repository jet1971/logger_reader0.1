import 'dart:async';
import 'dart:convert';
import 'package:ble1/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';





Future<void> showTemperatureCalibrationDialog(BuildContext context,
    final BluetoothCharacteristic settingsCharacteristic) async {
  await showDialog(
    context: context,
    builder: (_) => TemperatureCalibrationDialog(
      settingsCharacteristic: settingsCharacteristic,
      onUpdated: () {
        print("Temperature calibration updated");
      },
    ),
  );
}

class TemperatureCalibrationDialog extends StatefulWidget {
  final BluetoothCharacteristic settingsCharacteristic;
  final VoidCallback onUpdated;
  

  const TemperatureCalibrationDialog({
    super.key,
    required this.settingsCharacteristic,
    required this.onUpdated,
  });

  @override
  State<TemperatureCalibrationDialog> createState() =>
      _TemperatureCalibrationDialogState();
}

class _TemperatureCalibrationDialogState extends State<TemperatureCalibrationDialog> {

  List tempPoints = [0, 20, 40, 60, 80, 100, 120];
  List voltagePoints = [3.312, 3.011, 2.522, 2.011, 1.115, 1.230, 0.765];

  late List temperaturePointsList;
  late List voltagePointsList;
  double liveVoltage = engineTempVolts;
  StreamSubscription? sub;
  late StreamSubscription<List<int>> temperatureCalibrationSub;
  bool jsonReceived = false;
  bool isLoading = true;






  Future<void> getEngineTemperatureCalibration(BluetoothCharacteristic c) async {
    try {
      await c.setNotifyValue(true);
      print("Subscribed to notifications");

      temperatureCalibrationSub = c.onValueReceived.listen((value) {
        if (jsonReceived) return;

        try {
          final jsonString = utf8.decode(value);
          print("# Decoded JSON string: $jsonString");

          final jsonData = jsonDecode(jsonString);
          jsonReceived = true;

          voltagePoints[0] = (jsonData['V0'] ?? 3.3).toDouble();
          voltagePoints[1] = (jsonData['V1'] ?? 3.0).toDouble();
          voltagePoints[2] = (jsonData['V2'] ?? 2.5).toDouble();
          voltagePoints[3] = (jsonData['V3'] ?? 2.0).toDouble();
          voltagePoints[4] = (jsonData['V4'] ?? 1.5).toDouble();
          voltagePoints[5] = (jsonData['V5'] ?? 1.0).toDouble();
          voltagePoints[6] = (jsonData['V6'] ?? 0.5).toDouble();


       
          setState(() {
            isLoading = false;
          });
        } catch (e) {
          print("# JSON parse error: $e");
        }
      });

      //await c.write(utf8.encode("GET_SETTINGS"), withoutResponse: false);
      await c.write(
          utf8.encode(jsonEncode({"cmd": "GET_E_T_C"})));

      print("Sent GET_E_TEMPERATURE_CALIBRATION");
    } catch (e) {
      print('# Error in get_E_TEMPERATURE_CALIBRATION: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getEngineTemperatureCalibration(widget.settingsCharacteristic);

    // Subscribe to live sensor stream
    sub = streamController.stream.listen((data) {
      if (!mounted) return;
      setState(() {
        liveVoltage = data['engineTempVolts'] ?? engineTempVolts;
      });
    });
  }

  @override
  void dispose() {
    temperatureCalibrationSub.cancel();
    sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  final temperaturePointsList = List.generate(
    7,
    (i) => SizedBox(
      width: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Temp',
            style: TextStyle(
              color: Color.fromARGB(139, 109, 108, 108),
              fontSize: 12,
            ),
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 5),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color.fromARGB(138, 30, 30, 30),
                  width: 1.0,
                ),
              ),
            ),
            child: Text('${tempPoints[i].toString()}      '),
          ),
        ],
      ),
    ),
  );

  final voltagePointsList = List.generate(
    7,
    (i) => SizedBox(
      width: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Voltage',
            style: TextStyle(
              color: Color.fromARGB(139, 109, 108, 108),
              fontSize: 12,
            ),
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 5),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color.fromARGB(138, 30, 30, 30),
                  width: 1.0,
                ),
              ),
            ),
            child: Text('${voltagePoints[i].toStringAsFixed(3)}   '),
          ),
        ],
      ),
    ),
  );

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return AlertDialog(
      title: const Text('Calibrate Engine Temperature'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              'Live sensor voltage: ${liveVoltage.toStringAsFixed(3)} V',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Column(
              children: List.generate(7, (index) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    temperaturePointsList[index],
                    voltagePointsList[index],
                    TextButton(
                      onPressed: () {
                        voltagePoints[index] = liveVoltage;
                        setState(() {});
                        widget.onUpdated();
                        sendEngineTemperatureCalibration(
                            widget.settingsCharacteristic,
                            voltagePoints);
                        //     print(voltagePoints);
                      },
                      child: const Text(
                        'SET',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Close Window',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }
}

Future<void> sendEngineTemperatureCalibration(BluetoothCharacteristic c, voltagePoints) async {
  try {
    Map<String, dynamic> payload = {
      "cmd": "SAVE_E_T_C",
      "V0": voltagePoints[0],
      "V1": voltagePoints[1],
      "V2": voltagePoints[2],
      "V3": voltagePoints[3],
      "V4": voltagePoints[4],
      "V5": voltagePoints[5],
      "V6": voltagePoints[6],
    };

    String jsonString = jsonEncode(payload);
    List<int> jsonBytes = utf8.encode(jsonString);

    await c.write(jsonBytes, withoutResponse: false);
    print("✅ Sent Temperature settings to ESP32: $jsonString");
//   getEngineTemperatureCalibation(widget.settingsCharacteristic);
  } catch (e) {
    print("❌ Failed to send settings: $e");
  }
}
