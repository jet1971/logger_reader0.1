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
    // Assuming filename is in the format "yyyyMMdd:HHmmss.txt" its not its a ServerFileDetails object so do some stuff below
    try {
      String datePart = fileName.year + fileName.month + fileName.day;

      String time = fileName.time;

      int colonPos = time.indexOf(':');

      String hour = time.substring(colonPos - 2, colonPos + 0);

      String mins = time.substring(colonPos + 1, colonPos + 3);

      String timePart = hour + mins;

      return DateTime.parse("$datePart $timePart");
    } catch (e) {
      return DateTime
          .now(); // In case of invalid filename, use the current date
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
