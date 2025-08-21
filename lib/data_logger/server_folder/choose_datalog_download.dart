// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:ble1/data_logger/server_folder/server_file_list.dart';
import 'package:ble1/data_logger/models/server_file_details.dart';
import 'package:ble1/data_logger/server_folder/file_management.dart';
import 'package:ble1/data_logger/provider/server_file_list_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



class FileReceiver {
  StringBuffer jsonBuffer = StringBuffer(); // Buffer to accumulate JSON chunks

  void onDataReceived(String jsonString, WidgetRef ref) {
    try {
      print("# 5, Raw JSON String: $jsonString"); // Print the raw JSON string

      // Parse the received JSON string into a map
      Map<String, dynamic> jsonData = jsonDecode(jsonString);

      // Extract the array of files
      List<dynamic> filesArray = jsonData['files'];

      // Create a list to hold new files
      List<ServerFileDetails> newList = [];

      // Iterate over the files array and create ServerFileDetails objects
      for (var fileData in filesArray) {
        ServerFileDetails fileDetails = ServerFileDetails.fromJson(fileData);
        newList.add(fileDetails);
      }

      // Update the provider with the new file list
      ref.read(fileListProvider.notifier).setServerFileList(newList);
      print("# 6, Received and parsed files: ${newList.length}");
    } catch (e) {
      print('# 9, Error parsing JSON: $e');
    }
  }
}

class ChooseLogDownload extends ConsumerStatefulWidget {
  final BluetoothCharacteristic readFileDetailCharacteristic;
  final BluetoothCharacteristic deleteFileCharacteristic;
  final BluetoothCharacteristic downloadFileCharacteristic;

  const ChooseLogDownload(
      {super.key,
      required this.readFileDetailCharacteristic,
      required this.deleteFileCharacteristic,
      required this.downloadFileCharacteristic});

  @override
  ConsumerState<ChooseLogDownload> createState() => _ChooseLogDownloadState();
}

class _ChooseLogDownloadState extends ConsumerState<ChooseLogDownload> {
  final GlobalKey<AnimatedListState> _listKey =
      GlobalKey<AnimatedListState>(); // Key to control AnimatedList

  late FileManagement fileManagement;
  FileReceiver fileReceiver = FileReceiver();
  bool isTransferStarted = false;
  bool isRequestSent = false;
  StreamSubscription<List<int>>? subscription;
  // Add a state variable to store the file contents
  String fileContents = "Waiting for data...";

  @override
  void initState() {
    super.initState();

    fileManagement = FileManagement(
        widget.deleteFileCharacteristic,
        widget
            .downloadFileCharacteristic); // Initialize fileManagement inside initState, where widget properties are accessible

    startFileTransfer(widget.readFileDetailCharacteristic);
  }

  @override
  void dispose() {
    subscription?.cancel(); // Cancel the BLE stream subscription
    super.dispose();
  }

