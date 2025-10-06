import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/bundle_rec.dart';
import '../models/cred_def_rec.dart';
import '../models/schema_rec.dart';

class DbService {
  late final Isar isar;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [BundleRecSchema, CredDefRecSchema, SchemaRecSchema],
      directory: dir.path,
    );
  }
}
