//ignore_for_file: avoid_print

import 'package:ble1/data_logger/log_viewer/log_viewer_frame.dart';
import 'package:ble1/data_logger/log_viewer/widgets/sideBar/isar_database_stuff/models/venue_model.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:ble1/data_logger/provider/datalog_provider.dart';
import 'package:ble1/data_logger/provider/local_file_list_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ble1/data_logger/provider/filename_provider.dart';
import 'package:isar/isar.dart';

class ListSavedFiles extends ConsumerStatefulWidget {
  const ListSavedFiles({super.key});

  @override
  ConsumerState<ListSavedFiles> createState() => ListSavedFilesState();
}

class ListSavedFilesState extends ConsumerState<ListSavedFiles> {
  Uint8List fileContents = Uint8List(0);
  List<VenueModel> venueList = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      ref.read(localFileListProvider.notifier).loadLocalFileList();
      final isar = Isar.getInstance();
      final result = await isar?.venueModels.where().findAll();
      setState(() {
        venueList = result!;
      });
    });
  }

  Future<String> getFilePath(String fileName) async {
    // Get the application's document directory
    Directory directory = await getApplicationDocumentsDirectory();
    return '${directory.path}$fileName';
  }

  Future<void> loadData(String fileName, WidgetRef ref) async {
    try {
      // Get the full file path
      final fullPath = await getFilePath(fileName);

      // Read the file as bytes
      fileContents = await File(fullPath).readAsBytes();

      // Update the provider with the new data
      ref
          .read(dataLogProvider.notifier)
          .setDatalog(Uint8List.fromList(fileContents));
      ref.read(filenameProvider.notifier).setFileName(fileName);

      print('File loaded successfully: $fileName');
    } catch (e) {
      print('Error loading file: $e');
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
    if (time.length < 4) {
      print("⚠️ Invalid time string: '$time'");
      return "--:--";
    }

    String hour = time.substring(0, 2);
    String mins = time.substring(2, 4);
    return '$hour:$mins';
  }

//-----------------------------------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final fileList = ref
        .watch(localFileListProvider)
        .where((file) => !file.endsWith('.DS_Store'))
        .toList();

    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved Files"),
      ),
      body: fileList.isEmpty
          ? const Center(
              child: Text(
              'No files found',
              style: TextStyle(fontSize: 22, color: Colors.white),
            ))
          : ListView.builder(
              itemCount: fileList.length,
              itemBuilder: (context, index) {
                String filePath = fileList[index];
                String fileName = path.basename(filePath);

                int txtPos = fileName.indexOf('.txt');

                // Ensure txtPos is valid
                if (txtPos == -1 || txtPos < 22) {
                  print('Skipping invalid log filename format: $fileName');
                  print('Skipping invalid log filename format: $filePath');
                  return const SizedBox.shrink(); // Skip processing this file
                }



                String id = fileName.substring(
                    1, txtPos - 22); // Extract ID from filename
                print(id);

                String year = fileName.substring(
                    txtPos - 4, txtPos); // Extract year (2024)
                String month = fileName.substring(
                    txtPos - 6, txtPos - 4); // Extract month (10)
                String day =
                    fileName.substring(txtPos - 8, txtPos - 6); // Extract day
                String time = fileName.substring(
                    txtPos - 12, txtPos - 8); // Extract time (HHMMSS)
                // String fastestLap = fileName.substring(txtPos - 19,
                //     txtPos - 12); // Extract fastest lap time (HHMMSS)
                String fastestLap = fileName.substring(txtPos - 19,
                    txtPos - 12); // Extract fastest lap time (HHMMSS)
                String version = fileName.substring(txtPos - 22, txtPos - 21);

         
                String venueName = "Unknown Venue";
                //defensive check
                if (fileName.length >= 30) {
                  String venueCode =
                      fileName.substring(txtPos - 26, txtPos - 25);

                  for (final venue in venueList) {
                    if (venue.code == venueCode) {
                      venueName = venue.name;
                      break;
                    }
                  }
                }

                // print('printing from open_existing_datalogs_file $fileName');
                // print('printing from open_existing_datalogs_file $filePath');

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
                                'Warning! This cannot be undone.',
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
                                  'DELETE',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                                ),
                                onPressed: () {
                                  ref
                                      .read(localFileListProvider
                                          .notifier) // remove from filelist
                                      .deleteFile(index);
                                  ref
                                      .read(dataLogProvider
                                          .notifier) // removes from local storage
                                      .deleteFile(fileName, ref);

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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Row(
                      children: [
                        screenSize.width > 670
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 150,
                                    child: Text(
                                      venueName,
                                      style: const TextStyle(
                                          color: Colors.blue,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        day,
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
                                        month,
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
                                        year,
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
                                      venueName,
                                      style: const TextStyle(
                                          color: Colors.blue,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          day,
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
                                          month,
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
                                          year,
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
                        SizedBox(
                          width: 150,
                          child: Text(
                            id,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        SizedBox(
                          width: 110,
                          child: Text(
                            formatTime(time), // Format the time as HH:MM
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
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
                            formatMilliseconds(int.parse(
                                fastestLap)), // Format the fastest lap time(millis to HH:MM:SS)
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const Spacer(),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.green,
                          ),
                          onPressed: () async {
                            await loadData('/$fileName',
                                ref); // Ensure data is loaded before navigation
                            if (!context.mounted) return;
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => LogViewerFrame(
                                  fileName: fileName,

                                  //  datalog: ref.read(localDataLogProvider),
                                ),
                              ),
                            );
                          },
                          child: const Text('OPEN'),
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
              },
            ),
    );
  }
}
