import 'package:ble1/data_logger/log_viewer/widgets/sideBar/isar_database_stuff/models/note.dart';
import 'package:ble1/data_logger/provider/filename_provider.dart';
import 'package:ble1/data_logger/provider/note_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotesForm extends ConsumerStatefulWidget {
  final String fileName;
  const NotesForm({super.key, required this.fileName});

  @override
  ConsumerState<NotesForm> createState() => _NotesFormState();
}

class _NotesFormState extends ConsumerState<NotesForm> {
  final sessionController = TextEditingController();
  final weatherController = TextEditingController();
  final frontSprocketController = TextEditingController();
  final rearSprocketController = TextEditingController();
  final mainJetController = TextEditingController();
  final pilotJetController = TextEditingController();
  final needleController = TextEditingController();
  final notesController = TextEditingController();

  Note? lastLoadedNote;
  bool hasInitialLoad = false;
  bool hasSetListener = false;
  bool isDirty = false; // 🔹 Track unsaved changes

  @override
  void initState() {
    super.initState();

    // Watch controllers for changes
    for (var c in [
      sessionController,
      weatherController,
      frontSprocketController,
      rearSprocketController,
      mainJetController,
      pilotJetController,
      needleController,
      notesController
    ]) {
      c.addListener(() {
        if (lastLoadedNote != null) {
          isDirty = sessionController.text != lastLoadedNote!.session ||
              weatherController.text != lastLoadedNote!.weather ||
              frontSprocketController.text != lastLoadedNote!.frontSprocket ||
              rearSprocketController.text != lastLoadedNote!.rearSprocket ||
              mainJetController.text != lastLoadedNote!.mainJet ||
              pilotJetController.text != lastLoadedNote!.pilotJet ||
              needleController.text != lastLoadedNote!.needlePosition ||
              notesController.text != lastLoadedNote!.additionalNotes;
          setState(() {}); // rebuild to update Save button state if needed
        }
      });
    }
  }

  @override
  void dispose() {
    sessionController.dispose();
    weatherController.dispose();
    frontSprocketController.dispose();
    rearSprocketController.dispose();
    mainJetController.dispose();
    pilotJetController.dispose();
    needleController.dispose();
    notesController.dispose();
    super.dispose();
  }

  void _fillControllers(Note note) {
    sessionController.text = note.session;
    weatherController.text = note.weather;
    frontSprocketController.text = note.frontSprocket;
    rearSprocketController.text = note.rearSprocket;
    mainJetController.text = note.mainJet;
    pilotJetController.text = note.pilotJet;
    needleController.text = note.needlePosition;
    notesController.text = note.additionalNotes;
    isDirty = false; // reset dirty flag
  }

