// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:async';
import 'dart:convert'; // <-- Import this for utf8.encode
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

//import "../utils/snackbar.dart";
import "descriptor_tile.dart";

//------------------------------------------------------------------------------------------
// This class handles receiving data in chunks and storing it in fileData

class FileReceiver {
  List<int> fileData = [];

  // Append a chunk of data to fileData
  void addData(List<int> chunk) {
    fileData.addAll(chunk);
  }

  // Optionally process the data when the transfer is complete
  void processFileData() {
    if (fileData.isNotEmpty) {
      String fileContents = utf8.decode(fileData);
      print("Full File Received: $fileContents");
    } else {
      print("No data received.");
    }
  }
}

//-----------------------------------------------------------------------------------------

class CharacteristicTile extends StatefulWidget {
  final BluetoothCharacteristic characteristic;
  final List<DescriptorTile> descriptorTiles;

  const CharacteristicTile({
    super.key,
    required this.characteristic,
    required this.descriptorTiles,
  });

  @override
  State<CharacteristicTile> createState() => _CharacteristicTileState();
}

class _CharacteristicTileState extends State<CharacteristicTile> {

  
  
  FileReceiver fileReceiver = FileReceiver();
  bool isTransferStarted = false;
  bool isRequestSent = false;
  StreamSubscription<List<int>>? subscription;
  // Add a state variable to store the file contents
  String fileContents = "Waiting for data...";

  @override
  void initState() {
    super.initState();
    // Add any other initialization logic here
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  Future<void> startLargeFileTransfer(BluetoothCharacteristic c) async {
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

      subscription = c.onValueReceived.listen(
        (value) async {
       
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
            fileReceiver.processFileData();

            setState(() {
              fileContents = utf8.decode(fileReceiver.fileData);
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
        },
        onDone: () {
          print("Data stream closed");
        },
      );

      c.device.cancelWhenDisconnected(subscription!);

      if (!isRequestSent) {
        await _sendGetLargeFileRequest(c);
      }
    } catch (e) {
      print("Error in startLargeFileTransfer: $e");
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


// Build the Write button
  Widget buildWriteButton(BuildContext context) {
    // bool withoutResp = widget.characteristic.properties.writeWithoutResponse;
    return TextButton(
      child: const Text("Get Data Log"),
      onPressed: () {
        //    sendAck =
        //      true; // needed so it dosn't keep sending ACK when tranfer complete
        // Call the function to start the large file transfer when the button is pressed
        startLargeFileTransfer(widget.characteristic);
        print('Pressed at buildButton');
        // if (mounted) {
        //   setState(() {});
        // }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: ListTile(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Data = $fileContents'),
          ],
        ),

        subtitle: buildWriteButton(context), // Use the write button here
        contentPadding: const EdgeInsets.all(0.0),
      ),
    );
  }
}
