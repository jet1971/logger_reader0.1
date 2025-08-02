import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ble1/data_logger/models/server_file_details.dart';
import 'package:ble1/data_logger/provider/datalog_provider.dart';
import 'package:ble1/data_logger/provider/local_file_list_provider.dart';
import 'package:ble1/data_logger/log_viewer/log_viewer_frame.dart';
import 'package:ble1/data_logger/provider/filename_provider.dart';

class ServerItemInfo extends ConsumerStatefulWidget {
  const ServerItemInfo({
    super.key,
    required this.serverInfo,
    required this.deleteFunction,
    required this.downloadFileFunction,
  });

  final ServerFileDetails serverInfo;
  final VoidCallback deleteFunction; // Update to match VoidCallback signature
  final VoidCallback downloadFileFunction;

  @override
  ConsumerState<ServerItemInfo> createState() => _ServerItemInfoState();
}

class _ServerItemInfoState extends ConsumerState<ServerItemInfo> {
  bool saved = false;
  Uint8List fileContents = Uint8List(0);

  @override
  void initState() {
    super.initState();
    // Load the local file list when the widget is initialized
    Future.microtask(() {
      ref.watch(localFileListProvider.notifier).loadLocalFileList();
      final providerLocalFileList = ref.watch(localFileListProvider);

      saved = providerLocalFileList
          .map((filePath) => path.basename(filePath))
          .contains(widget.serverInfo.fileName);
    });
  }

  Future<void> loadData(String fileName, WidgetRef ref) async {
    try {
      // Get the full file path
      final directory = await getApplicationDocumentsDirectory();
      final fullPath = '${directory.path}/$fileName';

      // Read the file as bytes
      fileContents = await File(fullPath).readAsBytes();

      // Update the provider with the new data
      ref.read(dataLogProvider.notifier).setDatalog(fileContents);
      ref.read(filenameProvider.notifier).setFileName(fileName);

      print("Loaded data: $fileContents");
    } catch (e) {
      print("Error loading file: $e");
    }
  }

  //-----------------------------------------------------------------------------------------------------

  String formatMilliseconds(int milliseconds) {
    // Calculate minutes, seconds, and remaining milliseconds
    int minutes = (milliseconds ~/ 60000); // 1 minute = 60000 ms
    int seconds = ((milliseconds % 60000) ~/ 1000);
    int remainingMilliseconds = (milliseconds % 1000);

    // Format the time as 'minutes:seconds.milliseconds'
    String formattedTime =
        '$minutes:${seconds.toString().padLeft(2, '0')}.${remainingMilliseconds.toString().padLeft(3, '0')}';

    return formattedTime;
  }

//-----------------------------------------------------------------------------------------------------
 String formatTime(String time) {
    String hour = time.substring(0, 2); // First 2 characters are the hour
    String mins = time.substring(2, 4); // Characters 2-4 are the minutes
    return '$hour:$mins';
  }
//-----------------------------------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {

    var screenSize = MediaQuery.of(context).size;

    final providerLocalFileList = ref.watch(localFileListProvider);

    // Update the `saved` status based on the current provider state
    saved = providerLocalFileList
        .map((filePath) => path.basename(filePath))
        .contains(widget.serverInfo.fileName);

    Future<void> showMyDialog() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Confirm Delete',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                    'Warning! This will remove this file from your Datalogger',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    child: const Text(
                      'CANCEL',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: const Text(
                      'CONFIRM',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      widget.deleteFunction(); // Call the delete function
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'FILE DELETED!',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          duration: Duration(milliseconds: 1000),
                          backgroundColor: Colors.red,
                        ),
                      );
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          );
        },
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          children: [
            screenSize.width > 670
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 150,
                        child: Text(
                          widget.serverInfo.venue,
                          style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            widget.serverInfo.day,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          const Text(
                            "/",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            widget.serverInfo.month,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          const Text(
                            "/",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            widget.serverInfo.year,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )

                //                  Screeen less than 860px
                //-------------------------------------------------------------------------------------
                : SizedBox(
                    width: 100, // used to keep track name aligned
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.serverInfo.venue,
                          style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Text(
                              widget.serverInfo.day,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            const Text(
                              "/",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              widget.serverInfo.month,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            const Text(
                              "/",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              widget.serverInfo.year,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
            const SizedBox(
              width: 15,
            ),
                SizedBox(
              width: 70,
              child: Text(
                widget.serverInfo.id,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
            SizedBox(
              width: 70,
              child: Text(
                formatTime(widget.serverInfo.time),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
            const Text(
              'Fastest Lap:  ',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(
              width: 120,
              child: Text(
                formatMilliseconds(int.tryParse(widget.serverInfo.fastestLap) ?? 0),
               
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.normal),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            const Text(
              'File size: ',
              style: TextStyle(color: Colors.white),
            ),
            Text(
              widget.serverInfo.fileSize,
              style: const TextStyle(color: Colors.white),
            ),
            const Spacer(),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.green),
              child: saved
                  ? const Text(
                      'SAVED / OPEN',
                    )
                  : const Text(
                      'DOWNLOAD',
                      style: TextStyle(color: Colors.blue),
                    ),
              onPressed: () async {
                if (saved) {
                  // Load data before navigation
                  ref
                      .read(filenameProvider.notifier)
                      .setFileName(widget.serverInfo.fileName);
                  await loadData(widget.serverInfo.fileName, ref);

                  if (!context.mounted) return;

                  // Perform navigation after loading data
                  Navigator.of(context)
                      .push(
                    MaterialPageRoute(
                      builder: (context) => LogViewerFrame(
                        fileName: widget.serverInfo.fileName,
                      ),
                    ),
                  )
                      .then((_) {
                    // Optional: Call setState if needed after navigating back
                    setState(() {});
                  });
                } else {
                  // Handle downloading the file
                  widget.downloadFileFunction();
                }
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              onPressed: () {
                showMyDialog();
              },
              child: const Text('DELETE'),
            )
          ],
        ),
      ),
    );
  }
}
