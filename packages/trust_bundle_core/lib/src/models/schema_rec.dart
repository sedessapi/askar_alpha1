import 'package:isar/isar.dart';

part 'schema_rec.g.dart';

@collection
class SchemaRec {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String schemaId;

  late String content;
}