  Future<void> deleteFile(ServerFileDetails file, int index) async {
  
    await fileManagement.deleteFile(file.fileName); // Delete file on the server

    // Call deleteFile method on the notifier to update the provider's state
    ref.read(fileListProvider.notifier).deleteFile(index);

    // Remove the file from the AnimatedList with animation
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildDeletedItem(file, animation),
      duration: const Duration(milliseconds: 300),
    );
    print("File deleted from server and removed from list");
  }

  // Build a deleted item with animation
  Widget _buildDeletedItem(
      ServerFileDetails file, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: Card(
        child: ListTile(
          title: Text(file.fileName),
          subtitle: Text("Size: ${file.fileSize} bytes"),
        ),
      ),
    );
  }

  Future<void> startFileTransfer(BluetoothCharacteristic c) async {
    Timer? timeoutTimer;
    try {
      // Request MTU only on Android
      if (Platform.isAndroid) {
        int desiredMtu = 512;
        int mtu = await c.device.requestMtu(desiredMtu);
        print("Requested MTU: $desiredMtu, Negotiated MTU: $mtu");
      } else {
        print("Skipping MTU request, not supported on non-Android platforms.");
      }

      await c.setNotifyValue(true);
      print("Subscribed to notifications");

      // Prepare to accumulate chunks
      StringBuffer jsonStringBuffer = StringBuffer();

      subscription = c.onValueReceived.listen(
        (value) async {
          // Reset the timeout timer on receiving any data

          // Convert the incoming byte data to a UTF-8 string
          String receivedData =
              utf8.decode(value).replaceAll('\u0000', '').trim();

          print("# 1, Received cleaned data chunk: '$receivedData'");

          if (!isTransferStarted) {
            isTransferStarted = true;
            print("File transfer started");
            timeoutTimer?.cancel();
          }

          timeoutTimer = Timer(const Duration(seconds: 1), () {
            print("Timeout reached, attempting to parse JSON");
            print("File transfer complete");

            // Process the complete JSON data
            String completeJsonString = jsonStringBuffer.toString();
            print("# 2, Final JSON String: $completeJsonString");

            // Reset state
            isTransferStarted = false;
            isRequestSent = false;

            // Clear the buffer and return
            jsonStringBuffer.clear();
            return;
          });

          // Check if transfer is complete (received "END" signal)
          if (receivedData == "END") {
            print("# 3, File transfer complete");

            // Process the complete JSON data
            String completeJsonString = jsonStringBuffer.toString();
            print("# 4, Final JSON String: $completeJsonString");
            fileReceiver.onDataReceived(
                completeJsonString, ref); // Pass ref to update provider

            // Reset state
            isTransferStarted = false;
            isRequestSent = false;

            // Clear the buffer and return
            jsonStringBuffer
                .clear(); //////////////////////////////////////////////////////////////////////////////////////////////////
            return;
          }

          // Accumulate received data chunks into the buffer
          jsonStringBuffer.write(receivedData);

          // After processing the chunk, request the next chunk

          await _requestNextChunk(
              c); //------------------------------------------------
        },
        onError: (error) {
          print("Error receiving data: $error");
        },
        onDone: () {
          print("Data stream closed");
        },
      );

      c.device.cancelWhenDisconnected(subscription!);

      if (!isRequestSent) {
        await _sendGetFileDetailsRequest(c);
      }
    } catch (e) {
      print("Error in startFileTransfer: $e");
    }
  }

  Future<void> _sendGetFileDetailsRequest(BluetoothCharacteristic c) async {
    const maxRetries = 3;
    for (int i = 0; i < maxRetries; i++) {
      try {
        List<int> request = utf8.encode("SEND_FILE_DETAILS");
        print(request);

        await c.write(request, withoutResponse: false);
        print("Sent SEND_FILE_DETAILS request to ESP32");
        isRequestSent = true;
        break;
      } catch (e) {
        print("Error sending SEND_FILE_DETAILS request (attempt ${i + 1}): $e");
        if (i == maxRetries - 1) {
          rethrow;
        }
        await Future.delayed(const Duration(seconds: 5));
      }
    }
  }

  // Function to request the next chunk after receiving one
  Future<void> _requestNextChunk(BluetoothCharacteristic c) async {
    String request = "MORE_FILE_DETAILS";
    await c.write(utf8.encode(request)); // Send the request for the next chunk
    print("# 8,  Requested more file details from ESP32");
  }

  @override
  Widget build(BuildContext context) {
    final serverFileList = ref.watch(fileListProvider);

    return Scaffold(
        appBar: AppBar(
          
          title: const Text(
            'Files stored on logger',
            style: TextStyle(
              color: Color.fromARGB(255, 249, 249, 250),
            ),
          ),
          centerTitle: true,
          actions: const [
            SizedBox(
              width: 200,
              child: Text(
                'Logger storage used: Soon... %',
                //  serverFileListProvided[0].fastestLap, // dicking about
              ),
            )
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                  child: ServerFileList(
                downloadFileFunction: (fileName, context, fileSize) {
                  fileManagement.downloadFile(fileName, fileSize,
                      context); // I have no idea how I did this...
                },

                data: serverFileList, // Use provider data
                deleteFunction: deleteFile,
                listKey: _listKey, // Pass the AnimatedList key
              ))
            ],
          ),
        ));
  }
}
