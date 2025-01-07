import 'package:flutter/material.dart';
import 'package:ble1/data_logger/models/server_file_details.dart';
import 'package:ble1/data_logger/server_folder/server_item_info.dart';

class ServerFileList extends StatelessWidget {
  const ServerFileList(
      {required this.data,
      required this.downloadFileFunction,
      required this.deleteFunction,
      required this.listKey,
      super.key}); // Add the key for AnimatedList

  final List<ServerFileDetails> data;                                                                // the data
  final void Function(ServerFileDetails file, int index) deleteFunction;                              // pass the delete function and some other stuff to do with the delete animation?
  final void Function(String fileName, BuildContext context, int fileSize) downloadFileFunction;       // pass the download function
  final GlobalKey<AnimatedListState> listKey;                                                          // AnimatedList key

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: CircularProgressIndicator()
          // Text(
          //   "No files available",
          //   style: TextStyle(color: Colors.white),
          // ),
          );
    }
    return AnimatedList(
      key: listKey, // Assign the key to the AnimatedList
      initialItemCount: data.length,

      itemBuilder:
          (BuildContext context, int index, Animation<double> animation) {
        return _buildItem(context, index, animation);
      },
    );
  }

  Widget _buildItem(
      BuildContext context, int index, Animation<double> animation) {
    final file = data[index];
    return SizeTransition(
      sizeFactor: animation,
      child: ServerItemInfo(
        serverInfo: file,
        downloadFileFunction: () => downloadFileFunction(file.fileName, context, int.parse(file.fileSize)),
        deleteFunction: () => deleteFunction(file,
            index), // Pass the index along with the file to delete function
      ),
    );
  }
}
