import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

/// SQLite compiled to WebAssembly. Used on the web, where `dart:ffi` does not
/// exist. Requires `web/sqlite3.wasm` and `web/drift_worker.js` to be served
/// next to `index.html`.
QueryExecutor openConnection() {
  return LazyDatabase(() async {
    final result = await WasmDatabase.open(
      databaseName: 'animals',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );
    return result.resolvedExecutor;
  });
}
