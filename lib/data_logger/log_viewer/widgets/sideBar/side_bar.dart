import 'package:ble1/data_logger/log_viewer/widgets/sideBar/choose_lap_menu.dart';
import 'package:ble1/data_logger/log_viewer/widgets/sideBar/side_bar_values.dart';
import 'package:flutter/material.dart';
import 'package:ble1/const/constant.dart';
import 'package:ble1/data_logger/log_viewer/widgets/sideBar/choose_data_category_menu.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ble1/data_logger/provider/datalog_provider.dart';
import 'package:ble1/data_logger/provider/local_file_list_provider.dart';
import 'package:path/path.dart' as path;
import 'package:ble1/data_logger/log_viewer/logger_first_screen.dart';

class SideBar extends ConsumerStatefulWidget {
  const SideBar({
    super.key,
    required this.fileName,
  });
  final String fileName;

  @override
  ConsumerState<SideBar> createState() => _SideMenuState();
}

class _SideMenuState extends ConsumerState<SideBar> {
  bool isSaved = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final providerLocalFileList = ref.watch(localFileListProvider);
      isSaved = providerLocalFileList
          .map((filePath) => path.basename(filePath))
          .contains(widget.fileName);
    });
  }

  @override
  Widget build(BuildContext context) {
    final providerLocalFileList = ref.watch(localFileListProvider);
    // Update the `saved` status based on the current provider state
    isSaved = providerLocalFileList
        .map((filePath) => path.basename(filePath))
        .contains(widget.fileName);

    return SingleChildScrollView(
     // physics: FixedExtentScrollPhysics(parent: ClampingScrollPhysics()),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            //  padding: const EdgeInsets.symmetric(vertical: 30),
            color: const Color(0xFF171821),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(28,30,28,0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(
                            Icons.arrow_back_outlined,
                            color: secondaryColor,
                            size: 32,
                          )),
                      IconButton(
                        onPressed: isSaved
                            ? null
                            : () {
                                ref                                     // save to local storage
                                    .read(dataLogProvider.notifier) // dataLogProvider is the provider
                                    .saveData(widget.fileName, ref); // ref is the widget reference
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Log saved to local storage',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                      textAlign: TextAlign.center,
                                    ),
                                    duration: Duration(milliseconds: 4000),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              },
                        icon: Icon(
                          Icons.save_as_outlined,
                          color: isSaved
                              ? const Color.fromARGB(121, 158, 158, 158)
                              : const Color.fromARGB(255, 5, 168, 90),
                          size: 30,
                        ),
                      ),
                      IconButton(
                        // delete icon
                        onPressed: isSaved
                            ? () {
                                ref
                                    .read(dataLogProvider
                                        .notifier) // removes from local storage
                                    .deleteFile(widget.fileName, ref);
                                Navigator.of(context).pop();
                              }
                            : null,

                        icon: Icon(
                          Icons.delete_forever_outlined,
                          color: isSaved
                              ? Colors.red
                              : const Color.fromARGB(121, 158, 158, 158),
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const ChooseScreenMenu(),
                const SizedBox(
                  height: 20,
                ),
                const ChooseLapMenu(),
                const SizedBox(
                  height: 20,
                ),
                const SideBarValues(),
                // Placeholder(),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  width: 220,
                  height: 280,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xFF21222D),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: LoggerFirstScreen(fileName: widget.fileName,),
                  ),
                ),
                const SizedBox(
                  height: 30,
                )
                //  SideBarFooter(
                //   fileName: widget.fileName,
                //  ), // pass fileName to display venue/date..
              ],
            ),
          ),
        ],
      ),
    );
  }
}
