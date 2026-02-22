// Run the command to generate the code: flutter pub run build_runner build

import 'package:isar/isar.dart';

part 'note.g.dart';

@collection
class Note {
  Id id = Isar.autoIncrement;

  late String fileName; // Which log this note belongs to

  // Structured fields
  String session = '';
  String weather = '';
  String rider = '';
  String frontSprocket = '';
  String rearSprocket = '';
  String mainJet = '';
  String needlePosition = '';
  String pilotJet = '';
  String preload = '';
  String compression = '';
  String rebound = '';
  String maxAdvanceController = '';
  String ratioController = '';
  String rearPreloadController = '';
  String rearLowspeedCompressionController = '';
  String rearHighspeedCompressionController = '';
  String rearReboundController = '';

  // Freeform notes
  String additionalNotes = '';
}
