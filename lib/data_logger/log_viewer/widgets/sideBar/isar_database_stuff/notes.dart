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
  final riderController = TextEditingController();
  final frontSprocketController = TextEditingController();
  final rearSprocketController = TextEditingController();
  final mainJetController = TextEditingController();
  final pilotJetController = TextEditingController();
  final needleController = TextEditingController();
  final notesController = TextEditingController();
  final preloadController = TextEditingController();
  final compressionController = TextEditingController();
  final reboundController = TextEditingController();
  final maxAdvanceController = TextEditingController();
  final ratioController = TextEditingController();
  final rearPreloadController = TextEditingController();
  final rearLowspeedCompressionController = TextEditingController();
  final rearHighspeedCompressionController = TextEditingController();
  final rearReboundController = TextEditingController();

  Note? lastLoadedNote;
  bool hasInitialLoad = false;
  bool hasSetListener = false;
  bool isDirty = false; // 🔹 Track unsaved changes

  double inputCellWidth =
      70; // default width for input cells, can be adjusted as needed

  @override
  void initState() {
    super.initState();

    // Watch controllers for changes
    for (var c in [
      sessionController,
      weatherController,
      riderController,
      frontSprocketController,
      rearSprocketController,
      mainJetController,
      pilotJetController,
      needleController,
      notesController,
      preloadController,
      compressionController,
      reboundController,
      maxAdvanceController,
      ratioController,
      rearPreloadController,
      rearLowspeedCompressionController,
      rearHighspeedCompressionController,
      rearReboundController,
    ]) {
      c.addListener(() {
        if (lastLoadedNote != null) {
          isDirty = sessionController.text != lastLoadedNote!.session ||
              weatherController.text != lastLoadedNote!.weather ||
              riderController.text != lastLoadedNote!.rider ||
              frontSprocketController.text != lastLoadedNote!.frontSprocket ||
              rearSprocketController.text != lastLoadedNote!.rearSprocket ||
              mainJetController.text != lastLoadedNote!.mainJet ||
              pilotJetController.text != lastLoadedNote!.pilotJet ||
              needleController.text != lastLoadedNote!.needlePosition ||
              preloadController.text != lastLoadedNote!.preload ||
              compressionController.text != lastLoadedNote!.compression ||
              reboundController.text != lastLoadedNote!.rebound ||
              maxAdvanceController.text !=
                  lastLoadedNote!.maxAdvanceController ||
              ratioController.text != lastLoadedNote!.ratioController ||
              rearPreloadController.text !=
                  lastLoadedNote!.rearPreloadController ||
              rearLowspeedCompressionController.text !=
                  lastLoadedNote!.rearLowspeedCompressionController ||
              rearHighspeedCompressionController.text !=
                  lastLoadedNote!.rearHighspeedCompressionController ||
              rearReboundController.text !=
                  lastLoadedNote!.rearReboundController ||
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
    riderController.dispose();
    frontSprocketController.dispose();
    rearSprocketController.dispose();
    mainJetController.dispose();
    pilotJetController.dispose();
    needleController.dispose();
    notesController.dispose();
    preloadController.dispose();
    compressionController.dispose();
    reboundController.dispose();
    maxAdvanceController.dispose();
    ratioController.dispose();
    rearPreloadController.dispose();
    rearLowspeedCompressionController.dispose();
    rearHighspeedCompressionController.dispose();
    rearReboundController.dispose();
    super.dispose();
  }

  void _fillControllers(Note note) {
    sessionController.text = note.session;
    weatherController.text = note.weather;
    riderController.text = note.rider;
    frontSprocketController.text = note.frontSprocket;
    rearSprocketController.text = note.rearSprocket;
    mainJetController.text = note.mainJet;
    pilotJetController.text = note.pilotJet;
    needleController.text = note.needlePosition;
    notesController.text = note.additionalNotes;
    preloadController.text = note.preload;
    compressionController.text = note.compression;
    reboundController.text = note.rebound;
    maxAdvanceController.text = note.maxAdvanceController;
    ratioController.text = note.ratioController;
    rearPreloadController.text = note.rearPreloadController;
    rearLowspeedCompressionController.text =
        note.rearLowspeedCompressionController;
    rearHighspeedCompressionController.text =
        note.rearHighspeedCompressionController;
    rearReboundController.text = note.rearReboundController;

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
              child: const Text("Return to notes",
                  style: TextStyle(color: Colors.blue))),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text("Discard Edit",
                  style: TextStyle(color: Colors.red))),
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
        // appBar: AppBar(
        //     //     title: Text(
        //     //   "Notes for $venueAndDate",
        //     //   style: TextStyle(fontSize: 18),
        //     // )),
        //     ),
        body: Center(
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
                    height: 40,
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
                          'Weather Conditions',
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
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Rider',
                          style: TextStyle(fontSize: 19, color: Colors.blue),
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        TextField(
                          controller: riderController,
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

                  //======================== AFTER TOP BAR ==========================================================================
                  // SizedBox(
                  //   height: 1,
                  // ),
                  Column(
                    children: [
                      //---------------------------------- DEFINE THE NUMBER OF COLUMNS / ENGINE  -----------------------------------------------------------
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //   //---------------------------------- DEFINE THE NUMBER OF COLUMNS -----------------------------------------------------------

                          DataTable(
                            columns: const <DataColumn>[
                              DataColumn(
                                label: Text(
                                  '',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  '',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],

                            //---------------------------------------------------------------------------------------------

                            rows: <DataRow>[
                              DataRow(
                                color:
                                    WidgetStateProperty.all(Colors.grey[800]),
                                cells: <DataCell>[
                                  DataCell(Text('Engine')),
                                  DataCell(Text('')),
                                ],
                              ),
                              //---------------------------------------------------------------------------------------------

                              DataRow(
                                cells: <DataCell>[
                                  DataCell(Text('Main Jet')),
                                  DataCell(TextField(
                                    maxLength: 3,
                                    controller: mainJetController,
                                    decoration: InputDecoration(
                                        counterText: '',
                                        constraints: BoxConstraints(
                                            maxWidth: inputCellWidth)),
                                    style: TextStyle(color: Colors.black),
                                  )),
                                ],
                              ),

                              //---------------------------------------------------------------------------------------------

                              DataRow(
                                cells: <DataCell>[
                                  DataCell(Text('Needle Position')),
                                  DataCell(TextField(
                                    controller: needleController,
                                    maxLength: 3,
                                    decoration: InputDecoration(
                                      counterText: '',
                                      constraints: BoxConstraints(
                                          maxWidth: inputCellWidth),
                                    ),
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(color: Colors.black),
                                  )),
                                ],
                              ),
                              //---------------------------------------------------------------------------------------------

                              DataRow(
                                cells: <DataCell>[
                                  DataCell(Text('Max Advance')),
                                  DataCell(TextField(
                                    controller: maxAdvanceController,
                                    maxLength: 3,
                                    decoration: InputDecoration(
                                        counterText: '',
                                        constraints: BoxConstraints(
                                            maxWidth: inputCellWidth)),
                                    style: TextStyle(color: Colors.black),
                                  )),
                                ],
                              ),
                            ],
                          ),

                          //------------------------------------------------------------------------------------------------

                          Padding(
                            padding: const EdgeInsets.fromLTRB(90, 60, 160, 0),
                            child: ConstrainedBox(
                              constraints:
                                  BoxConstraints(maxWidth: 350, maxHeight: 250),
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
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  '',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],

                            //---------------------------------------------------------------------------------------------

                            rows: <DataRow>[
                              DataRow(
                                color:
                                    WidgetStateProperty.all(Colors.grey[800]),
                                cells: <DataCell>[
                                  DataCell(Text('Gearing')),
                                  DataCell(Text('')),
                                ],
                              ),
                              //---------------------------------------------------------------------------------------------

                              DataRow(
                                cells: <DataCell>[
                                  DataCell(Text('Ratio')),
                                  DataCell(TextField(
                                    controller: ratioController,
                                    maxLength: 3,
                                    decoration: InputDecoration(
                                        counterText: '',
                                        constraints: BoxConstraints(
                                            maxWidth: inputCellWidth)),
                                    style: TextStyle(color: Colors.black),
                                  )),
                                ],
                              ),

                              //---------------------------------------------------------------------------------------------

                              DataRow(
                                cells: <DataCell>[
                                  DataCell(Text('Front Sprocket')),
                                  DataCell(TextField(
                                    controller: frontSprocketController,
                                    maxLength: 3,
                                    decoration: InputDecoration(
                                        counterText: '',
                                        constraints: BoxConstraints(
                                            maxWidth: inputCellWidth)),
                                    style: TextStyle(color: Colors.black),
                                  )),
                                ],
                              ),

                              //---------------------------------------------------------------------------------------------

                              DataRow(
                                cells: <DataCell>[
                                  DataCell(Text('Rear Sprocket')),
                                  DataCell(TextField(
                                    controller: rearSprocketController,
                                    maxLength: 3,
                                    decoration: InputDecoration(
                                        counterText: '',
                                        constraints: BoxConstraints(
                                            maxWidth: inputCellWidth)),
                                    style: TextStyle(color: Colors.black),
                                  )),
                                ],
                              ),
                              //---------------------------------------------------------------------------------------------
                            ],
                          ),
                        ],
                      ),

                      //============================================= Middle Row ===========================================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //   //---------------------------------- DEFINE THE NUMBER OF COLUMNS / FRONT SUSPENSION -----------------------------------------------------------

                          DataTable(
                            columns: const <DataColumn>[
                              DataColumn(
                                label: Text(
                                  '',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  '',
                                  style: TextStyle(fontWeight: FontWeight.bold),
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
                                ],
                              ),
                              //---------------------------------------------------------------------------------------------

                              DataRow(
                                cells: <DataCell>[
                                  DataCell(Text('Preload')),
                                  DataCell(TextField(
                                    controller: preloadController,
                                    maxLength: 3,
                                    decoration: InputDecoration(
                                        counterText: '',
                                        constraints: BoxConstraints(
                                            maxWidth: inputCellWidth)),
                                    style: TextStyle(color: Colors.black),
                                  )),
                                ],
                              ),

                              //---------------------------------------------------------------------------------------------

                              DataRow(
                                cells: <DataCell>[
                                  DataCell(Text('Compression')),
                                  DataCell(TextField(
                                    controller: compressionController,
                                    maxLength: 3,
                                    decoration: InputDecoration(
                                        counterText: '',
                                        constraints: BoxConstraints(
                                            maxWidth: inputCellWidth)),
                                    style: TextStyle(color: Colors.black),
                                  )),
                                ],
                              ),
                              //---------------------------------------------------------------------------------------------

                              DataRow(
                                cells: <DataCell>[
                                  DataCell(Text('Rebound')),
                                  DataCell(TextField(
                                    maxLength: 3,
                                    controller: reboundController,
                                    decoration: InputDecoration(
                                        counterText: '',
                                        constraints: BoxConstraints(
                                            maxWidth: inputCellWidth)),
                                    style: TextStyle(color: Colors.black),
                                  )),
                                ],
                              ),
                            ],
                          ),

                          //------------------------------------------------------------------------------------------------

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 70,
                              ),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                    maxWidth: 450, maxHeight: 900),
                                child: TextField(
                                    style: TextStyle(color: Colors.black),
                                    controller: notesController,
                                    decoration: const InputDecoration(
                                      constraints:
                                          BoxConstraints(minWidth: 1000),
                                    ),
                                    maxLines: 6),
                              ),
                              SizedBox(
                                height: 25,
                              ),
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      final updated = note
                                        ..session = sessionController.text
                                        ..weather = weatherController.text
                                        ..preload = preloadController.text
                                        ..compression =
                                            compressionController.text
                                        ..rebound = reboundController.text
                                        ..rider = riderController.text
                                        ..frontSprocket =
                                            frontSprocketController.text
                                        ..rearSprocket =
                                            rearSprocketController.text
                                        ..mainJet = mainJetController.text
                                        ..pilotJet = pilotJetController.text
                                        ..needlePosition = needleController.text
                                        ..maxAdvanceController =
                                            maxAdvanceController.text
                                        ..ratioController = ratioController.text
                                        ..rearPreloadController =
                                            rearPreloadController.text
                                        ..rearLowspeedCompressionController =
                                            rearLowspeedCompressionController
                                                .text
                                        ..rearHighspeedCompressionController =
                                            rearHighspeedCompressionController
                                                .text
                                        ..rearReboundController =
                                            rearReboundController.text
                                        ..additionalNotes =
                                            notesController.text;

                                      ref
                                          .read(noteProvider.notifier)
                                          .saveNote(updated);
                                      isDirty = false;
                                      setState(() {});
                                      //  Navigator.pop(context);
                                    },
                                    child: Text(isDirty ? "SAVE" : "SAVED",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: isDirty
                                                ? Colors.white
                                                : Colors.blue)),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      if (isDirty) {
                                        final discard =
                                            await _showUnsavedDialog();
                                        if (discard && context.mounted) {
                                          Navigator.of(context).pop();
                                        }
                                      } else {
                                        if (context.mounted) {
                                          Navigator.of(context).pop();
                                        }
                                      }
                                    },
                                    child: isDirty
                                        ? Text("DISCARD EDIT",
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.blue))
                                        : Text("EXIT",
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.blue)),
                                  ),
                                ],
                              )
                            ],
                          ),
                          //------------------------------------------------------------------------------------------------

                          // SizedBox(width: 30,),
                          DataTable(
                            columns: const <DataColumn>[
                              DataColumn(
                                label: Text(
                                  '',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  '',
                                  style: TextStyle(fontWeight: FontWeight.bold),
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
                                ],
                              ),
                              //---------------------------------------------------------------------------------------------

                              DataRow(
                                cells: <DataCell>[
                                  DataCell(Text('SAG mm')),
                                  DataCell(TextField(
                                    controller: rearPreloadController,
                                    maxLength: 3,
                                    decoration: InputDecoration(
                                        counterText: '',
                                        constraints: BoxConstraints(
                                            maxWidth: inputCellWidth)),
                                    style: TextStyle(color: Colors.black),
                                  )),
                                ],
                              ),

                              //---------------------------------------------------------------------------------------------

                              DataRow(
                                cells: <DataCell>[
                                  DataCell(Text('Compression Low speed')),
                                  DataCell(TextField(
                                    controller:
                                        rearLowspeedCompressionController,
                                    maxLength: 3,
                                    decoration: InputDecoration(
                                        counterText: '',
                                        constraints: BoxConstraints(
                                            maxWidth: inputCellWidth)),
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
                                    controller:
                                        rearHighspeedCompressionController,
                                    maxLength: 3,
                                    decoration: InputDecoration(
                                        counterText: '',
                                        constraints: BoxConstraints(
                                            maxWidth: inputCellWidth)),
                                    style: TextStyle(color: Colors.black),
                                  )),
                                ],
                              ),
                              //---------------------------------------------------------------------------------------------

                              DataRow(
                                cells: <DataCell>[
                                  DataCell(Text('Rebound')),
                                  DataCell(TextField(
                                    controller: rearReboundController,
                                    maxLength: 3,
                                    decoration: InputDecoration(
                                        counterText: '',
                                        constraints: BoxConstraints(
                                            maxWidth: inputCellWidth)),
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

                  //---------------------------------------------------------------------------------------------
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
