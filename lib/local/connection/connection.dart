import 'package:drift/drift.dart';

import 'io.dart'
    if (dart.library.js_interop) 'web.dart' as driver;

/// Picks the platform-appropriate SQLite driver at compile time.
///
/// On Android, Windows, iOS and macOS this resolves to [io.dart] (native
/// SQLite via `dart:ffi`). On the web it resolves to [web.dart] (SQLite
/// compiled to WebAssembly). Only the selected file is compiled into the
/// bundle, so `dart:ffi` never reaches a web build.
QueryExecutor openConnection() => driver.openConnection();
