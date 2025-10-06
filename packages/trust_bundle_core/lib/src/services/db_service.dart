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
      inspector: true, // Enable inspector
    );
  }

  /// Get the Isar Inspector URL (only works in debug mode)
  String? getInspectorUrl() {
    try {
      // The inspector URL is printed to console, but we can construct it
      // from the Isar instance name. In debug mode, Isar automatically
      // starts the inspector server.
      return 'Check terminal for Isar Inspector URL';
    } catch (e) {
      return null;
    }
  }

  /// Clear all trust bundle data (bundles, schemas, cred defs)
  Future<void> clearAllTrustBundleData() async {
    await isar.writeTxn(() async {
      await isar.bundleRecs.clear();
      await isar.schemaRecs.clear();
      await isar.credDefRecs.clear();
    });
    print('🗑️ Cleared all trust bundle data');
  }
}
