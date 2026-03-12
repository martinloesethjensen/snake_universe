import 'dart:io';

import 'package:backend/middlewares/supabase_provider.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:supabase/supabase.dart';

Future<HttpServer> bootstrap({
  required Handler handler,
  required InternetAddress ip,
  required int port,
}) async {
  final supabaseUrl = Platform.environment['SUPABASE_URL'];
  final supabaseSecretKey = Platform.environment['SUPABASE_SECRET_KEY'];

  if (supabaseUrl == null || supabaseSecretKey == null) {
    throw StateError(
      'Missing required environment variables: SUPABASE_URL and/or SUPABASE_SECRET_KEY',
    );
  }

  final supabase = SupabaseClient(supabaseUrl, supabaseSecretKey);

  final pipeline = const Pipeline()
      .addMiddleware(supabaseProvider(supabase))
      .addHandler(handler);

  return serve(pipeline, ip, port);
}
