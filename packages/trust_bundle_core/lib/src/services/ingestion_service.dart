import 'dart:convert';

import '../models/bundle_rec.dart';
import '../models/cred_def_rec.dart';
import '../models/schema_rec.dart';
import 'bundle_client.dart';
import 'db_service.dart';

class IngestionService {
  final BundleClient _bundleClient;
  final DbService _dbService;

  IngestionService({
    required BundleClient bundleClient,
    required DbService dbService,
  }) : _bundleClient = bundleClient,
       _dbService = dbService;

  Future<void> ingestBundle() async {
    final bundle = await _bundleClient.fetchBundle();
    final bundleId = bundle['id'] as String;
    final bundleContent = json.encode(bundle);

    await _dbService.isar.writeTxn(() async {
      final existingBundle = await _dbService.isar.bundleRecs.getByBundleId(
        bundleId,
      );

      if (existingBundle != null && existingBundle.content == bundleContent) {
        return;
      }

      if (existingBundle != null) {
        await _dbService.isar.bundleRecs.put(
          existingBundle
            ..lastUpdated = DateTime.now()
            ..content = bundleContent,
        );
      } else {
        await _dbService.isar.bundleRecs.put(
          BundleRec()
            ..bundleId = bundleId
            ..lastUpdated = DateTime.now()
            // ignore: cascade_invocations
            ..content = bundleContent,
        );
      }

      final schemas = bundle['schemas'] as List;
      for (final schema in schemas) {
        final schemaId = schema['id'] as String;
        final schemaContent = json.encode(schema);
        await _dbService.isar.schemaRecs.put(
          SchemaRec()
            ..schemaId = schemaId
            ..content = schemaContent,
        );
      }

      final credDefs = bundle['cred_defs'] as List;
      for (final credDef in credDefs) {
        final credDefId = credDef['id'] as String;
        final credDefContent = json.encode(credDef);
        await _dbService.isar.credDefRecs.put(
          CredDefRec()
            ..credDefId = credDefId
            ..content = credDefContent,
        );
      }
    });
  }
}
