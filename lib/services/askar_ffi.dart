import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:ffi/ffi.dart';

// FFI type definitions for Rust functions

typedef ProvisionWalletNative = ffi.Pointer<Utf8> Function(
  ffi.Pointer<Utf8> dbPath,
  ffi.Pointer<Utf8> rawKey,
);
typedef ProvisionWalletDart = ffi.Pointer<Utf8> Function(
  ffi.Pointer<Utf8> dbPath,
  ffi.Pointer<Utf8> rawKey,
);

typedef InsertEntryNative = ffi.Pointer<Utf8> Function(
  ffi.Pointer<Utf8> dbPath,
  ffi.Pointer<Utf8> rawKey,
  ffi.Pointer<Utf8> entryName,
  ffi.Pointer<Utf8> entryValue,
);
typedef InsertEntryDart = ffi.Pointer<Utf8> Function(
  ffi.Pointer<Utf8> dbPath,
  ffi.Pointer<Utf8> rawKey,
  ffi.Pointer<Utf8> entryName,
  ffi.Pointer<Utf8> entryValue,
);

typedef ListEntriesNative = ffi.Pointer<Utf8> Function(
  ffi.Pointer<Utf8> dbPath,
  ffi.Pointer<Utf8> rawKey,
);
typedef ListEntriesDart = ffi.Pointer<Utf8> Function(
  ffi.Pointer<Utf8> dbPath,
  ffi.Pointer<Utf8> rawKey,
);

typedef ImportBulkEntriesNative = ffi.Pointer<Utf8> Function(
  ffi.Pointer<Utf8> dbPath,
  ffi.Pointer<Utf8> rawKey,
  ffi.Pointer<Utf8> jsonData,
);
typedef ImportBulkEntriesDart = ffi.Pointer<Utf8> Function(
  ffi.Pointer<Utf8> dbPath,
  ffi.Pointer<Utf8> rawKey,
  ffi.Pointer<Utf8> jsonData,
);

typedef ListCategoriesNative = ffi.Pointer<Utf8> Function(
  ffi.Pointer<Utf8> dbPath,
  ffi.Pointer<Utf8> rawKey,
);
typedef ListCategoriesDart = ffi.Pointer<Utf8> Function(
  ffi.Pointer<Utf8> dbPath,
  ffi.Pointer<Utf8> rawKey,
);

typedef FreeStringNative = ffi.Void Function(ffi.Pointer<Utf8> ptr);
typedef FreeStringDart = void Function(ffi.Pointer<Utf8> ptr);

/// Singleton class for Askar FFI operations
class AskarFfi {
  static final AskarFfi _instance = AskarFfi._internal();
  late final ffi.DynamicLibrary _lib;
  late final ProvisionWalletDart _provisionWallet;
  late final InsertEntryDart _insertEntry;
  late final ListEntriesDart _listEntries;
  late final ImportBulkEntriesDart _importBulkEntries;
  late final ListCategoriesDart _listCategories;
  late final FreeStringDart _freeString;

  factory AskarFfi() {
    return _instance;
  }

  AskarFfi._internal() {
    _lib = _loadLibrary();

    _provisionWallet = _lib
        .lookup<ffi.NativeFunction<ProvisionWalletNative>>('provision_wallet')
        .asFunction<ProvisionWalletDart>();

    _insertEntry = _lib
        .lookup<ffi.NativeFunction<InsertEntryNative>>('insert_entry')
        .asFunction<InsertEntryDart>();

    _listEntries = _lib
        .lookup<ffi.NativeFunction<ListEntriesNative>>('list_entries')
        .asFunction<ListEntriesDart>();

    _importBulkEntries = _lib
        .lookup<ffi.NativeFunction<ImportBulkEntriesNative>>(
          'import_bulk_entries',
        )
        .asFunction<ImportBulkEntriesDart>();

    _listCategories = _lib
        .lookup<ffi.NativeFunction<ListCategoriesNative>>('list_categories')
        .asFunction<ListCategoriesDart>();

    _freeString = _lib
        .lookup<ffi.NativeFunction<FreeStringNative>>('free_string')
        .asFunction<FreeStringDart>();
  }

  ffi.DynamicLibrary _loadLibrary() {
    if (Platform.isAndroid) {
      return ffi.DynamicLibrary.open('libffi_bridge.so');
    }
    if (Platform.isIOS) {
      return ffi.DynamicLibrary.process();
    }
    if (Platform.isMacOS) {
      // For macOS, use the library from the project directory
      // This works for both development and release builds
      final executableDir = File(Platform.resolvedExecutable).parent.path;

      // Try multiple locations in order of preference
      final possiblePaths = [
        // 1. Bundled with app (release builds)
        '$executableDir/../Frameworks/libffi_bridge.dylib',
        // 2. In macos/libs directory (development builds)
        '/Users/itzmi/dev/askar_alpha/macos/libs/libffi_bridge.dylib',
        // 3. Just the library name (if it's in system path)
        'libffi_bridge.dylib',
      ];

      for (final path in possiblePaths) {
        try {
          return ffi.DynamicLibrary.open(path);
        } catch (e) {
          // Try next path
          continue;
        }
      }

      throw UnsupportedError(
        'Could not load libffi_bridge.dylib. Please run: cd rust_lib && ./build_all.sh',
      );
    }
    throw UnsupportedError('Unsupported platform for Askar FFI');
  }

