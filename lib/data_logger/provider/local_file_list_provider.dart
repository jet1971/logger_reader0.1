import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class LocalFileListNotifier extends StateNotifier<List<String>> {
  LocalFileListNotifier() : super([]);

  List<String> fileList = [];

  void loadLocalFileList() async {
    try {
      // Get the path to the documents directory
      final directory = await getApplicationDocumentsDirectory();
      final dir = Directory(directory.path);

      // Check if the directory exists
      if (await dir.exists()) {
        // List the files in the directory
        List<FileSystemEntity> files = dir.listSync();

        // Filter and add file paths to the list

        fileList = files
            .whereType<File>() // Filter only files
            .map((file) => file.path)
            .toList();

        // Sort the list based on date information parsed from filenames
        fileList.sort((a, b) {
          DateTime dateA = _parseDateFromFilename(a);
          DateTime dateB = _parseDateFromFilename(b);
          return dateB.compareTo(dateA); // Sort descending (most recent first)
        });

        setLocalFileList(fileList);
        
      } else {
        print("Directory does not exist.");
      }
    } catch (e) {
      print("Error listing files: $e");
    }
  }

  // Function to set the file list
  void setLocalFileList(List<String> newList) {
    state = newList;
  }

  DateTime _parseDateFromFilename(String fileName) {
    // Assuming filename is in the format "yyyyMMdd:HHmmss.txt" its not its this //wo0212202418:27.txt so parsed first
    try {
      int colonPos = fileName.indexOf(':');

      String year =
          fileName.substring(colonPos - 6, colonPos - 2); // Extract year (2024)
      String month =
          fileName.substring(colonPos - 8, colonPos - 6); // Extract month (10)
      String day =
          fileName.substring(colonPos - 10, colonPos - 8); // Extract day

      String datePart = year + month + day;
      String hour = fileName.substring(colonPos - 2, colonPos + 0);
      String mins = fileName.substring(colonPos + 1, colonPos + 3);
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
  void addFile(String file) {
    state = [...state, file];
  }

  // Delete a file by index
  void deleteFile(int index) {
    if (index >= 0 && index < state.length) {
      final updatedList = List<String>.from(state);
      updatedList.removeAt(index);
      state = updatedList;
    }
  }
}

final localFileListProvider =
    StateNotifierProvider<LocalFileListNotifier, List<String>>((ref) {
  return LocalFileListNotifier();
});
