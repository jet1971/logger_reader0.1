import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ble1/data_logger/models/server_file_details.dart';

class FileListNotifier extends StateNotifier<List<ServerFileDetails>> {
  FileListNotifier() : super([]);

  // Function to set the file list
  void setServerFileList(List<ServerFileDetails> newList) {
    // Sort the list based on date information parsed from filenames
    newList.sort((a, b) {
      DateTime dateA = _parseDateFromFilename(a);
      DateTime dateB = _parseDateFromFilename(b);
      return dateB.compareTo(dateA); // Sort descending (most recent first)
    });
    state = newList;
  }

  DateTime _parseDateFromFilename(ServerFileDetails fileName) {
    try {
      // Combine year, month, and day to form the date part
      String datePart = fileName.year + fileName.month + fileName.day;

      // Extract the time part (hour and minutes)
      String time = fileName.time;

      // `time` is in the format "HHmm"
      String hour = time.substring(0, 2); // First 2 characters are the hour
      String mins = time.substring(2, 4); // Characters 2-4 are the minutes
      //String secs = time.substring(6, 8); // Characters 6-7 are the seconds

      // Combine date and time into a full DateTime string
      return DateTime.parse("$datePart $hour$mins");
    } catch (e) {
      // In case of invalid filename, return the current date and time
      return DateTime.now();
    }
  }

  // Function to clear the list
  void clearList() {
    state = [];
  }

  // Add a file
  void addFile(ServerFileDetails file) {
    state = [...state, file];
  }

  // Delete a file by index
  void deleteFile(int index) {
    if (index >= 0 && index < state.length) {
      final updatedList = List<ServerFileDetails>.from(state);
      updatedList.removeAt(index);
      state = updatedList;
    }
  }
}

final fileListProvider =
    StateNotifierProvider<FileListNotifier, List<ServerFileDetails>>((ref) {
  return FileListNotifier();
});