  /// Provisions (creates) a new Askar wallet
  ///
  /// [dbPath]: File path for the wallet database
  /// [rawKey]: Base58-encoded encryption key
  ///
  /// Returns: `{"success": true/false, "error": "..."}`
  Map<String, dynamic> provisionWallet({
    required String dbPath,
    required String rawKey,
  }) {
    final dbPathPtr = dbPath.toNativeUtf8();
    final rawKeyPtr = rawKey.toNativeUtf8();
    ffi.Pointer<Utf8> resultPtr = ffi.nullptr;

    try {
      resultPtr = _provisionWallet(dbPathPtr, rawKeyPtr);
      final resultString = resultPtr.toDartString();
      return jsonDecode(resultString) as Map<String, dynamic>;
    } finally {
      malloc.free(dbPathPtr);
      malloc.free(rawKeyPtr);
      if (resultPtr != ffi.nullptr) {
        _freeString(resultPtr);
      }
    }
  }

  /// Inserts a single entry into the wallet
  ///
  /// [dbPath]: File path for the wallet database
  /// [rawKey]: Base58-encoded encryption key
  /// [entryName]: Name/key for the entry
  /// [entryValue]: Value to store (will be converted to string)
  ///
  /// Returns: `{"success": true/false, "error": "..."}`
  Map<String, dynamic> insertEntry({
    required String dbPath,
    required String rawKey,
    required String entryName,
    required String entryValue,
  }) {
    final dbPathPtr = dbPath.toNativeUtf8();
    final rawKeyPtr = rawKey.toNativeUtf8();
    final entryNamePtr = entryName.toNativeUtf8();
    final entryValuePtr = entryValue.toNativeUtf8();
    ffi.Pointer<Utf8> resultPtr = ffi.nullptr;

    try {
      resultPtr = _insertEntry(
        dbPathPtr,
        rawKeyPtr,
        entryNamePtr,
        entryValuePtr,
      );
      final resultString = resultPtr.toDartString();
      return jsonDecode(resultString) as Map<String, dynamic>;
    } finally {
      malloc.free(dbPathPtr);
      malloc.free(rawKeyPtr);
      malloc.free(entryNamePtr);
      malloc.free(entryValuePtr);
      if (resultPtr != ffi.nullptr) {
        _freeString(resultPtr);
      }
    }
  }

  /// Lists all entries in the wallet
  ///
  /// [dbPath]: File path for the wallet database
  /// [rawKey]: Base58-encoded encryption key
  ///
  /// Returns: `{"success": true/false, "entries": [...], "error": "..."}`
  Map<String, dynamic> listEntries({
    required String dbPath,
    required String rawKey,
  }) {
    final dbPathPtr = dbPath.toNativeUtf8();
    final rawKeyPtr = rawKey.toNativeUtf8();
    ffi.Pointer<Utf8> resultPtr = ffi.nullptr;

    try {
      resultPtr = _listEntries(dbPathPtr, rawKeyPtr);
      final resultString = resultPtr.toDartString();
      return jsonDecode(resultString) as Map<String, dynamic>;
    } finally {
      malloc.free(dbPathPtr);
      malloc.free(rawKeyPtr);
      if (resultPtr != ffi.nullptr) {
        _freeString(resultPtr);
      }
    }
  }

  /// Imports entries from an Askar export JSON into the wallet
  ///
  /// [dbPath]: File path for the wallet database
  /// [rawKey]: Base58-encoded encryption key
  /// [jsonData]: Complete export JSON string
  ///
  /// Expected JSON structure:
  /// ```json
  /// {
  ///   "category1": [
  ///     {"name": "key1", "value": {...}, "tags": {"tag1": "val1"}},
  ///     ...
  ///   ],
  ///   "category2": [...]
  /// }
  /// ```
  ///
  /// Returns:
  /// ```json
  /// {
  ///   "success": true,
  ///   "imported": 150,
  ///   "failed": 2,
  ///   "categories": {
  ///     "credential": {"imported": 100, "failed": 1},
  ///     "schema": {"imported": 50, "failed": 1}
  ///   }
  /// }
  /// ```
  Map<String, dynamic> importBulkEntries({
    required String dbPath,
    required String rawKey,
    required String jsonData,
  }) {
    final dbPathPtr = dbPath.toNativeUtf8();
    final rawKeyPtr = rawKey.toNativeUtf8();
    final jsonDataPtr = jsonData.toNativeUtf8();
    ffi.Pointer<Utf8> resultPtr = ffi.nullptr;

    try {
      resultPtr = _importBulkEntries(dbPathPtr, rawKeyPtr, jsonDataPtr);
      final resultString = resultPtr.toDartString();
      return jsonDecode(resultString) as Map<String, dynamic>;
    } finally {
      malloc.free(dbPathPtr);
      malloc.free(rawKeyPtr);
      malloc.free(jsonDataPtr);
      if (resultPtr != ffi.nullptr) {
        _freeString(resultPtr);
      }
    }
  }

  /// Lists all categories and their entry counts in the wallet
  ///
  /// [dbPath]: File path for the wallet database
  /// [rawKey]: Base58-encoded encryption key
  ///
  /// Returns:
  /// ```json
  /// {
  ///   "success": true,
  ///   "categories": {
  ///     "credential": 100,
  ///     "schema": 50,
  ///     "credential_definition": 25
  ///   },
  ///   "total": 175
  /// }
  /// ```
  Map<String, dynamic> listCategories({
    required String dbPath,
    required String rawKey,
  }) {
    final dbPathPtr = dbPath.toNativeUtf8();
    final rawKeyPtr = rawKey.toNativeUtf8();
    ffi.Pointer<Utf8> resultPtr = ffi.nullptr;

    try {
      resultPtr = _listCategories(dbPathPtr, rawKeyPtr);
      final resultString = resultPtr.toDartString();
      return jsonDecode(resultString) as Map<String, dynamic>;
    } finally {
      malloc.free(dbPathPtr);
      malloc.free(rawKeyPtr);
      if (resultPtr != ffi.nullptr) {
        _freeString(resultPtr);
      }
    }
  }
}
