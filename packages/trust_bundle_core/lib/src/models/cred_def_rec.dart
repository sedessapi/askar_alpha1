import 'package:isar/isar.dart';

part 'cred_def_rec.g.dart';

@collection
class CredDefRec {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String credDefId;

  late String content;
}
