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
  final supabasePublishableKey =
      Platform.environment['SUPABASE_PUBLISHABLE_KEY'];

  if (supabaseUrl == null || supabasePublishableKey == null) {
    throw StateError(
      'Missing required environment variables: SUPABASE_URL and/or SUPABASE_PUBLISHABLE_KEY',
    );
  }

  final supabase = SupabaseClient(supabaseUrl, supabasePublishableKey);

  final pipeline = const Pipeline()
      .addMiddleware(supabaseProvider(supabase))
      .addHandler(handler);

  return serve(pipeline, ip, port);
}
