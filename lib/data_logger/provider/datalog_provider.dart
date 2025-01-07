// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ble1/data_logger/provider/local_file_list_provider.dart';


class DataLogProvider extends StateNotifier<String> {
  // Parsed data state
  List<Map<String, dynamic>> gpsData = [];
  List<Map<String, dynamic>> temperatureData = [];
  List<Map<String, dynamic>> rpmData = [];

//List<GPSPoint> gpsData = [];

  DataLogProvider() : super('');

  void setDatalog(String newLog) {
    state = newLog;
    parseDataString(state);
  }

  Future<String> getFilePath(String fileName) async {
    // Get the application's document directory
    Directory directory = await getApplicationDocumentsDirectory();
    return '${directory.path}$fileName';
  }

  Future<void> writeToFile(String data, String fileName) async {
    final path = await getFilePath(fileName);
    print('The Path: $path');
    final file = File(path);

    // Write the data to the file
    await file.writeAsString(data);
    // print("Data written to file: $data");
  }

  void saveData(String fileName, WidgetRef ref) async {
    await writeToFile(state, '/$fileName');
    // Trigger the provider to update after saving
    ref.read(localFileListProvider.notifier).loadLocalFileList();
    //.Load; // or update the relevant part of the state
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

  void parseDataString(String data) {
    List<String> lines = data.split(','); // Split the data by the commas
    gpsData.clear(); // Clear previous data
    temperatureData.clear(); // Clear previous data
    rpmData.clear(); // Clear previous data

    List<double>? lastParsed;

    // Iterate through the lines to parse data
    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim(); // Remove extra whitespace

      if (line.startsWith('G') && i + 4 < lines.length) {
        // Check if it's a GPS record (lat, lng, speed, timestamp)
        try {
          double lat = double.parse(lines[i + 1].trim());
          double lng = double.parse(lines[i + 2].trim());
          double speed = double.parse(lines[i + 3].trim());
          int timestamp = int.parse(lines[i + 4].trim());

          List<double> currentParsed = [lat, lng];

          // Check if the current point is (0, 0) and skip it if so
          if (lat == 0.000000 && lng == 0.000000) {
            print("Skipping invalid GPS point (0, 0) at index $i");
            continue; // Skip to the next iteration
          }

          // Initialize lastParsed if it's null (on first iteration)
          if (lastParsed == null) {
            lastParsed = currentParsed;
            gpsData.add({
              'latitude': lat,
              'longitude': lng,
              'speed': speed,
              'timestamp': timestamp,
            });
            continue;
          }

          // Check if this set of values is the same as the last one
          double latDiff = (lat - lastParsed[0]).abs();
          double lonDiff = (lng - lastParsed[1]).abs();

          // Set threshold value
          double threshold =
              1.0; // Make adjustable in the page settings one day?

          // If the differences exceed the threshold, skip this point
          if (latDiff > threshold || lonDiff > threshold) {
            print(
                "Skipping point due to threshold exceedance: Latitude diff = $latDiff, Longitude diff = $lonDiff");
            continue;
          }

          if (currentParsed != lastParsed) {
            // Add valid data to gpsData
            gpsData.add({
              'latitude': lat,
              'longitude': lng,
              'speed': speed,
              'timestamp': timestamp,
            });
            lastParsed = currentParsed;
          }
        } catch (e) {
          print("Error parsing GPS data at index $i: $e");
        }


        //---------------------------------------------------------------------------------------------------------------------------------------
      } else if (line.startsWith('ET') && i + 2 < lines.length) {
        // Check if it's a TEMP record (temperature, timestamp)
        double temperature = double.parse(lines[i + 1]);
        int timestamp = int.parse(lines[i + 2]);
        // print(timestamp);

        temperatureData.add({
          'temperature': temperature,
          'timestamp': timestamp,
        });

        i += 2; // Skip the next 2 entries for the current RPM data
      } else if (line.startsWith('R') && i + 2 < lines.length) {
        // Check if it's a RPM record (rpm, timestamp)
        double rpm = double.parse(lines[i + 1]);
        int timestamp = int.parse(lines[i + 2]);
        // print(timestamp);

        rpmData.add({
          'rpm': rpm,
          'timestamp': timestamp,
        });

        i += 2; // Skip the next 2 entries for the current TEMP data
      }
    }
  }
}

final dataLogProvider = StateNotifierProvider<DataLogProvider, String>((ref) {
  return DataLogProvider();
});
