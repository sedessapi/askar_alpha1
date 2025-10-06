import 'dart:async';
import 'dart:convert';

import '../crypto/manifest_verifier.dart';
import '../models/bundle_rec.dart';
import '../models/cred_def_rec.dart';
import '../models/schema_rec.dart';
import 'bundle_client.dart';
import 'db_service.dart';

enum IngestionStatus {
  fetching,
  verifying,
  parsing,
  savingSchemas,
  savingCredDefs,
  complete,
  error,
}

class IngestionProgress {
  final IngestionStatus status;
  final int current;
  final int total;
  final String message;

  IngestionProgress(
    this.status, {
    this.current = 0,
    this.total = 0,
    this.message = '',
  });
}

class IngestionService {
  final BundleClient _bundleClient;
  final DbService _dbService;
  final ManifestVerifier _manifestVerifier;

  IngestionService({
    required BundleClient bundleClient,
    required DbService dbService,
    required ManifestVerifier manifestVerifier,
  }) : _bundleClient = bundleClient,
       _dbService = dbService,
       _manifestVerifier = manifestVerifier;

  /// Fetch and preview the bundle without saving to database
  Future<Map<String, dynamic>> previewBundle() async {
    final bundle = await _bundleClient.fetchBundle();
    
    // Verify the bundle
    if (!_manifestVerifier.verify(bundle)) {
      throw Exception('Manifest signature verification failed');
    }

    // Extract metadata - handle nested artifacts structure
    final artifacts = bundle['artifacts'] as Map<String, dynamic>?;
    final schemas = (artifacts?['schemas'] as Map<String, dynamic>?)?.values.toList() ?? [];
    final credDefs = (artifacts?['cred_defs'] as Map<String, dynamic>?)?.values.toList() ?? [];
    final bundleVersion = bundle['bundle_version']?.toString() ?? 'unknown';
    final network = bundle['network'] as String? ?? 'unknown';

    return {
      'bundleVersion': bundleVersion,
      'network': network,
      'schemaCount': schemas.length,
      'credDefCount': credDefs.length,
      'schemas': schemas,
      'credDefs': credDefs,
      'generatedAt': bundle['generated_at'],
      'expiresAt': bundle['expires_at'],
      'rawBundle': bundle, // Include raw bundle for saving
    };
  }

  /// Save an already-fetched and verified bundle to database
  Stream<IngestionProgress> savePreviewedBundle(Map<String, dynamic> rawBundle) {
    final controller = StreamController<IngestionProgress>();

    Future<void> doSave() async {
      try {
        controller.add(
          IngestionProgress(
            IngestionStatus.parsing,
            message: 'Preparing to save...',
          ),
        );
        
        // Handle the actual bundle structure from the server
        final bundleVersion = rawBundle['bundle_version']?.toString() ?? 'unknown';
        final network = rawBundle['network'] as String? ?? 'unknown';
        final bundleId = '${network}_v${bundleVersion}';
        final bundleContent = json.encode(rawBundle);

        // Extract schemas and cred_defs from the nested artifacts structure
        final artifacts = rawBundle['artifacts'] as Map<String, dynamic>?;
        final schemasMap = artifacts?['schemas'] as Map<String, dynamic>?;
        final credDefsMap = artifacts?['cred_defs'] as Map<String, dynamic>?;
        
        final schemas = schemasMap?.values.toList() ?? [];
        final credDefs = credDefsMap?.values.toList() ?? [];
        final totalItems = schemas.length + credDefs.length;
        int processedItems = 0;

        await _dbService.isar.writeTxn(() async {
          final existingBundle = await _dbService.isar.bundleRecs.getByBundleId(
            bundleId,
          );

          if (existingBundle != null &&
              existingBundle.content == bundleContent) {
            // No changes, but we'll still report completion.
          } else if (existingBundle != null) {
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
                ..content = bundleContent,
            );
          }

          controller.add(
            IngestionProgress(
              IngestionStatus.savingSchemas,
              current: processedItems,
              total: totalItems,
              message: 'Saving schemas...',
            ),
          );
          for (final schema in schemas) {
            final schemaId = schema['id'] as String;
            final schemaContent = json.encode(schema);
            await _dbService.isar.schemaRecs.put(
              SchemaRec()
                ..schemaId = schemaId
                ..content = schemaContent,
            );
            processedItems++;
            if (processedItems % 50 == 0) {
              controller.add(
                IngestionProgress(
                  IngestionStatus.savingSchemas,
                  current: processedItems,
                  total: totalItems,
                  message: 'Saving schemas...',
                ),
              );
            }
          }

          controller.add(
            IngestionProgress(
              IngestionStatus.savingCredDefs,
              current: processedItems,
              total: totalItems,
              message: 'Saving credential definitions...',
            ),
          );
          for (final credDef in credDefs) {
            final credDefId = credDef['id'] as String;
            final credDefContent = json.encode(credDef);
            await _dbService.isar.credDefRecs.put(
              CredDefRec()
                ..credDefId = credDefId
                ..content = credDefContent,
            );
            processedItems++;
            if (processedItems % 50 == 0) {
              controller.add(
                IngestionProgress(
                  IngestionStatus.savingCredDefs,
                  current: processedItems,
                  total: totalItems,
                  message: 'Saving credential definitions...',
                ),
              );
            }
          }
        });

        controller.add(
          IngestionProgress(
            IngestionStatus.complete,
            current: totalItems,
            total: totalItems,
            message: 'Save complete',
          ),
        );
        await controller.close();
      } catch (e) {
        controller.add(
          IngestionProgress(
            IngestionStatus.error,
            message: 'Error during save: $e',
          ),
        );
        await controller.close();
      }
    }

