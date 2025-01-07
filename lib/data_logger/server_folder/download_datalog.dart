// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:async';
import 'dart:convert'; // <-- Import this for utf8.encode
import 'package:ble1/data_logger/log_viewer/log_viewer_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ble1/data_logger/provider/datalog_provider.dart';
import 'package:ble1/data_logger/provider/filename_provider.dart';

class FileReceiver {
  List<int> fileData = [];

  // Append a chunk of data to fileData
  void addData(List<int> chunk) {
    fileData.addAll(chunk);
  }
}

//-----------------------------------------------------------------------------------------

class DownloadDataLog extends ConsumerStatefulWidget {
  final BluetoothCharacteristic characteristic;
  final int fileSize;
  final String fileName;

  const DownloadDataLog(
      {super.key,
      required this.characteristic,
      required this.fileSize,
      required this.fileName});

  @override
  ConsumerState<DownloadDataLog> createState() => _DownloadDataLogState();
}

class _DownloadDataLogState extends ConsumerState<DownloadDataLog> {
  FileReceiver fileReceiver = FileReceiver();
  bool isTransferStarted = false;
  bool isRequestSent = false;
  bool isLoading = false; // Add this for showing the progress indicator
  int bytesReceived = 0; // Track the total bytes received
  StreamSubscription<List<int>>? subscription;

  String fileContents =
      "Waiting for data..."; // Add a state variable to store the file contents

  @override
  void initState() {
    super.initState();

    startLargeFileTransfer(widget.characteristic);
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  Future<void> startLargeFileTransfer(
    BluetoothCharacteristic c,
  ) async {
    try {
      setState(() {
        isLoading = true;
      });

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

      subscription = c.onValueReceived.listen(
        (value) async {
          setState(() {
            bytesReceived += value
                .length; // Each time receive data, add the length to bytesReceived
          });

          // Clean the received data to remove null characters and extra spaces
          String receivedData =
              utf8.decode(value).replaceAll('\u0000', '').trim();
          print("Received cleaned data chunk: '$receivedData'");

          if (!isTransferStarted) {
            isTransferStarted = true;
            print("Large file transfer started");
          }

          // If the transfer is complete, stop
          if (receivedData == "END") {
            print("File transfer complete");
            //   fileReceiver.processFileData();

            ref.read(dataLogProvider.notifier).setDatalog(utf8.decode(
                fileReceiver.fileData)); // pass the data to the provider
            ref.read(filenameProvider.notifier).setFileName(widget.fileName);// pass file name to the file name formatter(display in bottom of each log viewer screen)
          
            setState(() {
              // fileContents = utf8.decode(fileReceiver.fileData);
              isLoading =
                  false; // Hide the progress indicator when transfer is complete?

              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => //DeviceScreen(device: device)
                      LogViewerFrame(
                    // datalog: ref.read(dataLogProvider),
                    fileName: widget.fileName,
                  ),
                ),
              );
            });

            isTransferStarted = false;
            isRequestSent = false;

            return;
          }

          // Add received data to fileReceiver
          fileReceiver.addData(value);
          print("Processed chunk of size: ${value.length}");

          // After processing the chunk, send a request for the next chunk
          await _requestNextChunk(c);
        },
        onError: (error) {
          print("Error receiving data: $error");
          setState(() {
            isLoading = false; // Hide the progress indicator on error
          });
        },
        onDone: () {
          print("Data stream closed");
          setState(() {
            isLoading = false;
          });
        },
      );

      c.device.cancelWhenDisconnected(subscription!);

      if (!isRequestSent) {
        await _sendGetLargeFileRequest(c);
      }
    } catch (e) {
      print("Error in startLargeFileTransfer: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _sendGetLargeFileRequest(BluetoothCharacteristic c) async {
    const maxRetries = 3;
    for (int i = 0; i < maxRetries; i++) {
      try {
        List<int> request = utf8.encode("GET_LARGE_FILE");
        // List<int> request = utf8.encode("SEND_FILE_DETAILS");
        print(request);

        await c.write(request, withoutResponse: false);
        print("Sent GET_LARGE_FILE request to ESP32");
        isRequestSent = true;
        break;
      } catch (e) {
        print("Error sending GET_LARGE_FILE request (attempt ${i + 1}): $e");
        if (i == maxRetries - 1) {
          rethrow;
        }
        await Future.delayed(const Duration(seconds: 5));
      }
    }
  }

// Function to request the next chunk after receiving one
  Future<void> _requestNextChunk(BluetoothCharacteristic c) async {
    String request = "NEXT_CHUNK";
    await c.write(utf8.encode(request)); // Send the request for the next chunk
    print("Requested next chunk from ESP32");
  }

  @override
  Widget build(BuildContext context) {
    //  final datalog = ref.watch(dataLogProvider);

    double progress = (bytesReceived / widget.fileSize).clamp(0.0, 1.0);
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Download'),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 200,
          ), // just added to move the progress indicator down
          if (isLoading)
            SizedBox(
              width:
                  500, // constrain the lenght of it change to media query later
              child: SizedBox(
                height: 20, // set how thick it is
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.black87,
                  color: Colors.white,
                ),
              ),
            ), // Show determinate progress bar

          const Expanded(
            child: Center(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Progress: ${(progress * 100).toStringAsFixed(2)}%', // Show progress percentage
              style: const TextStyle(color: Colors.white, fontSize: 30),
            ),
          ),
        ],
      ),
    );
  }
}
