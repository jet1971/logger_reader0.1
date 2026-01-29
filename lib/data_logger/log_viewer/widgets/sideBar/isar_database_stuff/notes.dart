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
            title: Text(
          "Notes for $venueAndDate",
          style: TextStyle(fontSize: 18),
        )),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(1.0),
            child: SizedBox(
              width: 700,
              child: Column(
                children: [
                  Row(
                    children: [Text('Session'), SizedBox(width: 100,), Text('$venueAndDate',),],
                  ),
                  Row(),
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
                    rows: <DataRow>[
                      DataRow(
                        color: WidgetStateProperty.all(Colors.red),
                        cells: <DataCell>[
                          DataCell(Text('Session')),
                        //  DataCell(Text('$venueAndDate')),
                          DataCell(TextField(
                            controller: sessionController,
                            decoration: const InputDecoration(fillColor: Color.fromARGB(0, 158, 158, 158),
                                constraints: BoxConstraints(minWidth: 200, maxWidth: 200)),
                            style: TextStyle(color: Colors.white),
                          )),
                          DataCell(Text('Weather')),
                          DataCell(Text('Rain')),
                        ],
                      ),
                      DataRow(
                        cells: <DataCell>[
                          DataCell(Text('Front Sprocket')),
                          DataCell(TextField(
                            controller: frontSprocketController,
                            decoration: const InputDecoration(
                                fillColor: Color.fromARGB(0, 158, 158, 158),
                                constraints: BoxConstraints(minWidth: 0)),
                            style: TextStyle(color: Colors.white),
                          )),
                          DataCell(Text('Rear Sprocket')),
                          DataCell(TextField(
                            controller: rearSprocketController,
                            decoration: const InputDecoration(
                                constraints: BoxConstraints(maxWidth: 55)),
                            style: TextStyle(color: Colors.black),
                          )),
                        ],
                      ),
                      DataRow(
                        cells: <DataCell>[
                          DataCell(Text('Rear Sprocket')),
                          DataCell(TextField(
                            controller: rearSprocketController,
                            decoration: const InputDecoration(
                                constraints: BoxConstraints(maxWidth: 55)),
                            style: TextStyle(color: Colors.black),
                          )),
                          DataCell(Text('Session')),
                          DataCell(TextField(
                            controller: sessionController,
                            decoration: const InputDecoration(
                                constraints: BoxConstraints(minWidth: 0)),
                            style: TextStyle(color: Colors.black),
                          )),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  // TextField(
                  //     controller: sessionController,
                  //     decoration: const InputDecoration(labelText: 'Race/Session',),
                  //     style: TextStyle(color: Colors.black),),
                  //     SizedBox(height: 10,),

                  // TextField(
                  //     controller: frontSprocketController,
                  //     decoration: const InputDecoration(labelText: 'Num T')),
                  //     SizedBox(
                  //   height: 10,
                  // ),
                  // TextField(
                  //     controller: mainJetController,
                  //     decoration: const InputDecoration(labelText: 'Main Jet')),
                  // TextField(
                  //     controller: pilotJetController,
                  //     decoration: const InputDecoration(labelText: 'Pilot Jet')),
                  // TextField(
                  //     controller: needleController,
                  //     decoration:
                  //         const InputDecoration(labelText: 'Needle Position')),
                  TextField(
                      style: TextStyle(color: Colors.black),
                      controller: notesController,
                      decoration: const InputDecoration(
                        constraints: BoxConstraints(minWidth: 500),
                      ),
                      maxLines: 4),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      final updated = note
                        ..session = sessionController.text
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
    );
  }
}
