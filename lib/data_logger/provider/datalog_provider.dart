// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ble1/data_logger/provider/local_file_list_provider.dart';

// class DataLogProvider extends StateNotifier<Uint8List> {
//   // Parsed data state
//   List<Map<String, dynamic>> allData = [];

//   DataLogProvider() : super(Uint8List(0));



//   Future<String> getFilePath(String fileName) async {
//     Directory directory = await getApplicationDocumentsDirectory();
//     return '${directory.path}/$fileName'; // Ensure the slash is correct
//   }

//   Future<void> writeToFile(Uint8List data, String fileName) async {
//     final path = await getFilePath(fileName);
//     print('Saving data to path: $path');
//     final file = File(path);

//     // Write the binary data to the file
//     await file.writeAsBytes(data);
//     print('Data written to file: $data');
//   }

//   void saveData(String fileName, WidgetRef ref) async {
//     if (state.isEmpty) {
//       print('No data to save.');
//       return;
//     }

//     // Save the current state (Uint8List) to the file
//     await writeToFile(state, fileName);

//     // Trigger the provider to update after saving
//     ref.read(localFileListProvider.notifier).loadLocalFileList();
//     print('Data saved to $fileName');
//   }

//   Future<void> deleteFile(String fileName, WidgetRef ref) async {
//     try {
//       // Get the directory where the file is stored
//       final directory = await getApplicationDocumentsDirectory();
//       final filePath = '${directory.path}/$fileName';

//       // Create a File instance for the file
//       final file = File(filePath);

//       // Check if the file exists, and delete it if it does
//       if (await file.exists()) {
//         await file.delete();
//         print('File deleted.... $filePath');
//       } else {
//         print('File not found: $filePath');
//       }
//       // Trigger the provider to update after saving
//       ref.read(localFileListProvider.notifier).loadLocalFileList();
//       //.Load; // or update the relevant part of the state
//     } catch (e) {
//       print('Error deleting file: $e');
//     }
//   }

//   double mapValue(
//       double x, double inMin, double inMax, double outMin, double outMax) {
//     return ((x - inMin) * (outMax - outMin) / (inMax - inMin)) + outMin;
//   }

//   //----------------------------------------------------------------------------------------
//   void setDatalog(Uint8List newLog) {
//     print('Setting new log');
//     state = newLog; // Update the state with the raw data
//     allData.clear();
//     parseAllEntries(newLog);
//   }
//   //----------------------------------------------------------------------------------------

//   void parseAllEntries(Uint8List fileData) {
//     const recordSize = 24; // was 24 for full struct
//     int count = fileData.length ~/ recordSize;

//     for (int i = 1; i < count; i++) {
//       int offset = i * recordSize;
//       ByteData bd = fileData.buffer.asByteData(
//         fileData.offsetInBytes + offset,
//         recordSize,
//       );

//       int timestamp = bd.getUint32(0, Endian.little);
//       double lat = bd.getFloat32(4, Endian.little);
//       double lon = bd.getFloat32(8, Endian.little);
//       int mph = bd.getUint16(12, Endian.little);
//       int rpm = bd.getUint16(14, Endian.little);
//       int tps = bd.getUint8(16);
//       int lambdaRaw = bd.getUint8(17);
//       int airBoxPressure = bd.getUint8(18); // probably sent in kpa
//       int airTemperature = bd.getUint8(19);
//       int coolantTemperature = bd.getUint8(20);
//       int oilPressure = bd.getUint8(21);
//       int bVoltage = bd.getUint8(22);
//       int spare = bd.getUint8(23);
//      // print(bVoltage);


//       double modMph = mph / 10.0; // convert to double
//       double lambdaDouble = lambdaRaw / 100.0; // convert to double
//       double afr = lambdaDouble * 14.7; // convert to AFR
//       double modAfr = double.parse(afr.toStringAsFixed(2));// limit to 2 decimal
//       double modBatteryVoltage = bVoltage / 10.0; // convert to double
//       double modAirBoxPressure =
//           airBoxPressure * 0.14503773773020923; // convert to psi
//       double roundedPressure =
//           double.parse(modAirBoxPressure.toStringAsFixed(2));
//       double modRpm = rpm.toDouble(); // convert to double
//       double modTps = tps.toDouble(); // convert to double

//      // print(modAfr);


//       // store or print them
//       //  print(
//       //      "#$i timestamp: $timestamp, lat: $lat,6, lng: $lon mph: $modMph, rpm: $rpm, tps: $tps, afr: $modAfr, airBoxPressure: $modAirBoxPressure, airTemperature: $airTemperature, coolantTemperature: $coolantTemperature, oilPressure: $oilPressure, bVoltage: $modBatteryVoltage");

//       allData.add({
//         'timestamp': timestamp,
//         'latitude': lat,
//         'longitude': lon,
//         'speed': modMph,
//         'rpm': rpm,
//         'modRpm': modRpm,
//         'tps': modTps,
//         'afr': modAfr,
//         'airboxPressure': roundedPressure,
//         'airTemperature': airTemperature,
//         'coolantTemperature': coolantTemperature,
//         'oilPressure': oilPressure,
//         'batteryVoltage': modBatteryVoltage,
//         'spare': spare,
//       });
//     }
//   }
// }




class DataLogProvider extends StateNotifier<Uint8List> {
  DataLogProvider() : super(Uint8List(0));

    Future<String> getFilePath(String fileName) async {
    Directory directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$fileName'; // Ensure the slash is correct
    return '${directory.path}/$fileName'; // Ensure the slash is correct
  }