  Future<bool> _showUnsavedDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Unsaved Changes"),
        content: const Text(
            "You have unsaved changes. Do you want to discard them?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text("Return to notes")),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text("Discard Edit")),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // 🔹 Register ref.listen in build (only once)
    if (!hasSetListener) {
      hasSetListener = true;
      ref.listen<String?>(filenameProvider, (previous, next) async {
        if (next != null) {
          if (isDirty) {
            final discard = await _showUnsavedDialog();
            if (!discard) return; // keep editing current
          }
          ref.read(noteProvider.notifier).loadNoteForFile(next);
        }
      });
    }
    final venueAndDate = ref.read(filenameProvider);

    // 🔹 Run initial load
    if (!hasInitialLoad) {
      hasInitialLoad = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(noteProvider.notifier).loadNoteForFile(widget.fileName);
      });
    }

    final note = ref.watch(noteProvider);

    if (note == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (lastLoadedNote == null || lastLoadedNote!.id != note.id) {
      _fillControllers(note);
      lastLoadedNote = note;
    }

    return PopScope(
      canPop: !isDirty, // block automatic popping if unsaved
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return; // the route already popped, no need to handle

        if (isDirty) {
          final discard = await _showUnsavedDialog();
          if (discard && context.mounted) {
            Navigator.of(context).pop(); // manually pop if user confirms
          }
        } else {
          if (context.mounted) Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
            //     title: Text(
            //   "Notes for $venueAndDate",
            //   style: TextStyle(fontSize: 18),
            // )),
            ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(1.0),
            child: SizedBox(
              width: 1200,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text('NOTES:',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue)),
                        SizedBox(
                          width: 10,
                        ),
                        Text('$venueAndDate',
                            style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue)),
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),

                    //---------------------------------------------------------------------------------------------

                    Container(
                      color: Colors.grey[900],
                      height: 45,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Session',
                            style: TextStyle(fontSize: 20, color: Colors.blue),
                          ),
                          SizedBox(
                            width: 13,
                          ),
                          TextField(
                            controller: sessionController,
                            textAlignVertical: TextAlignVertical.center,
                            decoration: const InputDecoration(
                              fillColor: Color.fromARGB(95, 106, 105, 105),
                              constraints:
                                  BoxConstraints(minWidth: 200, maxWidth: 200),
                            ),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Text(
                            'Weather / Conditions',
                            style: TextStyle(fontSize: 19, color: Colors.blue),
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          TextField(
                            controller: weatherController,
                            textAlignVertical: TextAlignVertical.center,
                            decoration: const InputDecoration(
                              fillColor: Color.fromARGB(95, 106, 105, 105),
                              constraints:
                                  BoxConstraints(minWidth: 200, maxWidth: 200),
                            ),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(width: 10,),
                               Text(
                            'Rider',
                            style: TextStyle(fontSize: 19, color: Colors.blue),
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          TextField(
                            controller: weatherController,
                            textAlignVertical: TextAlignVertical.center,
                            decoration: const InputDecoration(
                              fillColor: Color.fromARGB(95, 106, 105, 105),
                              constraints:
                                  BoxConstraints(minWidth: 200, maxWidth: 200),
                            ),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),

                    //==================================================================================================
                    SizedBox(
                      height: 40,
                    ),
                    Column(
                      children: [
                        Container(
                          height: 120,
                          width: 200,
                          decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              border:
                                  Border.all(color: Colors.black, width: 2)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 35,
                                color: Colors.white,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text('Main Jet',
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 12)),
                                    Spacer(),
                                    TextField(
                                      controller: mainJetController,
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      decoration: const InputDecoration(
                                        fillColor:
                                            Color.fromARGB(145, 234, 233, 233),
                                        constraints: BoxConstraints(
                                            minWidth: 60, maxWidth: 60),
                                      ),
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 11,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                  ],
                                ),
                              ),

                              Container(
                                height: 35,
                                color: Colors.white,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text('Needle Pos',
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 12)),
                                    Spacer(),
                                    TextField(
                                      controller: needleController,
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      decoration: const InputDecoration(
                                        fillColor:
                                            Color.fromARGB(145, 234, 233, 233),
                                        constraints: BoxConstraints(
                                            minWidth: 60, maxWidth: 60),
                                      ),
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 11,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                  ],
                                ),
                              ),

                              Container(
                                height: 35,
                                color: Colors.white,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text('Max Advance',
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 14)),
                                    Spacer(),
                                    TextField(
                                      controller: sessionController,
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      decoration: const InputDecoration(
                                        fillColor:
                                            Color.fromARGB(145, 234, 233, 233),
                                        constraints: BoxConstraints(
                                            minWidth: 60, maxWidth: 60),
                                      ),
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        //============================================= Middle Row ===========================================
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            
                              //   //---------------------------------- DEFINE THE NUMBER OF COLUMNS / FRONT SUSPENSION -----------------------------------------------------------
                         
                            DataTable(
                              columns: const <DataColumn>[
                                DataColumn(
                                  label: Text(
                                    '',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    '',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],

                              //---------------------------------------------------------------------------------------------

                              rows: <DataRow>[
                                DataRow(
                                  color:
                                      WidgetStateProperty.all(Colors.grey[800]),
                                  cells: <DataCell>[
                                    DataCell(Text('Front Suspension')),
                                    DataCell(Text('')),
                                    // DataCell(TextField(
                                    //   controller: sessionController,
                                    //   decoration: const InputDecoration(
                                    //       fillColor:
                                    //           Color.fromARGB(0, 158, 158, 158),
                                    //       constraints: BoxConstraints(
                                    //           minWidth: 200, maxWidth: 200)),
                                    //   style: TextStyle(color: Colors.white),
                                    // )),
                                    
                                  ],
                                ),
                                //---------------------------------------------------------------------------------------------

                                DataRow(
                                  cells: <DataCell>[
                                      DataCell(Text('Preload')),
                                    // DataCell(TextField(
                                    //   controller: frontSprocketController,
                                    //   decoration: const InputDecoration(
                                    //       fillColor:
                                    //           Color.fromARGB(0, 158, 158, 158),
                                    //       constraints:
                                    //           BoxConstraints(minWidth: 0)),
                                    //   style: TextStyle(color: Colors.white),
                                    // )),
                                    DataCell(TextField(
                                      controller: rearSprocketController,
                                      decoration: const InputDecoration(
                                          constraints:
                                              BoxConstraints(maxWidth: 55)),
                                      style: TextStyle(color: Colors.black),
                                    )),
                                  ],
                                ),

                                //---------------------------------------------------------------------------------------------

                                DataRow(
                                  cells: <DataCell>[
                                    DataCell(Text('Compression')),
                                      DataCell(TextField(
                                      controller: rearSprocketController,
                                      decoration: const InputDecoration(
                                          constraints:
                                              BoxConstraints(maxWidth: 55)),
                                      style: TextStyle(color: Colors.black),
                                    )),
                                  ],
                                ),
                                //---------------------------------------------------------------------------------------------
                                                            
                                DataRow(
                                  cells: <DataCell>[
                                    DataCell(Text('Rebound')),
                                    DataCell(TextField(
                                      controller: rearSprocketController,
                                      decoration: const InputDecoration(
                                          constraints:
                                              BoxConstraints(maxWidth: 55)),
                                      style: TextStyle(color: Colors.black),
                                    )),
                                  ],
                                ),
                              ],
                            ),

                            //------------------------------------------------------------------------------------------------
                            Padding(
                              padding: const EdgeInsets.all(28.0),
                              child: ConstrainedBox(
                                constraints:
                                    BoxConstraints(maxWidth: 400, maxHeight: 300),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Color.fromARGB(0, 0, 0,
                                        0), // Add this to set a solid background
                                    image: DecorationImage(
                                      image: AssetImage(
                                        'lib/images/whiteBike_flipped.png',
                                      ),
                                      fit: BoxFit
                                          .contain, // Optional: Ensures the image fits nicely without distortion
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            //------------------------------------------------------------------------------------------------
                            
                            DataTable(
                              columns: const <DataColumn>[
                                DataColumn(
                                  label: Text(
                                    '',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    '',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],

                              //---------------------------------------------------------------------------------------------

                              rows: <DataRow>[
                                DataRow(
                                  color:
                                      WidgetStateProperty.all(Colors.grey[800]),
                                  cells: <DataCell>[
                                    DataCell(Text('Rear Suspension')),
                                    DataCell(Text('')),
                                    // DataCell(TextField(
                                    //   controller: sessionController,
                                    //   decoration: const InputDecoration(
                                    //       fillColor:
                                    //           Color.fromARGB(0, 158, 158, 158),
                                    //       constraints: BoxConstraints(
                                    //           minWidth: 200, maxWidth: 200)),
                                    //   style: TextStyle(color: Colors.white),
                                    // )),
                                  ],
                                ),
                                //---------------------------------------------------------------------------------------------

                                DataRow(
                                  cells: <DataCell>[
                                    DataCell(Text('Preload')),
                                    // DataCell(TextField(
                                    //   controller: frontSprocketController,
                                    //   decoration: const InputDecoration(
                                    //       fillColor:
                                    //           Color.fromARGB(0, 158, 158, 158),
                                    //       constraints:
                                    //           BoxConstraints(minWidth: 0)),
                                    //   style: TextStyle(color: Colors.white),
                                    // )),
                                    DataCell(TextField(
                                      controller: rearSprocketController,
                                      decoration: const InputDecoration(
                                          constraints:
                                              BoxConstraints(maxWidth: 55)),
                                      style: TextStyle(color: Colors.black),
                                    )),
                                  ],
                                ),

                                //---------------------------------------------------------------------------------------------

                                DataRow(
                                  cells: <DataCell>[
                                    DataCell(Text('Compression Low speed')),
                                    DataCell(TextField(
                                      controller: rearSprocketController,
                                      decoration: const InputDecoration(
                                          constraints:
                                              BoxConstraints(maxWidth: 55)),
                                      style: TextStyle(color: Colors.black),
                                    )),
                                  ],
                                ),
                                //---------------------------------------------------------------------------------------------
                                //---------------------------------------------------------------------------------------------

                                DataRow(
                                  cells: <DataCell>[
                                    DataCell(Text('Compression High Speed')),
                                    DataCell(TextField(
                                      controller: rearSprocketController,
                                      decoration: const InputDecoration(
                                          constraints:
                                              BoxConstraints(maxWidth: 55)),
                                      style: TextStyle(color: Colors.black),
                                    )),
                                  ],
                                ),
                                //---------------------------------------------------------------------------------------------

                                DataRow(
                                  cells: <DataCell>[
                                    DataCell(Text('Rebound')),
                                    DataCell(TextField(
                                      controller: rearSprocketController,
                                      decoration: const InputDecoration(
                                          constraints:
                                              BoxConstraints(maxWidth: 55)),
                                      style: TextStyle(color: Colors.black),
                                    )),
                                  ],
                                ),
                              ],
                            ),


                          ],
                        ),
                      ],
                    ),

                    //---------------------------------- DEFINE THE TABLE ----------------------------------------------
                    //  DataTable(
                    // //   //---------------------------------- DEFINE THE NUMBER OF COLUMNS -----------------------------------------------------------
                    //   columns: const <DataColumn>[
                    //     DataColumn(
                    //       label: Text(
                    //         '',
                    //         style: TextStyle(fontWeight: FontWeight.bold),
                    //       ),
                    //     ),
                    //     DataColumn(
                    //       label: Text(
                    //         '',
                    //         style: TextStyle(fontWeight: FontWeight.bold),
                    //       ),
                    //     ),
                    //     DataColumn(
                    //       label: Text(
                    //         '',
                    //         style: TextStyle(fontWeight: FontWeight.bold),
                    //       ),
                    //     ),
                    //     DataColumn(
                    //       label: Text(
                    //         '',
                    //         style: TextStyle(fontWeight: FontWeight.bold),
                    //       ),
                    //     ),
                    //   ],

                    //   //---------------------------------------------------------------------------------------------

                    //   rows: <DataRow>[
                    //     DataRow(
                    //       color: WidgetStateProperty.all(Colors.grey[800]),
                    //       cells: <DataCell>[
                    //         DataCell(
                    //           Text(
                    //             'Session',
                    //           ),
                    //         ),
                    //         DataCell(TextField(
                    //           controller: sessionController,
                    //           decoration: const InputDecoration(
                    //               fillColor: Color.fromARGB(0, 158, 158, 158),
                    //               constraints: BoxConstraints(
                    //                   minWidth: 200, maxWidth: 200)),
                    //           style: TextStyle(color: Colors.white),
                    //         )),
                    //         DataCell(Text('Weather')),
                    //         DataCell(Text('Rain')),
                    //       ],
                    //     ),
                    //     //---------------------------------------------------------------------------------------------

                    //     DataRow(
                    //       cells: <DataCell>[
                    //         DataCell(Text('Front Sprocket')),
                    //         DataCell(TextField(
                    //           controller: frontSprocketController,
                    //           decoration: const InputDecoration(
                    //               fillColor: Color.fromARGB(0, 158, 158, 158),
                    //               constraints: BoxConstraints(minWidth: 0)),
                    //           style: TextStyle(color: Colors.white),
                    //         )),
                    //         DataCell(Text('Rear Sprocket')),
                    //         DataCell(TextField(
                    //           controller: rearSprocketController,
                    //           decoration: const InputDecoration(
                    //               constraints: BoxConstraints(maxWidth: 55)),
                    //           style: TextStyle(color: Colors.black),
                    //         )),
                    //       ],
                    //     ),

                    //     //---------------------------------------------------------------------------------------------

                    //     DataRow(
                    //       cells: <DataCell>[
                    //         DataCell(Text('Rear Sprocket')),
                    //         DataCell(TextField(
                    //           controller: rearSprocketController,
                    //           decoration: const InputDecoration(
                    //               constraints: BoxConstraints(maxWidth: 55)),
                    //           style: TextStyle(color: Colors.black),
                    //         )),
                    //         DataCell(Text('Session')),
                    //         DataCell(TextField(
                    //           controller: sessionController,
                    //           decoration: const InputDecoration(
                    //               constraints: BoxConstraints(minWidth: 0)),
                    //           style: TextStyle(color: Colors.black),
                    //         )),
                    //       ],
                    //     ),
                    //     //---------------------------------------------------------------------------------------------
                    //   ],
                    // ),
                    //---------------------------------------------------------------------------------------------

                    SizedBox(
                      height: 10,
                    ),

                    TextField(
                        style: TextStyle(color: Colors.black),
                        controller: notesController,
                        decoration: const InputDecoration(
                          constraints: BoxConstraints(minWidth: 500),
                        ),
                        maxLines: 4),
                    const SizedBox(height: 20),
                    ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 600),
                        child: Divider(color: Colors.grey)),
                    SizedBox(height: 20),

                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        final updated = note
                          ..session = sessionController.text
                          ..weather = weatherController.text
                          ..frontSprocket = frontSprocketController.text
                          ..rearSprocket = rearSprocketController.text
                          ..mainJet = mainJetController.text
                          ..pilotJet = pilotJetController.text
                          ..needlePosition = needleController.text
                          ..additionalNotes = notesController.text;

                        ref.read(noteProvider.notifier).saveNote(updated);
                        isDirty = false;
                        setState(() {});
                        //  Navigator.pop(context);
                      },
                      child: Text(isDirty ? "Save" : "Saved"),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
