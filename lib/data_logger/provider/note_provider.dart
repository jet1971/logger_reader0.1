import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:ble1/data_logger/log_viewer/widgets/sideBar/isar_database_stuff/models/note.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ble1/data_logger/log_viewer/widgets/sideBar/isar_database_stuff/models/venue_model.dart';

/// Call this in main() to initialize the Isar database
Future<Isar> initializeIsar() async {
  final dir = await getApplicationDocumentsDirectory();

  return Isar.open(
    [NoteSchema,
    VenueModelSchema,
    ],
    directory: dir.path,
  );
}

final isarProvider = Provider<Isar>((ref) => throw UnimplementedError());

final noteProvider = StateNotifierProvider<NoteNotifier, Note?>((ref) {
  final isar = ref.watch(isarProvider);
  return NoteNotifier(isar);
});

class NoteNotifier extends StateNotifier<Note?> {
  final Isar _isar;
  NoteNotifier(this._isar) : super(null);

  /// Load the single note for a file
  Future<void> loadNoteForFile(String fileName) async {
    final note =
        await _isar.notes.filter().fileNameEqualTo(fileName).findFirst();
    if (note == null) {
      final newNote = Note()..fileName = fileName;
      await _isar.writeTxn(() => _isar.notes.put(newNote));
      state = newNote;
    } else {
      state = note;
    }
  }

  Future<void> saveNote(Note note) async {
    await _isar.writeTxn(() => _isar.notes.put(note));
    state = note;
  }

  Future<void> deleteNoteForFile(String fileName) async {
    final note =
        await _isar.notes.filter().fileNameEqualTo(fileName).findFirst();
    if (note != null) {
      await _isar.writeTxn(() => _isar.notes.delete(note.id));
      state = null;
    }
  }
}
