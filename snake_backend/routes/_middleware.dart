import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:logging/logging.dart';

final _logger = Logger('snake_backend');

bool _loggerInitialized = false;

void _initLogger() {
  if (_loggerInitialized) return;
  _loggerInitialized = true;
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    final msg =
        'LOG: [${record.time.toIso8601String()}] [${record.level.name}] '
        '${record.message}';
    if (record.level >= Level.SEVERE) {
      stderr.writeln(msg);
      if (record.error != null) stderr.writeln('  ERROR: ${record.error}');
      if (record.stackTrace != null) {
        stderr.writeln('  STACK:\n${record.stackTrace}');
      }
    } else {
      stdout.writeln(msg);
    }
  });
}

Handler middleware(Handler handler) {
  _initLogger();
  return (context) async {
    final method = context.request.method.value;
    final path = context.request.uri.path;
    final start = DateTime.now();

    try {
      final response = await handler(context);
      final ms = DateTime.now().difference(start).inMilliseconds;
      _logger.info(
        'LOG: [${start.toIso8601String()}] [$method] [$path]'
        ' - ${response.statusCode} (${ms}ms)',
      );
      return response;
    } catch (e, st) {
      final ms = DateTime.now().difference(start).inMilliseconds;
      _logger.severe(
        'LOG: [${start.toIso8601String()}] [$method] [$path] - 500 (${ms}ms)',
        e,
        st,
      );
      return Response(
        statusCode: HttpStatus.internalServerError,
        body: 'Internal Server Error',
      );
    }
  };
}