    Future<void> writeToFile(Uint8List data, String fileName) async {
    final path = await getFilePath(fileName);
    print('Saving data to path: $path');
    print('Saving data to path: $path');
    final file = File(path);

    // Write the binary data to the file
    await file.writeAsBytes(data);
    print('Data written to file: $data');
    // Write the binary data to the file
    await file.writeAsBytes(data);
    print('Data written to file: $data');
  }

  void saveData(String fileName, WidgetRef ref) async {
    if (state.isEmpty) {
      print('No data to save.');
      return;
    }

    // Save the current state (Uint8List) to the file
    await writeToFile(state, fileName);

    if (state.isEmpty) {
      print('No data to save.');
      return;
    }

    // Save the current state (Uint8List) to the file
    await writeToFile(state, fileName);

    // Trigger the provider to update after saving
    ref.read(localFileListProvider.notifier).loadLocalFileList();
    print('Data saved to $fileName');
    print('Data saved to $fileName');
  }

  Future<void> deleteFile(String fileName, WidgetRef ref) async {
    try {
      // Get the directory where the file is stored
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';

      // Create a File instance for the file
      final file = File(filePath);

      // Check if the file exists, and delete it if it does
      if (await file.exists()) {
        await file.delete();
        print('File deleted.... $filePath');
      } else {
        print('File not found: $filePath');
      }
      // Trigger the provider to update after saving
      ref.read(localFileListProvider.notifier).loadLocalFileList();
      //.Load; // or update the relevant part of the state
    } catch (e) {
      print('Error deleting file: $e');
    }
  }

  double mapValue(
      double x, double inMin, double inMax, double outMin, double outMax) {
    return ((x - inMin) * (outMax - outMin) / (inMax - inMin)) + outMin;
  }
  //----------------------------------------------------------------------------------------

  final List<Map<String, dynamic>> allData = [];
  final Map<int, List<Map<String, dynamic>>> laps = {};
  int fastestLapNumber = 1;
  int fastestLapTime = 99999999;

  void setDatalog(Uint8List newLog) {
    state = newLog;
    allData.clear();
    laps.clear();
    parseAllEntries(newLog);
  }

  void parseAllEntries(Uint8List fileData) {
    const recordSize = 24;
    int count = fileData.length ~/ recordSize;
    int lapStartTime = 0;

    for (int i = 1; i < count; i++) {
      int offset = i * recordSize;
      ByteData bd = fileData.buffer.asByteData(
        fileData.offsetInBytes + offset,
        recordSize,
      );

      int timestamp = bd.getUint32(0, Endian.little);
      double lat = bd.getFloat32(4, Endian.little);
      double lon = bd.getFloat32(8, Endian.little);
      int mph = bd.getUint16(12, Endian.little);
      int rpm = bd.getUint16(14, Endian.little);
      int tps = bd.getUint8(16);
      int lambdaRaw = bd.getUint8(17);
      int airBoxPressure = bd.getUint8(18);
      int airTemperature = bd.getUint8(19);
      int coolantTemperature = bd.getUint8(20);
      int oilPressure = bd.getUint8(21);
      int bVoltage = bd.getUint8(22);
      int lap = bd.getUint8(23); // 'spare' as lap number

      double modMph = mph / 10.0;
      double afr = (lambdaRaw / 100.0) * 14.7;
      double modAfr = double.parse(afr.toStringAsFixed(2));
      double modBatteryVoltage = bVoltage / 10.0;
      double modAirBoxPressure =
          double.parse((airBoxPressure * 0.1450377).toStringAsFixed(2));

      final entry = {
        'timestamp': timestamp,
        'latitude': lat,
        'longitude': lon,
        'speed': modMph,
        'rpm': rpm.toDouble(),
        'tps': tps.toDouble(),
        'afr': modAfr,
        'airboxPressure': modAirBoxPressure,
        'airTemperature': airTemperature,
        'coolantTemperature': coolantTemperature,
        'oilPressure': oilPressure,
        'batteryVoltage': modBatteryVoltage,
        'lap': lap,
        'spare': 0, // Placeholder for spare field
      };

      allData.add(entry);
      // Update total laps count
      if (!laps.containsKey(lap)) {
        laps[lap] = [];
      }

      // Group entries by lap number
      laps.putIfAbsent(lap, () => []).add(entry);

    
     // Track lap times (but ignore lap 0 for fastest lap detection)
      if (laps[lap]!.length == 1) {
        lapStartTime = timestamp;
      } else {
        int lapTime = timestamp - lapStartTime;

        // Only update if lap number > 0
        if (lap > 0 && lapTime < fastestLapTime) {
          fastestLapTime = lapTime;
          fastestLapNumber = lap;
        }
      }

    }
  }

  List<Map<String, dynamic>> getLap(int lapNumber) {
    return laps[lapNumber] ?? [];
  }

  int getFastestLap() => fastestLapNumber;

  int getTotalNumberOfLaps() => laps.keys.length;
}

//final selectedLapProvider = StateProvider<int>((ref) => 1); // Default to lap 1

final selectedLapProvider = StateProvider<int>((ref) {
  final laps = ref.watch(dataLogProvider.notifier).laps;

  // Map of lap -> lap time (excluding lap 0 and the last lap)
  final lapTimes = {
    for (final lap in laps.keys)
      if (lap != 0 && laps[lap]!.length > 1 && lap != laps.keys.last)
        lap: laps[lap]!.last['timestamp'] - laps[lap]!.first['timestamp']
  };

  // Default to 0 if nothing valid
  if (lapTimes.isEmpty) return 0;

  // Return the lap with the shortest time
  return lapTimes.entries.reduce((a, b) => a.value < b.value ? a : b).key;
});



final dataLogProvider =
    StateNotifierProvider<DataLogProvider, Uint8List>((ref) {
  return DataLogProvider();
});
