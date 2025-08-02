import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

String venue = 'Venue N/A';

class FilenameProvider extends StateNotifier<String?> {
  // State to hold the file name
  String? currentFileName;

  // Parsed filename components
  Map<String, String?> parsedFileName = {};

  FilenameProvider() : super('');

  // Method to set and parse the file name
  void setFileName(String fileName) {
    state = fileName;
    currentFileName = fileName;
    parseFilename(fileName);
  }

  // Method to parse the filename and store results
  void parseFilename(String fileName) {
    // Find positions based on expected format

    // int colonPos =
    //     fileName.indexOf(':'); // Locate the time part by finding the colon

    // int txtPos =
    //     fileName.indexOf('.txt'); // Locate the end of the filename by finding '.txt'

    // int colonPos =
    //     fileName.indexOf(':'); // Locate the time part by finding the colon

    int txtPos = fileName
        .indexOf('.txt'); // Locate the end of the filename by finding '.txt'

    String venueCode =
        fileName.substring(txtPos - 26, txtPos - 25); // Extract venue initials
    String year = fileName.substring(txtPos - 4, txtPos); // Extract year (2024)
    fileName.substring(txtPos - 4, txtPos); // Extract year (2024)
    String month =
        fileName.substring(txtPos - 6, txtPos - 4); // Extract month (10)
    // String day = fileName.substring(txtPos - 6, txtPos - 4); // Extract day
    fileName.substring(txtPos - 6, txtPos - 4); // Extract month (10)
    String day = fileName.substring(txtPos - 6, txtPos - 4); // Extract day
    String time = fileName.substring(txtPos - 12, txtPos - 8); // Extract time
    fileName.substring(txtPos - 12, txtPos - 8); // Extract time

    // // Handle special cases for venue
    // if (venue == 'ho') {
    //   venue = 'Home';
    // } else if (venue == '1') {
    //   venue = 'Work';
    // } else if (venue == '0') {
    //   venue = 'Venue N/A';
    // }

    print('venueCode: $venueCode');

    if (venue == "1") {
      venue = 'Work';
    } else if (venue == "2") {
      venue = 'Home';
    } else if (venue == "3") {
      venue = 'Aintree';
    } else if (venue == "4") {
      venue = 'Services';
    } else if (venue == "5") {
      venue = 'Cadwell';
    } else if (venue == "6") {
      venue = 'Oulton';
    } else if (venue == "7") {
      venue = 'IOM';
    } else if (venue == "8") {
      venue = 'Venue N/A';
    } else if (venue == "9") {
      venue = 'Venue N/A';
    } else if (venue == "0") {
      venue = 'Venue N/A';
    }

    // Add parsed data to parsedFileName map
    parsedFileName = {
      'venue': venue,
      'year': year,
      'month': month,
      'day': day,
      'time': time,
    };

    // Optionally, update state with parsed data in a more readable format
    state = '$venueCode, $day/$month/$year $time';
  }

  // Get parsed file components
  Map<String, String?> getParsedFileName() {
    return parsedFileName;
  }
}

// Define the provider for accessing FilenameProvider
final filenameProvider =
    StateNotifierProvider<FilenameProvider, String?>((ref) {
  return FilenameProvider();
});
