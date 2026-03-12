import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

const _allowedOrigins = <String>{
  'https://snakegame.martinloeseth.dev',
  'https://snake-game-90a9e.web.app',
  'https://snake-game-90a9e.firebaseapp.com/',
};

String? _allowedOrigin(String? origin) {
  if (origin == null) return null;
  if (_allowedOrigins.contains(origin)) return origin;
  // Allow any localhost origin for local development.
  if (Uri.tryParse(origin)?.host == 'localhost') return origin;
  return null;
}

Handler middleware(Handler handler) {
  return (context) async {
    final origin = _allowedOrigin(context.request.headers['origin']);
    final corsHeaders = {
      if (origin != null) HttpHeaders.accessControlAllowOriginHeader: origin,
      HttpHeaders.accessControlAllowMethodsHeader: 'GET, POST, OPTIONS',
      HttpHeaders.accessControlAllowHeadersHeader: 'Content-Type',
    };

    if (context.request.method == HttpMethod.options) {
      return Response(statusCode: HttpStatus.noContent, headers: corsHeaders);
    }
    final response = await handler(context);
    return response.copyWith(headers: {...corsHeaders, ...response.headers});
  };
}
