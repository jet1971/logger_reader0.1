import 'dart:async';
import 'package:ble1/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class CalibrateTPSDialog extends StatefulWidget {
  final BluetoothCharacteristic settingsCharacteristic;
  final VoidCallback onUpdated;

  const CalibrateTPSDialog({
    super.key,
    required this.settingsCharacteristic,
    required this.onUpdated,
  });

  @override
  State<CalibrateTPSDialog> createState() => _CalibrateTPSDialogState();
}

class _CalibrateTPSDialogState extends State<CalibrateTPSDialog> {
  late StreamSubscription sub;
  int localRaw = rawTpsValue;
  int localPercent = tpsValue;

  @override
  void initState() {
    super.initState();
    sub = streamController.stream.listen((data) {
      if (!mounted) return;
      setState(() {
        localRaw = data['raw'];
        localPercent = data['percent'];
      });
    });
  }

  @override
  void dispose() {
    sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Calibrate TPS',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Raw: $localRaw  TP: $localPercent %'),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                child: const Text('Set closed',
                    style:
                        TextStyle(fontSize: 14, color: Colors.black)),
                onPressed: () async {
                  minRawTPS = localRaw;
                  widget.onUpdated();
                  await sendLoggerSettings(widget.settingsCharacteristic);
                },
              ),
              TextButton(
                child: const Text('Set open',
                    style:
                        TextStyle(fontSize: 14, color: Colors.black)),
                onPressed: () async {
                  maxRawTPS = localRaw;
                  widget.onUpdated();
                  await sendLoggerSettings(widget.settingsCharacteristic);
                },
              ),
            ],
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close Window',
                style: TextStyle(fontSize: 14, color: Colors.black)),
          ),
        ],
      ),
    );
  }
}

class CalibrateTPS extends StatelessWidget {
  final BluetoothCharacteristic settingsCharacteristic;
  final VoidCallback onUpdated;

  const CalibrateTPS({
    super.key,
    required this.settingsCharacteristic,
    required this.onUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: const Text(
        'Calibrate',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.blue, fontSize: 19),
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) => CalibrateTPSDialog(
            settingsCharacteristic: settingsCharacteristic,
            onUpdated: onUpdated,
          ),
        );
      },
    );
  }
}
