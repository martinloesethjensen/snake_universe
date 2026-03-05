import 'dart:io';

import 'package:postgres/postgres.dart';

// ignore: public_member_api_docs
Pool<Object> createPool() {
  final url = Platform.environment['DATABASE_URL'] ?? '';
  if (url.isEmpty) throw StateError('DATABASE_URL env var must be set');

  final uri = Uri.parse(url);
  final userInfo = uri.userInfo.split(':');

  return Pool<Object>.withEndpoints(
    [
      Endpoint(
        host: uri.host,
        port: uri.hasPort ? uri.port : 5432,
        database: uri.path.replaceFirst('/', ''),
        username: userInfo.first,
        password: userInfo.length > 1 ? Uri.decodeComponent(userInfo[1]) : null,
      ),
    ],
    settings: const PoolSettings(sslMode: SslMode.require),
  );
}
