// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:ble1/data_logger/server_folder/download_datalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class FileManagement {
  final BluetoothCharacteristic deleteFileCharacteristic,
      downloadFileCharacteristic;
  FileManagement(
      this.deleteFileCharacteristic, this.downloadFileCharacteristic);

  // Function to delete a file
  Future<void> deleteFile(String fileName) async {
    // Convert the file name to bytes and write it to the characteristic
    List<int> fileNameBytes = utf8.encode(fileName);
    await deleteFileCharacteristic.write(fileNameBytes);
    print("File delete request sent: $fileName");
  }

  Future<void> downloadFile(String fileName, int fileSize, context) async {
    // Convert the file name to bytes and write it to the characteristic
    List<int> fileNameBytes = utf8.encode(fileName);
    await downloadFileCharacteristic.write(fileNameBytes);
    print("Download request sent: $fileName");
     Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DownloadDataLog(
          characteristic: downloadFileCharacteristic,
          fileSize: fileSize,
          fileName: fileName,
        ),
      ),
    );
  }
}
