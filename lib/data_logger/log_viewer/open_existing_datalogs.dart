// ignore_for_file: avoid_print

import 'package:ble1/data_logger/log_viewer/log_viewer_frame.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:ble1/data_logger/provider/datalog_provider.dart';
import 'package:ble1/data_logger/provider/local_file_list_provider.dart';
import 'package:ble1/data_logger/log_viewer/logger_first_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ble1/data_logger/provider/filename_provider.dart';

class ListSavedFiles extends ConsumerStatefulWidget {
  const ListSavedFiles({super.key});

  @override
  ConsumerState<ListSavedFiles> createState() => ListSavedFilesState();
}

class ListSavedFilesState extends ConsumerState<ListSavedFiles> {
  // final GlobalKey<AnimatedListState> _listKey =
  //     GlobalKey<AnimatedListState>(); // Key to control AnimatedList

  String fileContents = '';

  @override
  void initState() {
    super.initState();
    // Load the local file list when the widget is initialized
    Future.microtask(() {
      ref.read(localFileListProvider.notifier).loadLocalFileList();
    });
  }

  Future<String> getFilePath(String fileName) async {
    // Get the application's document directory
    Directory directory = await getApplicationDocumentsDirectory();
    return '${directory.path}$fileName';
  }

  Future loadData(String fileName, WidgetRef ref) async {
    fileContents = await readFromFile(fileName);
    // Update the provider with the new file list
    ref.read(dataLogProvider.notifier).setDatalog(Uint8List.fromList(fileContents.codeUnits));
    ref.read(filenameProvider.notifier).setFileName(fileName);
  }

  @override
  Widget build(BuildContext context) {
    final fileList = ref.watch(localFileListProvider);

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

                int colonPos = fileName.indexOf(':');
                if (colonPos == -1 || colonPos < 12) {
                  // Handle the error or use default values
                  print('Invalid filename format: $fileName');
                  return const SizedBox(); // or handle it appropriately
                }

                if (colonPos - 12 < 0 || colonPos + 3 > fileName.length) {
                  print('Invalid range for filename: $fileName');
                  return const Text(
                    'No filesss found',
                    style: TextStyle(color: Colors.white, fontSize: 28),
                  ); // or handle the case gracefully
                }

                String venue = fileName.substring(
                    colonPos - 12,
                    colonPos -
                        10); // Extract venue initials, eg (cp = Cadwell Park), (na = not available)
                String year = fileName.substring(
                    colonPos - 6, colonPos - 2); // Extract year (2024)
                String month = fileName.substring(
                    colonPos - 8, colonPos - 6); // Extract month (10)
                String day = fileName.substring(
                    colonPos - 10, colonPos - 8); // Extract day
                String time = fileName.substring(colonPos - 2, colonPos + 3);
                String fastestLap = "00:00.00";

                if (venue == 'ho') {
                  venue = 'Home';
                } else if (venue == 'wo') {
                  venue = 'Work';
                } else if (venue == 'na') {
                  venue = 'Venue N/A';
                }
                print('printing from open_existing_datalogs_file $fileName');

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
                                      venue,
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
                                      venue,
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
                        const SizedBox(
                          width: 15,
                        ),
                        SizedBox(
                          width: 110,
                          child: Text(
                            time,
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
                            fastestLap,
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