    doSave();
    return controller.stream;
  }

  Stream<IngestionProgress> ingestBundle() {
    final controller = StreamController<IngestionProgress>();

    Future<void> doIngest() async {
      try {
        controller.add(
          IngestionProgress(
            IngestionStatus.fetching,
            message: 'Fetching bundle...',
          ),
        );
        final bundle = await _bundleClient.fetchBundle();

        controller.add(
          IngestionProgress(
            IngestionStatus.verifying,
            message: 'Verifying bundle signature...',
          ),
        );
        if (!_manifestVerifier.verify(bundle)) {
          throw Exception('Manifest signature verification failed');
        }

        controller.add(
          IngestionProgress(
            IngestionStatus.parsing,
            message: 'Parsing bundle...',
          ),
        );
        
        // Handle the actual bundle structure from the server
        final bundleVersion = bundle['bundle_version']?.toString() ?? 'unknown';
        final network = bundle['network'] as String? ?? 'unknown';
        final bundleId = '${network}_v${bundleVersion}';
        final bundleContent = json.encode(bundle);

        // Extract schemas and cred_defs from the nested artifacts structure
        final artifacts = bundle['artifacts'] as Map<String, dynamic>?;
        final schemasMap = artifacts?['schemas'] as Map<String, dynamic>?;
        final credDefsMap = artifacts?['cred_defs'] as Map<String, dynamic>?;
        
        final schemas = schemasMap?.values.toList() ?? [];
        final credDefs = credDefsMap?.values.toList() ?? [];
        final totalItems = schemas.length + credDefs.length;
        int processedItems = 0;

        await _dbService.isar.writeTxn(() async {
          final existingBundle = await _dbService.isar.bundleRecs.getByBundleId(
            bundleId,
          );

          if (existingBundle != null &&
              existingBundle.content == bundleContent) {
            // No changes, but we'll still report completion.
          } else if (existingBundle != null) {
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
                ..content = bundleContent,
            );
          }

          controller.add(
            IngestionProgress(
              IngestionStatus.savingSchemas,
              current: processedItems,
              total: totalItems,
              message: 'Saving schemas...',
            ),
          );
          for (final schema in schemas) {
            final schemaId = schema['id'] as String;
            final schemaContent = json.encode(schema);
            await _dbService.isar.schemaRecs.put(
              SchemaRec()
                ..schemaId = schemaId
                ..content = schemaContent,
            );
            processedItems++;
            if (processedItems % 50 == 0) {
              controller.add(
                IngestionProgress(
                  IngestionStatus.savingSchemas,
                  current: processedItems,
                  total: totalItems,
                  message: 'Saving schemas...',
                ),
              );
            }
          }

          controller.add(
            IngestionProgress(
              IngestionStatus.savingCredDefs,
              current: processedItems,
              total: totalItems,
              message: 'Saving credential definitions...',
            ),
          );
          for (final credDef in credDefs) {
            final credDefId = credDef['id'] as String;
            final credDefContent = json.encode(credDef);
            await _dbService.isar.credDefRecs.put(
              CredDefRec()
                ..credDefId = credDefId
                ..content = credDefContent,
            );
            processedItems++;
            if (processedItems % 50 == 0) {
              controller.add(
                IngestionProgress(
                  IngestionStatus.savingCredDefs,
                  current: processedItems,
                  total: totalItems,
                  message: 'Saving credential definitions...',
                ),
              );
            }
          }
        });

        controller.add(
          IngestionProgress(
            IngestionStatus.complete,
            current: totalItems,
            total: totalItems,
            message: 'Sync complete',
          ),
        );
        await controller.close();
      } catch (e) {
        controller.add(
          IngestionProgress(
            IngestionStatus.error,
            message: 'Error during ingestion: $e',
          ),
        );
        await controller.close();
      }
    }

    doIngest();
    return controller.stream;
  }
}
