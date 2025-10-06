import 'package:isar/isar.dart';

part 'bundle_rec.g.dart';

@collection
class BundleRec {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String bundleId;

  late DateTime lastUpdated;

  late String content;
}
