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
      print("Directory path: ${dir.path}");

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
      int txtPos = fileName.indexOf('.txt');

      String year =
          fileName.substring(txtPos - 4, txtPos); // Extract year (2024)
      String month =
          fileName.substring(txtPos - 6, txtPos - 4); // Extract month (10)
      String day =
          fileName.substring(txtPos - 8, txtPos - 6); // Extract day

      String datePart = year + month + day;
      String hour = fileName.substring(txtPos - 12, txtPos - 10);
      String mins = fileName.substring(txtPos - 10, txtPos - 8);
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
