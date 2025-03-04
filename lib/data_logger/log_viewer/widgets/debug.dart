import 'package:flutter/material.dart';
import 'package:ble1/data_logger/provider/datalog_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DebugWidget extends ConsumerWidget {
  const DebugWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final temperatureData = ref.watch(dataLogProvider.notifier).allData;
    final rpmData = ref.watch(dataLogProvider.notifier).allData;
    final oilPressureData = ref.watch(dataLogProvider.notifier).allData;
    final gpsData = ref.watch(dataLogProvider.notifier).allData;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SingleChildScrollView(
              child: Column(
                children: gpsData.asMap().entries.map((entry) {
                  final index = entry.key; // The integer index
                  final data = entry.value; // The actual map item

                  return Row(
                    children: [
                      // Show the 1-based index (index + 1)
                      Text(
                        '${index + 1}. ',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      // Show your RPM
                      Text(
                        data['rpm'].toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Show your timestamp
                      Text(
                        data['timestamp'].toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),

            ),
            SingleChildScrollView(
              child: Column(
                children: temperatureData.asMap().entries.map((entry) {
                  final index = entry.key; // The integer index
                  final data = entry.value; // The actual map item

                  return Row(
                    children: [
                      // Show the 1-based index (index + 1)
                      Text(
                        '${index + 1}. ',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      // Show your RPM
                      Text(
                        data['coolantTemperature'].toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Show your timestamp
                      Text(
                        data['timestamp'].toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),

            ),
            SingleChildScrollView(
             child: Column(
                children: oilPressureData.asMap().entries.map((entry) {
                  final index = entry.key; // The integer index
                  final data = entry.value; // The actual map item

                  return Row(
                    children: [
                      // Show the 1-based index (index + 1)
                      Text(
                        '${index + 1}. ',
                        style: const TextStyle( 
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      // Show your RPM
                      Text(
                        data['afr'].toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Show your timestamp
                      Text(
                        data['timestamp'].toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),

            ),
          ],
        ),
      ),
    );
  }
}
