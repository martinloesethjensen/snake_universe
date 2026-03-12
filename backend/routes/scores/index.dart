import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:shared_models/shared_models.dart';
import 'package:supabase/supabase.dart' as db;

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.get => await _get(context),
    HttpMethod.post => await _post(context),
    _ => Response(
      statusCode: HttpStatus.methodNotAllowed,
      headers: {'Allow': '${HttpMethod.get.value}, ${HttpMethod.post.value}'},
    ),
  };
}

Future<Response> _get(RequestContext context) async {
  final supabase = context.read<db.SupabaseClient>();
  final data = await supabase
      .from('high_scores')
      .select('name, score')
      .order('score', ascending: false)
      .limit(25);
  final scores = data.map(Score.fromJson);
  return Response.json(body: scores.toList());
}

Future<Response> _post(RequestContext context) async {
  final Score score;
  try {
    final json = await context.request.json() as Map<String, dynamic>;
    score = Score.fromJson(json);
  } catch (_) {
    return Response(statusCode: HttpStatus.badRequest);
  }

  if (score.name.isEmpty || score.score < 0) {
    return Response(
      statusCode: HttpStatus.unprocessableEntity,
      body: 'Name must be non-empty and score must be non-negative',
    );
  }

  final supabase = context.read<db.SupabaseClient>();
  final created = await supabase
      .from('high_scores')
      .insert(score.toJson())
      .select('name, score')
      .limit(1)
      .single();

  return Response.json(
    statusCode: HttpStatus.created,
    body: Score.fromJson(created),
  );
}
