import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    int colonPos =
        fileName.indexOf(':'); // Locate the time part by finding the colon

    String venue = fileName.substring(
        colonPos - 12, colonPos - 10); // Extract venue initials
    String year =
        fileName.substring(colonPos - 6, colonPos - 2); // Extract year (2024)
    String month =
        fileName.substring(colonPos - 8, colonPos - 6); // Extract month (10)
    String day = fileName.substring(colonPos - 10, colonPos - 8); // Extract day
    String time =
        fileName.substring(colonPos - 2, colonPos + 3); // Extract time

    // Handle special cases for venue
    if (venue == 'ho') {
      venue = 'Home';
    } else if (venue == 'wo') {
      venue = 'Work';
    } else if (venue == 'na') {
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
    state = '$venue, $day/$month/$year $time';
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
