
import 'package:flutter_riverpod/flutter_riverpod.dart';

//String venue = 'Venue N/Ass';

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

    String venueCode = fileName.substring(txtPos - 26, txtPos - 25); // Extract venue initials
    String year = fileName.substring(txtPos - 4, txtPos); // Extract year (2024)
   // fileName.substring(txtPos - 4, txtPos); // Extract year (2024)
    String month = fileName.substring(txtPos - 6, txtPos - 4); // Extract month (10)
    // String day = fileName.substring(txtPos - 6, txtPos - 4); // Extract day
   // fileName.substring(txtPos - 6, txtPos - 4); // Extract month (10)
    String day = fileName.substring(txtPos - 8, txtPos - 6); // Extract day
    String hour = fileName.substring(txtPos - 12, txtPos - 10); // Extract time
    String mins = fileName.substring(txtPos - 10, txtPos - 8); // Extract time
    String time = '$hour$mins'; // Combine hour and minutes
    // String time = fileName.substring(txtPos - 12, txtPos - 8); // Extract time
    //fileName.substring(txtPos - 12, txtPos - 8); // Extract time

 

    // "4BK31010040400213731072025.txt" example file name
String venue = 'Venue N/A'; // Default value for venue

    if (venueCode == "1") {
      venue = 'Work';
    } else if (venueCode == "2") {
      venue = 'Home';
    } else if (venueCode == "3") {
      venue = 'Aintree';
    } else if (venueCode == "4") {
      venue = 'Services';
    } else if (venueCode == "5") {
      venue = 'Cadwell';
    } else if (venueCode == "6") {
      venue = 'Oulton';
    } else if (venueCode == "7") {
      venue = 'IOM';
    } else if (venueCode == "8") {
      venue = 'Venue N/A';
    } else if (venueCode == "9") {
      venue = 'Venue N/A';
    } else if (venueCode == "0") {
      venue = 'Venue N/A';
    }

    // Add parsed data to parsedFileName map
    parsedFileName = {
      'venue': venue,
      'year': year,
      'month': month,
      'day': day,
      'time': time,
      'hour': hour,
      'mins': mins,
    };

    // Optionally, update state with parsed data in a more readable format
   // state = '$venue, $day/$month/$year $time';
   state = '${parsedFileName['venue']!}, ${parsedFileName['day']!}/${parsedFileName['month']!}/${parsedFileName['year']!} ${parsedFileName['hour']!}:${parsedFileName['mins']!}';
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
