import 'package:isar/isar.dart';

part 'venue_model.g.dart';

@collection
class VenueModel {
  Id id = Isar.autoIncrement;

  late String name;
  late String code;
}
